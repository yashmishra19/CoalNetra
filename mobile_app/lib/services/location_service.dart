import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';

/// LocationService — captures GPS every 2 minutes.
/// Works above ground (live GPS) and underground (last known position).
/// Stores each ping in the local Drift DB for offline-first sync.
class LocationService {
  final AppDatabase _db;
  final String _role;   // 'sirdar' | 'worker' | 'contractor'
  final String _userId; // e.g. 'field_officer_01'

  Timer? _timer;
  Position? _lastKnownPosition;
  bool _running = false;

  LocationService({
    required AppDatabase db,
    required String role,
    required String userId,
  })  : _db = db,
        _role = role,
        _userId = userId;

  /// Start pinging every 2 minutes
  Future<void> start() async {
    if (_running) return;
    _running = true;

    // Request permissions upfront
    await _requestPermissions();

    // Immediately take first ping on start
    await _captureAndStore();

    // Then every 2 minutes
    _timer = Timer.periodic(const Duration(minutes: 2), (_) async {
      await _captureAndStore();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  Future<void> _requestPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
    } catch (_) {}
  }

  Future<void> _captureAndStore() async {
    double? lat;
    double? lng;
    double? accuracy;
    String confidence = locConfidenceLastKnown;

    try {
      // Attempt live GPS fix — 4 second timeout (3G-friendly)
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.balanced,
          timeLimit: Duration(seconds: 4),
        ),
      );
      lat = position.latitude;
      lng = position.longitude;
      accuracy = position.accuracy;
      confidence = locConfidenceLive;
      _lastKnownPosition = position;
    } catch (_) {
      // Underground / no GPS — fall back to last known
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          lat = lastPos.latitude;
          lng = lastPos.longitude;
          accuracy = lastPos.accuracy;
          _lastKnownPosition = lastPos;
        } else if (_lastKnownPosition != null) {
          lat = _lastKnownPosition!.latitude;
          lng = _lastKnownPosition!.longitude;
          accuracy = _lastKnownPosition!.accuracy;
        }
      } catch (_) {}
    }

    // Always store a ping — even if lat/lng is null (marks the person as active)
    if (lat != null && lng != null) {
      try {
        await _db.addLocationPing(LocationPingsCompanion(
          clientUuid: drift.Value(const Uuid().v4()),
          reportedBy: drift.Value(_userId),
          role: drift.Value(_role),
          lat: drift.Value(lat),
          lng: drift.Value(lng),
          accuracy: drift.Value(accuracy),
          locationConfidence: drift.Value(confidence),
          capturedAt: drift.Value(DateTime.now().toUtc()),
          syncStatus: const drift.Value(0),
        ));
      } catch (_) {
        // DB error — silently skip this ping, next one will retry
      }
    }
  }

  /// Get the latest position snapshot for immediate use (e.g. SOS)
  Future<({double? lat, double? lng, String confidence})> getCurrentSnapshot() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.balanced,
          timeLimit: Duration(seconds: 3),
        ),
      );
      _lastKnownPosition = position;
      return (lat: position.latitude, lng: position.longitude, confidence: locConfidenceLive);
    } catch (_) {
      final lastPos = await Geolocator.getLastKnownPosition() ?? _lastKnownPosition;
      if (lastPos != null) {
        return (lat: lastPos.latitude, lng: lastPos.longitude, confidence: locConfidenceLastKnown);
      }
      return (lat: null, lng: null, confidence: 'unknown');
    }
  }
}
