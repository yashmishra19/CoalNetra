import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import 'location_service.dart';

/// MeshSosService — triggers EMERGENCY SOS via two simultaneous channels:
///   1. Cellular POST to server (works whenever network is available)
///   2. UDP LAN broadcast (works on same WiFi network — useful when same-site
///      devices are on local WiFi but NOT on mobile data, e.g. underground
///      WiFi access points or even a shared hotspot)
///
/// On emulator: UDP goes to 255.255.255.255 on port 45678 — two emulators
/// on the same host machine share the LAN and can receive each other's UDP.
/// On physical device: same UDP broadcast + cellular fallback.
///
/// A receiving device running the app that has cellular will automatically
/// relay the received SOS to the server (relay logic is in listenForPeerSos).
class MeshSosService {
  final AppDatabase _db;
  final LocationService _locationService;
  final String _userId;
  final String _role;
  final String _userName;

  static const _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );
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

  /// Call this once on app start to listen for peer SOS signals
  Future<void> startListening() async {
    if (_isListening) return;
    try {
      _udpSocket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        _udpPort,
        reuseAddress: true,
        reusePort: false,
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
              // Received a peer SOS — relay it to server via cellular
              await _relayPeerSos(msg);
            }
          } catch (_) {}
        }
      });
    } catch (e) {
      // UDP socket failed (some emulators restrict this) — silently degrade
      _isListening = false;
    }
  }

  void stopListening() {
    _udpSocket?.close();
    _udpSocket = null;
    _isListening = false;
  }

  /// Main entry point: call this when EMERGENCY button is tapped
  /// Returns a [SosResult] with channels used and whether server confirmed
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

    // ── Step 1: Save SOS locally (so it survives if both channels fail)
    await _db.addSosEvent(SosEventsCompanion(
      clientUuid: drift.Value(uuid),
      triggeredBy: drift.Value(_userId),
      role: drift.Value(_role),
      lat: drift.Value(snap.lat),
      lng: drift.Value(snap.lng),
      locationConfidence: drift.Value(snap.confidence),
      sentViaChannel: const drift.Value('cellular'), // will update after send
      triggeredAt: drift.Value(now),
      syncStatus: const drift.Value(0),
    ));

    bool sentViaCellular = false;
    bool sentViaUdp = false;

    // ── Step 2: Try cellular POST (fastest if network available)
    final cellularFuture = _postSosToServer(payload, uuid);

    // ── Step 3: Simultaneously broadcast via UDP (works on local WiFi/hotspot)
    final udpFuture = _broadcastUdpSos(payload);

    // Run both in parallel — don't wait for either to finish before the other
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

    // Update the local SOS record with actual channels used
    try {
      await (_db.update(_db.sosEvents)
            ..where((t) => t.clientUuid.equals(uuid)))
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
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/sync/push'),
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
      socket.send(data, InternetAddress('255.255.255.255'), _udpPort);
      socket.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Relay a peer's SOS (received via UDP) to the server
  Future<void> _relayPeerSos(Map<String, dynamic> msg) async {
    try {
      final relayPayload = {
        ...msg,
        'meshRelayedBy': _userId,
      };
      await http.post(
        Uri.parse('$_apiBaseUrl/api/sync/push'),
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
