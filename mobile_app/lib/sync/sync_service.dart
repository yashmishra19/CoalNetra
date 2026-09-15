import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../database/database.dart';

class SyncResult {
  final int pushed;
  final DateTime serverTime;

  const SyncResult({required this.pushed, required this.serverTime});
}

class SyncService {
  SyncService(this.database);

  final AppDatabase database;
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  // Prevents concurrent sync attempts
  bool _isSyncing = false;

  Future<SyncResult> sync() async {
    if (_isSyncing) {
      return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
    }

    // Check network first — don't even attempt on no connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
    }

    _isSyncing = true;
    try {
      final result = await _syncWithRetry();
      _isSyncing = false;
      return result;
    } catch (e) {
      _isSyncing = false;
      rethrow;
    }
  }

  /// Exponential backoff: tries 3 times — immediately, after 5s, after 15s
  Future<SyncResult> _syncWithRetry() async {
    const delays = [Duration.zero, Duration(seconds: 5), Duration(seconds: 15)];
    Exception? lastError;

    for (int attempt = 0; attempt < delays.length; attempt++) {
      if (attempt > 0) {
        await Future.delayed(delays[attempt]);
        // Re-check connectivity before retry
        final conn = await Connectivity().checkConnectivity();
        if (conn.contains(ConnectivityResult.none)) {
          throw Exception('Network unavailable after retry');
        }
      }
      try {
        return await _doSync();
      } on Exception catch (e) {
        lastError = e;
        // Only retry on network errors, not on DB errors
      }
    }
    throw lastError ?? Exception('Sync failed after 3 attempts');
  }

  Future<SyncResult> _doSync() async {
    final observations = await database.getPendingObservations();
    final grievances = await database.getPendingGrievances();
    final locationPings = await database.getPendingLocationPings();
    final sosEvents = await database.getPendingSosEvents();

    final bool hasData = observations.isNotEmpty ||
        grievances.isNotEmpty ||
        locationPings.isNotEmpty ||
        sosEvents.isNotEmpty;

    if (!hasData) {
      return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
    }

    // Build payload — chunk large observation/grievance lists to keep
    // request size small on 3G (each chunk max 20 records)
    final obsChunks = _chunk(observations, 20);
    final grvChunks = _chunk(grievances, 20);
    // Location pings and SOS are already limited by DB queries (5 and all pending)

    int totalMarked = 0;
    DateTime serverTime = DateTime.now().toUtc();

    // Send location pings + SOS in first request
    if (locationPings.isNotEmpty || sosEvents.isNotEmpty) {
      final res = await _post({
        'observations': [],
        'grievances': [],
        'locationPings': locationPings.map((p) => {
          'clientUuid': p.clientUuid,
          'role': p.role,
          'reportedBy': p.reportedBy,
          'lat': p.lat,
          'lng': p.lng,
          'accuracy': p.accuracy,
          'locationConfidence': p.locationConfidence,
          'capturedAt': p.capturedAt.toUtc().toIso8601String(),
        }).toList(),
        'sosEvents': sosEvents.map((s) => {
          'clientUuid': s.clientUuid,
          'triggeredBy': s.triggeredBy,
          'role': s.role,
          'lat': s.lat,
          'lng': s.lng,
          'locationConfidence': s.locationConfidence,
          'sentViaChannel': s.sentViaChannel,
          'meshRelayedBy': s.meshRelayedBy,
          'triggeredAt': s.triggeredAt.toUtc().toIso8601String(),
        }).toList(),
      });

      final accepted = res['accepted'] as Map<String, dynamic>;
      serverTime = DateTime.parse(res['serverTime'] as String);

      for (final item in (accepted['locationPings'] as List<dynamic>? ?? [])) {
        await database.markLocationPingSynced(item['client_uuid'] as String);
        totalMarked++;
      }
      for (final item in (accepted['sosEvents'] as List<dynamic>? ?? [])) {
        await database.markSosEventSynced(item['client_uuid'] as String);
        totalMarked++;
      }
    }

    // Send observations in chunks
    final allObsChunks = obsChunks.isEmpty ? [[]] : obsChunks;
    final allGrvChunks = grvChunks.isEmpty ? [[]] : grvChunks;

    // Iterate over the larger of the two chunk lists
    final maxChunks = [allObsChunks.length, allGrvChunks.length].reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < maxChunks; i++) {
      final obsSlice = i < allObsChunks.length ? allObsChunks[i] : [];
      final grvSlice = i < allGrvChunks.length ? allGrvChunks[i] : [];

      if (obsSlice.isEmpty && grvSlice.isEmpty) continue;

      final res = await _post({
        'observations': obsSlice.map((item) => {
          'clientUuid': item.clientUuid,
          'category': item.category,
          'location': item.location,
          'trustScore': item.trustScore,
          'severity': 'MEDIUM',
          'description': item.category,
          'clientCreatedAt': DateTime.now().toUtc().toIso8601String(),
        }).toList(),
        'grievances': grvSlice.map((item) => {
          'clientUuid': item.clientUuid,
          'isAnonymous': item.isAnonymous,
          'lang': item.lang,
          'rawText': item.rawText,
          'createdAt': item.createdAt.toUtc().toIso8601String(),
        }).toList(),
        'locationPings': [],
        'sosEvents': [],
      });

      final accepted = res['accepted'] as Map<String, dynamic>;
      serverTime = DateTime.parse(res['serverTime'] as String);

      for (final item in (accepted['observations'] as List<dynamic>? ?? [])) {
        await database.markObservationSynced(item['client_uuid'] as String);
        totalMarked++;
      }
      for (final item in (accepted['grievances'] as List<dynamic>? ?? [])) {
        await database.markGrievanceSynced(item['client_uuid'] as String);
        totalMarked++;
      }
    }

    return SyncResult(pushed: totalMarked, serverTime: serverTime);
  }

  Future<Map<String, dynamic>> _post(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/sync/push'),
      headers: {
        'content-type': 'application/json',
        'connection': 'keep-alive',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Sync failed (${response.statusCode}): ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<List<T>> _chunk<T>(List<T> list, int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < list.length; i += size) {
      chunks.add(list.sublist(i, i + size > list.length ? list.length : i + size));
    }
    return chunks;
  }
}
