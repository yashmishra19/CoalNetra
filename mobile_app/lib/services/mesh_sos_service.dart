import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'location_service.dart';
import '../sync/sync_service.dart';

class MeshSosService {
  final AppDatabase _db;
  final LocationService _locationService;
  final String _userId;
  final String _role;
  final String _userName;

  static const int _udpPort = 45678;
  static const String _sosChannel = 'COALNETRA_SOS_V1';

  RawDatagramSocket? _udpSocket;
  bool _isListening = false;

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

  /// Listen for peer SOS signals over UDP LAN (compatible with Android 10+ sockets)
  Future<void> startListening() async {
    if (_isListening) return;
    try {
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _udpPort,
        reuseAddress: true,
      );
      _udpSocket!.broadcastEnabled = true;
      _isListening = true;

      _udpSocket!.listen((event) async {
        if (event == RawSocketEvent.read) {
          final datagram = _udpSocket!.receive();
          if (datagram == null) return;
          try {
            final msg = jsonDecode(utf8.decode(datagram.data)) as Map<String, dynamic>;
            if (msg['channel'] == _sosChannel && msg['triggeredBy'] != _userId) {
              await _handlePeerSosReceived(msg);
            }
          } catch (_) {}
        }
      });
    } catch (e) {
      debugPrint("Primary UDP bind notice: $e");
      try {
        _udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
        _udpSocket!.broadcastEnabled = true;
        _isListening = true;
      } catch (_) {
        _isListening = false;
      }
    }
  }

  void stopListening() {
    _udpSocket?.close();
    _udpSocket = null;
    _isListening = false;
  }

  Future<void> _handlePeerSosReceived(Map<String, dynamic> msg) async {
    final uuid = msg['clientUuid'] as String? ?? const Uuid().v4();
    final triggeredBy = msg['triggeredBy'] as String? ?? 'peer_worker';
    final role = msg['role'] as String? ?? 'worker';
    final userName = msg['userName'] as String? ?? 'Mine Worker';
    final lat = (msg['lat'] as num?)?.toDouble();
    final lng = (msg['lng'] as num?)?.toDouble();
    final confidence = msg['locationConfidence'] as String? ?? 'unknown';
    final triggeredAtStr = msg['triggeredAt'] as String?;
    final triggeredAt = triggeredAtStr != null ? DateTime.tryParse(triggeredAtStr) ?? DateTime.now().toUtc() : DateTime.now().toUtc();

    try {
      await _db.addSosEvent(SosEventsCompanion(
        clientUuid: drift.Value(uuid),
        triggeredBy: drift.Value(triggeredBy),
        role: drift.Value(role),
        userName: drift.Value(userName),
        lat: drift.Value(lat),
        lng: drift.Value(lng),
        locationConfidence: drift.Value(confidence),
        sentViaChannel: const drift.Value('udp_lan_relayed'),
        triggeredAt: drift.Value(triggeredAt),
        syncStatus: const drift.Value(1),
      ));
    } catch (_) {}

    // Relay to backend
    await _relayPeerSos(msg);
  }

  /// Main entry point: call this when EMERGENCY button is tapped
  Future<SosResult> triggerSos() async {
    final uuid = const Uuid().v4();
    final now = DateTime.now().toUtc();
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

    // ── Save SOS locally
    await _db.addSosEvent(SosEventsCompanion(
      clientUuid: drift.Value(uuid),
      triggeredBy: drift.Value(_userId),
      role: drift.Value(_role),
      userName: drift.Value(_userName),
      lat: drift.Value(snap.lat),
      lng: drift.Value(snap.lng),
      locationConfidence: drift.Value(snap.confidence),
      sentViaChannel: const drift.Value('cellular'),
      triggeredAt: drift.Value(now),
      syncStatus: const drift.Value(0),
    ));

    bool sentViaCellular = false;
    bool sentViaUdp = false;

    // Run parallel sends
    final cellularFuture = _postSosToServer(payload, uuid);
    final udpFuture = _broadcastUdpSos(payload);

    final results = await Future.wait([
      cellularFuture.then((v) { sentViaCellular = v; return v; }).catchError((_) => false),
      udpFuture.then((v) { sentViaUdp = v; return v; }).catchError((_) => false),
    ]);
    sentViaCellular = results[0];
    sentViaUdp = results[1];

    final channelStr = [
      if (sentViaCellular) 'cellular',
      if (sentViaUdp) 'udp_lan',
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
      locationConfidence: snap.confidence,
      lat: snap.lat,
      lng: snap.lng,
    );
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

  Future<bool> _broadcastUdpSos(Map<String, dynamic> payload) async {
    try {
      final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
      socket.broadcastEnabled = true;
      final data = utf8.encode(jsonEncode(payload));

      // Broadcast to standard global subnet
      socket.send(data, InternetAddress('255.255.255.255'), _udpPort);
      
      // Broadcast to mobile hotspot and local Wi-Fi subnets
      socket.send(data, InternetAddress('192.168.43.255'), _udpPort);
      socket.send(data, InternetAddress('192.168.1.255'), _udpPort);
      socket.send(data, InternetAddress('192.168.0.255'), _udpPort);
      socket.send(data, InternetAddress('10.0.2.255'), _udpPort);

      socket.close();
      return true;
    } catch (_) {
      return false;
    }
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

class SosResult {
  final String uuid;
  final bool sentViaCellular;
  final bool sentViaUdpLan;
  final String locationConfidence;
  final double? lat;
  final double? lng;

  const SosResult({
    required this.uuid,
    required this.sentViaCellular,
    required this.sentViaUdpLan,
    required this.locationConfidence,
    this.lat,
    this.lng,
  });

  bool get anySent => sentViaCellular || sentViaUdpLan;

  String get channelSummary {
    if (sentViaCellular && sentViaUdpLan) return 'Server + LAN mesh';
    if (sentViaCellular) return 'Server (cellular)';
    if (sentViaUdpLan) return 'LAN mesh (relayed)';
    return 'Stored locally — will sync when online';
  }
}

extension _StringX on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
