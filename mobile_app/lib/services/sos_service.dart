import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_ble_central/flutter_ble_central.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import '../database/database.dart';
import 'api_service.dart';
import '../sync/sync_service.dart';

class SOSBeaconData {
  final String id;
  final String minerName;
  final String role;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final int? distanceMeters;
  final int? rssi;
  final DateTime timestamp;
  final String? audioNoteUrl;
  final bool isBleAirTagMesh;

  SOSBeaconData({
    required this.id,
    required this.minerName,
    required this.role,
    required this.locationName,
    this.latitude,
    this.longitude,
    this.distanceMeters,
    this.rssi,
    required this.timestamp,
    this.audioNoteUrl,
    this.isBleAirTagMesh = true,
  });
}

class SOSService extends ChangeNotifier {
  SOSService._();
  static final SOSService instance = SOSService._();
  static const String sosServiceUuid = '7b8a2201-6412-4e4f-a134-0b2c9c719b20';
  static const int _beaconVersion = 1;

  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();
  final FlutterBleCentral _central = FlutterBleCentral();
  StreamSubscription<ScanResult>? _scanSubscription;

  bool _isSOSActive = false;
  Position? _currentPosition;

  final List<SOSBeaconData> _networkBeacons = [];
  final List<SOSBeaconData> _bleBeacons = [];
  AppDatabase? _database;
  SyncService? _syncService;
  String? _activeSignalId;
  String _userName = 'Mine user';
  String _role = 'Field user';
  Timer? _gpsTimer;
  Timer? _pollTimer;
  bool _signalSynced = false;
  bool _bleAvailable = false;
  String? _bleError;
  bool _advertisingPermissionGranted = false;

  bool get isSOSActive => _isSOSActive;
  Position? get currentPosition => _currentPosition;
  List<SOSBeaconData> get networkBeacons =>
      List.unmodifiable([..._bleBeacons, ..._networkBeacons]);
  bool get signalSynced => _signalSynced;
  bool get bleAvailable => _bleAvailable;
  String? get bleError => _bleError;

  void initialize(AppDatabase database) {
    _database = database;
    _syncService ??= SyncService(database);
    _pollActiveSignals();
    _pollTimer ??= Timer.periodic(const Duration(seconds: 20), (_) {
      _bleBeacons.removeWhere(
        (beacon) =>
            DateTime.now().difference(beacon.timestamp) >
            const Duration(seconds: 30),
      );
      _pollActiveSignals();
    });
  }

  Future<bool> startNearbyDiscovery() async {
    try {
      final permission = await _central.requestPermission();
      if (permission != CentralBluetoothState.ready &&
          permission != CentralBluetoothState.granted) {
        _bleError = 'Bluetooth permission or adapter is unavailable.';
        _bleAvailable = false;
        notifyListeners();
        return false;
      }
      await _scanSubscription?.cancel();
      _scanSubscription = _central.onScanResult.listen(_handleScanResult);
      final state = await _central.start(serviceUuids: [sosServiceUuid]);
      _bleAvailable =
          state == CentralBluetoothState.ready ||
          state == CentralBluetoothState.granted;
      _bleError = _bleAvailable ? null : 'Bluetooth scanning could not start.';
      notifyListeners();
      return _bleAvailable;
    } catch (error) {
      _bleAvailable = false;
      _bleError = 'Bluetooth scanning failed: $error';
      notifyListeners();
      return false;
    }
  }

  Future<void> stopNearbyDiscovery() async {
    try {
      await _central.stop();
      await _scanSubscription?.cancel();
    } catch (_) {}
    _bleAvailable = false;
    notifyListeners();
  }

  Future<void> initGPS() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> triggerSOS({
    String userName = 'Mine user',
    String role = 'Field user',
  }) async {
    _userName = userName;
    _role = role;
    _activeSignalId ??= const Uuid().v4();
    _isSOSActive = true;
    _signalSynced = false;
    notifyListeners();

    await initGPS();
    await _saveActiveSignal();
    await _startAdvertising();
    await _syncSignal();

    _gpsTimer?.cancel();
    _gpsTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      try {
        _currentPosition = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
        await _startAdvertising();
        await _saveActiveSignal();
        await _syncSignal();
        notifyListeners();
      } catch (_) {}
    });
  }

  Future<void> _startAdvertising() async {
    try {
      // Stop any stale advertising session first to prevent stacked sessions
      try {
        await _peripheral.stop();
      } catch (_) {}

      if (!_advertisingPermissionGranted) {
        PeripheralBluetoothState permission;
        try {
          permission = await _peripheral.requestPermission();
        } catch (e) {
          // Platform-level crash (e.g. BT adapter not initialized, NPE in plugin)
          _bleError = 'Bluetooth adapter unavailable: $e';
          _bleAvailable = false;
          notifyListeners();
          return;
        }
        if (permission != PeripheralBluetoothState.ready &&
            permission != PeripheralBluetoothState.granted) {
          _bleError =
              'Bluetooth advertising permission or adapter is unavailable.';
          notifyListeners();
          return;
        }
        _advertisingPermissionGranted = true;
      }
      final payload = _encodeBeacon(
        active: _isSOSActive,
        id: _activeSignalId ?? '',
        position: _currentPosition,
      );
      try {
        await _peripheral.start(
          advertiseData: Platform.isAndroid
              ? AndroidAdvertiseData(
                  serviceDataUuid: sosServiceUuid,
                  serviceData: payload,
                )
              : AdvertiseDataCore(serviceUuid: sosServiceUuid),
        );
        _bleError = null;
      } catch (error) {
        _bleError = 'Bluetooth SOS advertising failed: $error';
      }
    } catch (e) {
      // Catch-all for any platform-level exception (NullPointerException, etc.)
      _bleError = 'BLE peripheral error: $e';
      _advertisingPermissionGranted = false;
      debugPrint('BLE _startAdvertising platform crash: $e');
    }
    notifyListeners();
  }

  Uint8List _encodeBeacon({
    required bool active,
    required String id,
    required Position? position,
  }) {
    final data = Uint8List(10);
    final bytes = ByteData.sublistView(data);
    data[0] = active ? (_beaconVersion | 0x80) : _beaconVersion;
    var token = 0x811C9DC5;
    for (final byte in utf8.encode(id)) {
      token ^= byte;
      token = (token * 0x01000193) & 0xFFFFFFFF;
    }
    bytes.setUint32(1, token, Endian.big);
    data.setRange(5, 10, _encodeCoarseLocation(position));
    return data;
  }

  List<int> _encodeCoarseLocation(Position? position) {
    if (position == null) return List.filled(5, 0xFF);
    var minLatitude = -90.0;
    var maxLatitude = 90.0;
    var minLongitude = -180.0;
    var maxLongitude = 180.0;
    var even = true;
    var bit = 0;
    var value = 0;
    final output = <int>[];
    for (var index = 0; index < 40; index++) {
      if (even) {
        final midpoint = (minLongitude + maxLongitude) / 2;
        if (position.longitude >= midpoint) {
          value = (value << 1) | 1;
          minLongitude = midpoint;
        } else {
          value <<= 1;
          maxLongitude = midpoint;
        }
      } else {
        final midpoint = (minLatitude + maxLatitude) / 2;
        if (position.latitude >= midpoint) {
          value = (value << 1) | 1;
          minLatitude = midpoint;
        } else {
          value <<= 1;
          maxLatitude = midpoint;
        }
      }
      even = !even;
      bit++;
      if (bit == 8) {
        output.add(value);
        value = 0;
        bit = 0;
      }
    }
    return output;
  }

  (double, double)? _decodeCoarseLocation(List<int> bytes) {
    if (bytes.length != 5 || bytes.every((value) => value == 0xFF)) {
      return null;
    }
    var minLatitude = -90.0;
    var maxLatitude = 90.0;
    var minLongitude = -180.0;
    var maxLongitude = 180.0;
    var even = true;
    for (var index = 0; index < 40; index++) {
      final bit = (bytes[index ~/ 8] >> (7 - index % 8)) & 1;
      if (even) {
        final midpoint = (minLongitude + maxLongitude) / 2;
        if (bit == 1) {
          minLongitude = midpoint;
        } else {
          maxLongitude = midpoint;
        }
      } else {
        final midpoint = (minLatitude + maxLatitude) / 2;
        if (bit == 1) {
          minLatitude = midpoint;
        } else {
          maxLatitude = midpoint;
        }
      }
      even = !even;
    }
    return ((minLatitude + maxLatitude) / 2, (minLongitude + maxLongitude) / 2);
  }

  void _handleScanResult(ScanResult result) {
    final data = result.scanRecord?.serviceData?.entries
        .where((entry) => entry.key.toLowerCase() == sosServiceUuid)
        .firstOrNull
        ?.value;
    if (data == null) {
      final serviceUuids = result.scanRecord?.serviceUuids ?? const [];
      if (Platform.isIOS && serviceUuids.contains(sosServiceUuid)) {
        _upsertBleBeacon(
          SOSBeaconData(
            id: 'BLE-${result.device?.address ?? result.timestampNanos}',
            minerName: 'Nearby SOS user',
            role: 'SOS beacon',
            locationName: 'GPS available after network sync',
            distanceMeters: _roughDistance(result.rssi ?? -100),
            rssi: result.rssi,
            timestamp: DateTime.now(),
            isBleAirTagMesh: true,
          ),
        );
      }
      return;
    }
    if (data.length != 10 || data[0] != (_beaconVersion | 0x80)) {
      return;
    }

    final bytes = ByteData.sublistView(data);
    final token = bytes.getUint32(1, Endian.big);
    final location = _decodeCoarseLocation(data.sublist(5));
    final rssi = result.rssi ?? -100;
    final distance = _roughDistance(rssi);
    final id = 'BLE-${token.toRadixString(16).padLeft(4, '0')}';
    final beacon = SOSBeaconData(
      id: id,
      minerName: 'Nearby SOS user',
      role: 'SOS beacon',
      locationName: location == null
          ? 'GPS unavailable'
          : '${location.$1.toStringAsFixed(5)}, ${location.$2.toStringAsFixed(5)}',
      latitude: location?.$1,
      longitude: location?.$2,
      distanceMeters: distance,
      rssi: rssi,
      timestamp: DateTime.now(),
      isBleAirTagMesh: true,
    );
    _upsertBleBeacon(beacon);
  }

  void _upsertBleBeacon(SOSBeaconData beacon) {
    final index = _bleBeacons.indexWhere((item) => item.id == beacon.id);
    if (index == -1) {
      _bleBeacons.insert(0, beacon);
    } else {
      _bleBeacons[index] = beacon;
    }
    notifyListeners();
  }

  int _roughDistance(int rssi) {
    if (rssi >= -55) return 1;
    if (rssi >= -65) return 3;
    if (rssi >= -75) return 8;
    if (rssi >= -85) return 20;
    return 50;
  }

  Future<void> _saveActiveSignal({String status = 'ACTIVE'}) async {
    final database = _database;
    final signalId = _activeSignalId;
    if (database == null || signalId == null) return;
    await database.saveSosSignal(
      clientUuid: signalId,
      userName: _userName,
      role: _role,
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      status: status,
    );
  }

  Future<void> _syncSignal() async {
    final database = _database;
    final signalId = _activeSignalId;
    if (database == null || signalId == null) return;
    try {
      await _syncService?.sync();
      final pending = await database.getPendingSosSignals();
      _signalSynced = !pending.any((row) => row.clientUuid == signalId);
    } catch (_) {
      _signalSynced = false;
    }
    notifyListeners();
  }

  Future<void> _pollActiveSignals() async {
    final result = await ApiService.instance.fetchActiveSos();
    if (result == null || result['signals'] is! List) return;
    final ownId = _activeSignalId;
    final position = _currentPosition;
    final latest = (result['signals'] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .where((row) => row['client_uuid'] != ownId)
        .map((row) {
          final latitude = (row['latitude'] as num?)?.toDouble();
          final longitude = (row['longitude'] as num?)?.toDouble();
          final distance =
              position != null && latitude != null && longitude != null
              ? Geolocator.distanceBetween(
                  position.latitude,
                  position.longitude,
                  latitude,
                  longitude,
                ).round()
              : null;
          final created = DateTime.tryParse(
            row['client_created_at']?.toString() ?? '',
          );
          return SOSBeaconData(
            id: row['client_uuid'].toString(),
            minerName: (row['user_name'] ?? 'Mine user').toString(),
            role: (row['role'] ?? 'Field user').toString(),
            locationName: latitude == null || longitude == null
                ? 'GPS unavailable'
                : '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}',
            latitude: latitude,
            longitude: longitude,
            distanceMeters: distance,
            rssi: null,
            timestamp: created ?? DateTime.now(),
            isBleAirTagMesh: false,
          );
        })
        .toList();
    _networkBeacons
      ..clear()
      ..addAll(latest);
    notifyListeners();
  }

  Future<void> cancelSOS() async {
    _isSOSActive = false;
    _gpsTimer?.cancel();
    try {
      await _peripheral.stop();
    } catch (_) {}
    await _saveActiveSignal(status: 'CANCELLED');
    await _syncSignal();
    notifyListeners();
  }
}
