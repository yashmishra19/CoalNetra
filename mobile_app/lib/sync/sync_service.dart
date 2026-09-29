import 'dart:convert';
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
  bool _syncInProgress = false;
  int _failureCount = 0;
  DateTime? _retryAfter;
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3001',
  );

  Future<SyncResult> sync({bool force = false}) async {
    if (force) _retryAfter = null;
    final retryAfter = _retryAfter;
    if (retryAfter != null && DateTime.now().isBefore(retryAfter)) {
      return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
    }
    if (_syncInProgress) {
      return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
    }

    _syncInProgress = true;
    try {
      final result = await _syncPendingRecords();
      _failureCount = 0;
      _retryAfter = null;
      return result;
    } catch (_) {
      _failureCount++;
      final delaySeconds = _failureCount >= 7
          ? 900
          : 15 * (1 << (_failureCount - 1));
      _retryAfter = DateTime.now().add(Duration(seconds: delaySeconds));
      rethrow;
    } finally {
      _syncInProgress = false;
    }
  }

  Future<SyncResult> _syncPendingRecords() async {
    final observations = await database.getPendingObservations();
    final grievances = await database.getPendingGrievances();
    final obligations = await database.getPendingObligationUpdates();
    final sosSignals = await database.getPendingSosSignals();
    if (observations.isEmpty &&
        grievances.isEmpty &&
        obligations.isEmpty &&
        sosSignals.isEmpty) {
      return SyncResult(pushed: 0, serverTime: DateTime.now().toUtc());
    }

    final response = await http
        .post(
          Uri.parse('$apiBaseUrl/api/sync/push'),
          headers: {'content-type': 'application/json'},
          body: jsonEncode({
            'observations': observations
                .map(
                  (item) => {
                    'clientUuid': item.clientUuid,
                    'category': item.category,
                    'severity': item.severity,
                    'description': item.description,
                    'location': item.location,
                    'trustScore': item.trustScore,
                    'clientCreatedAt': item.createdAt.toUtc().toIso8601String(),
                  },
                )
                .toList(),
            'obligations': obligations
                .map(
                  (item) => {
                    'id': item.remoteId,
                    'status': item.status,
                    'dueDate': item.dueDate.toUtc().toIso8601String(),
                  },
                )
                .toList(),
            'grievances': grievances
                .map(
                  (item) => {
                    'clientUuid': item.clientUuid,
                    'isAnonymous': item.isAnonymous,
                    'lang': item.lang,
                    'rawText': item.rawText,
                    'createdAt': item.createdAt.toUtc().toIso8601String(),
                  },
                )
                .toList(),
            'sosSignals': sosSignals
                .map(
                  (item) => {
                    'clientUuid': item.clientUuid,
                    'userName': item.userName,
                    'role': item.role,
                    'latitude': item.latitude,
                    'longitude': item.longitude,
                    'status': item.status,
                    'createdAt': item.createdAt.toUtc().toIso8601String(),
                    'updatedAt': item.updatedAt.toUtc().toIso8601String(),
                  },
                )
                .toList(),
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Sync failed (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final accepted = payload['accepted'] as Map<String, dynamic>;
    for (final item
        in (accepted['observations'] as List<dynamic>? ?? const [])) {
      await database.markObservationSynced(item['client_uuid'] as String);
    }
    for (final item in (accepted['grievances'] as List<dynamic>? ?? const [])) {
      await database.markGrievanceSynced(item['client_uuid'] as String);
    }
    for (final item
        in (accepted['obligations'] as List<dynamic>? ?? const [])) {
      await database.markObligationSynced(item['id'] as String);
    }
    for (final item in (accepted['sosSignals'] as List<dynamic>? ?? const [])) {
      await database.markSosSignalSynced(item['client_uuid'] as String);
    }
    return SyncResult(
      pushed:
          (accepted['observations'] as List<dynamic>? ?? const []).length +
          (accepted['grievances'] as List<dynamic>? ?? const []).length +
          (accepted['obligations'] as List<dynamic>? ?? const []).length +
          (accepted['sosSignals'] as List<dynamic>? ?? const []).length,
      serverTime: DateTime.parse(payload['serverTime'] as String),
    );
  }
}
