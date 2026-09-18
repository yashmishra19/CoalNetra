import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:wifi_iot/wifi_iot.dart';

import '../database/database.dart';
import '../sync/sync_service.dart';
import 'location_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MeshSosService  — Multi-channel SOS for underground mine workers
//
// Channels used (in parallel on every SOS trigger):
//  1. UDP LAN broadcast  — Wi-Fi / hotspot, no internet needed
//  2. Google Nearby Connections (BT + Wi-Fi Direct) — no router needed
//  3. HTTP cellular  — when internet is available
//
// On SOS press: automatically requests WiFi + BT to be enabled.
// ─────────────────────────────────────────────────────────────────────────────

class MeshSosService {
  final AppDatabase _db;
  final LocationService _locationService;
  final String _userId;
  final String _role;
  final String _userName;

  static const int _udpPort = 45678;
  static const String _sosChannel = 'COALNETRA_SOS_V1';
  static const String _nearbyServiceId = 'com.coalnetra.sos';

  RawDatagramSocket? _udpSocket;
  bool _isListening = false;
  bool _nearbyAdvertising = false;
  bool _nearbyDiscovering = false;
  final Set<String> _connectedEndpoints = {};

  final Nearby _nearby = Nearby();

  MeshSosService({
    required AppDatabase db,
    required LocationService locationService,
    required String userId,
    required String role,
    required String userName,
  })  : _db = db,
        _locationService = locationService,
        _userId = userId,
        _role = role,
        _userName = userName;

  // ── PUBLIC: Start all listeners ──────────────────────────────────────────

  Future<void> startListening() async {
    if (_isListening) return;
    _isListening = true;

    // Run UDP and Nearby listeners in parallel (failures are swallowed)
    await Future.wait([
      _startUdpListener(),
      _startNearbyListener(),
    ]);
  }

  void stopListening() {
    _udpSocket?.close();
    _udpSocket = null;
    if (_nearbyAdvertising || _nearbyDiscovering) {
      try {
        _nearby.stopAdvertising();
        _nearby.stopDiscovery();
      } catch (_) {}
    }
    _nearbyAdvertising = false;
    _nearbyDiscovering = false;
    _connectedEndpoints.clear();
    _isListening = false;
  }

  // ── PUBLIC: Trigger SOS ──────────────────────────────────────────────────

  /// Main entry point: call this when the EMERGENCY button is tapped.
  /// 1. Auto-enables WiFi + Bluetooth.
  /// 2. Saves event locally.
  /// 3. Broadcasts simultaneously over UDP LAN + Nearby (BT/WiFi-Direct) + Cellular HTTP.
  Future<SosResult> triggerSos() async {
    final uuid = const Uuid().v4();
    final now = DateTime.now().toUtc();

    // ── Step 1: Auto-enable connectivity radios
    await _autoEnableRadios();

    // ── Step 2: Get best available location
    final snap = await _locationService.getCurrentSnapshot();

    final payload = {
      'channel': _sosChannel,
      'clientUuid': uuid,
      'triggeredBy': _userId,
      'role': _role,
      'userName': _userName,
      'lat': snap.lat,
      'lng': snap.lng,
      'locationConfidence': snap.confidence,
      'triggeredAt': now.toIso8601String(),
    };

    // ── Step 3: Save SOS locally (always succeeds offline)
    await _db.addSosEvent(SosEventsCompanion(
      clientUuid: drift.Value(uuid),
      triggeredBy: drift.Value(_userId),
      role: drift.Value(_role),
      userName: drift.Value(_userName),
      lat: drift.Value(snap.lat),
      lng: drift.Value(snap.lng),
      locationConfidence: drift.Value(snap.confidence),
      sentViaChannel: const drift.Value('stored_locally'),
      triggeredAt: drift.Value(now),
      syncStatus: const drift.Value(0),
    ));

    // ── Step 4: Fire all channels in parallel
    bool sentViaCellular = false;
    bool sentViaUdp = false;
    bool sentViaNearby = false;

    final results = await Future.wait([
      _postSosToServer(payload, uuid).catchError((_) => false),
      _broadcastUdpSos(payload).catchError((_) => false),
      _broadcastNearbySos(payload).catchError((_) => false),
    ]);
    sentViaCellular = results[0];
    sentViaUdp = results[1];
    sentViaNearby = results[2];

    final channelStr = [
      if (sentViaCellular) 'cellular',
      if (sentViaUdp) 'udp_lan',
      if (sentViaNearby) 'nearby_bt',
    ].join('+').ifEmpty('stored_locally');

    try {
      await (_db.update(_db.sosEvents)..where((t) => t.clientUuid.equals(uuid)))
          .write(SosEventsCompanion(
        sentViaChannel: drift.Value(channelStr),
        syncStatus: drift.Value(sentViaCellular ? 1 : 0),
      ));
    } catch (_) {}

    return SosResult(
      uuid: uuid,
      sentViaCellular: sentViaCellular,
      sentViaUdpLan: sentViaUdp,
      sentViaNearby: sentViaNearby,
      locationConfidence: snap.confidence,
      lat: snap.lat,
      lng: snap.lng,
    );
  }

  // ── PRIVATE: Auto-enable radios ─────────────────────────────────────────

  Future<void> _autoEnableRadios() async {
    // Enable WiFi
    try {
      final wifiEnabled = await WiFiForIoTPlugin.isEnabled();
      if (!wifiEnabled) {
        await WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: false);
      }
    } catch (_) {}

    // Enable Bluetooth (request via permission which triggers system dialog)
    try {
      if (await Permission.bluetooth.isDenied) {
        await Permission.bluetooth.request();
      }
      if (await Permission.bluetoothConnect.isDenied) {
        await Permission.bluetoothConnect.request();
      }
    } catch (_) {}
  }

  // ── PRIVATE: UDP listener ────────────────────────────────────────────────

  Future<void> _startUdpListener() async {
    try {
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _udpPort,
        reuseAddress: true,
        reusePort: true,   // fixed: was false → caused bind failures on Android
      );
      _udpSocket!.broadcastEnabled = true;

      _udpSocket!.listen((event) async {
        if (event == RawSocketEvent.read) {
          final datagram = _udpSocket!.receive();
          if (datagram == null) return;
          try {
            final msg = jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
            // KEY FIX: filter uses triggeredBy != _userId
            // Before this fix both devices shared userId 'field_officer_01' so this
            // evaluated to false and the SOS was silently dropped.
            if (msg['channel'] == _sosChannel && msg['triggeredBy'] != _userId) {
              await _handlePeerSosReceived(msg, 'udp_lan_relayed');
            }
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint('[SOS-UDP] Listener bind failed: $e');
    }
  }

  // ── PRIVATE: Google Nearby Connections (BT + WiFi-Direct) listener ───────

  Future<void> _startNearbyListener() async {
    try {
      // Request all required permissions for Nearby
      final permissions = [
        Permission.location,
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ];
      await permissions.request();

      // Advertise so other devices can find us
      await _nearby.startAdvertising(
        _userId,
        Strategy.P2P_CLUSTER,
        onConnectionInitiated: (endpointId, info) async {
          // Auto-accept all connections from same app
          await _nearby.acceptConnection(
            endpointId,
            onPayLoadRecieved: (endpointId, payload) async {
              if (payload.type == PayloadType.BYTES && payload.bytes != null) {
                try {
                  final msg = jsonDecode(utf8.decode(payload.bytes!)) as Map<String, dynamic>;
                  if (msg['channel'] == _sosChannel && msg['triggeredBy'] != _userId) {
                    await _handlePeerSosReceived(msg, 'nearby_bt');
                  }
                } catch (_) {}
              }
            },
            onPayloadTransferUpdate: (endpointId, _) {},
          );
        },
        onConnectionResult: (endpointId, status) {
          if (status == Status.CONNECTED) {
            _connectedEndpoints.add(endpointId);
          } else {
            _connectedEndpoints.remove(endpointId);
          }
        },
        onDisconnected: (endpointId) => _connectedEndpoints.remove(endpointId),
        serviceId: _nearbyServiceId,
      );
      _nearbyAdvertising = true;

      // Also discover other devices
      await _nearby.startDiscovery(
        _userId,
        Strategy.P2P_CLUSTER,
        onEndpointFound: (endpointId, info, serviceId) async {
          // Auto-request connection to any CoalNetra peer found
          await _nearby.requestConnection(
            _userId,
            endpointId,
            onConnectionInitiated: (endpointId, info) async {
              await _nearby.acceptConnection(
                endpointId,
                onPayLoadRecieved: (endpointId, payload) async {
                  if (payload.type == PayloadType.BYTES && payload.bytes != null) {
                    try {
                      final msg = jsonDecode(utf8.decode(payload.bytes!)) as Map<String, dynamic>;
                      if (msg['channel'] == _sosChannel && msg['triggeredBy'] != _userId) {
                        await _handlePeerSosReceived(msg, 'nearby_bt');
                      }
                    } catch (_) {}
                  }
                },
                onPayloadTransferUpdate: (endpointId, _) {},
              );
            },
            onConnectionResult: (endpointId, status) {
              if (status == Status.CONNECTED) {
                _connectedEndpoints.add(endpointId);
              } else {
                _connectedEndpoints.remove(endpointId);
              }
            },
            onDisconnected: (endpointId) => _connectedEndpoints.remove(endpointId),
          );
        },
        onEndpointLost: (endpointId) {},
        serviceId: _nearbyServiceId,
      );
      _nearbyDiscovering = true;
    } catch (e) {
      debugPrint('[SOS-Nearby] Failed to start: $e');
    }
  }

  // ── PRIVATE: SOS broadcast channels ─────────────────────────────────────

  Future<bool> _broadcastUdpSos(Map<String, dynamic> payload) async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      final data = utf8.encode(jsonEncode(payload));

      // Broadcast across all common subnet ranges
      for (final addr in [
        '255.255.255.255',  // global
        '192.168.43.255',   // Android hotspot
        '192.168.1.255',    // home router
        '192.168.0.255',    // home router alt
        '10.0.2.255',       // emulator
        '172.16.255.255',   // corporate
      ]) {
        try { socket.send(data, InternetAddress(addr), _udpPort); } catch (_) {}
      }
      socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _broadcastNearbySos(Map<String, dynamic> payload) async {
    if (_connectedEndpoints.isEmpty) return false;
    try {
      final data = utf8.encode(jsonEncode(payload));
      // Send to every connected Nearby peer individually
      await Future.wait(
        _connectedEndpoints.map((id) =>
          _nearby.sendBytesPayload(id, data).catchError((_) {})
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _postSosToServer(Map<String, dynamic> payload, String uuid) async {
    try {
      final baseUrl = SyncService.effectiveApiBaseUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/sync/push'),
        headers: {
          'content-type': 'application/json',
          'connection': 'keep-alive',
        },
        body: jsonEncode({
          'sosEvents': [payload],
          'observations': [],
          'grievances': [],
          'locationPings': [],
        }),
      ).timeout(const Duration(seconds: 8));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  // ── PRIVATE: Handle received peer SOS ───────────────────────────────────

  Future<void> _handlePeerSosReceived(Map<String, dynamic> msg, String channel) async {
    final uuid = msg['clientUuid'] as String? ?? const Uuid().v4();
    final triggeredBy = msg['triggeredBy'] as String? ?? 'peer_worker';
    final role = msg['role'] as String? ?? 'worker';
    final userName = msg['userName'] as String? ?? 'Mine Worker';
    final lat = (msg['lat'] as num?)?.toDouble();
    final lng = (msg['lng'] as num?)?.toDouble();
    final confidence = msg['locationConfidence'] as String? ?? 'unknown';
    final triggeredAtStr = msg['triggeredAt'] as String?;
    final triggeredAt = triggeredAtStr != null
        ? DateTime.tryParse(triggeredAtStr) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    try {
      await _db.addSosEvent(SosEventsCompanion(
        clientUuid: drift.Value(uuid),
        triggeredBy: drift.Value(triggeredBy),
        role: drift.Value(role),
        userName: drift.Value(userName),
        lat: drift.Value(lat),
        lng: drift.Value(lng),
        locationConfidence: drift.Value(confidence),
        sentViaChannel: drift.Value(channel),
        triggeredAt: drift.Value(triggeredAt),
        syncStatus: const drift.Value(1),
      ));
    } catch (_) {}

    // Relay to backend so command center web app sees it
    await _relayPeerSos(msg);
  }

  Future<void> _relayPeerSos(Map<String, dynamic> msg) async {
    try {
      final baseUrl = SyncService.effectiveApiBaseUrl;
      final relayPayload = {
        ...msg,
        'meshRelayedBy': _userId,
      };
      await http.post(
        Uri.parse('$baseUrl/api/sync/push'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'sosEvents': [relayPayload],
          'observations': [],
          'grievances': [],
          'locationPings': [],
        }),
      ).timeout(const Duration(seconds: 8));
    } catch (_) {}
  }
}

// ── Result ───────────────────────────────────────────────────────────────────

class SosResult {
  final String uuid;
  final bool sentViaCellular;
  final bool sentViaUdpLan;
  final bool sentViaNearby;
  final String locationConfidence;
  final double? lat;
  final double? lng;

  const SosResult({
    required this.uuid,
    required this.sentViaCellular,
    required this.sentViaUdpLan,
    required this.sentViaNearby,
    required this.locationConfidence,
    this.lat,
    this.lng,
  });

  bool get anySent => sentViaCellular || sentViaUdpLan || sentViaNearby;

  String get channelSummary {
    final parts = <String>[];
    if (sentViaCellular) parts.add('Server');
    if (sentViaUdpLan) parts.add('LAN mesh');
    if (sentViaNearby) parts.add('BT/WiFi-Direct');
    if (parts.isEmpty) return 'Stored locally — syncs when online';
    return parts.join(' + ');
  }
}

extension _StringX on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
