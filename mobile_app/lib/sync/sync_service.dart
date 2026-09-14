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
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  Future<SyncResult> sync() async {
    final observations = await database.getPendingObservations();
    final grievances = await database.getPendingGrievances();
    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/sync/push'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'observations': observations.map((item) => {
          'clientUuid': item.clientUuid,
          'category': item.category,
          'location': item.location,
          'trustScore': item.trustScore,
          'clientCreatedAt': DateTime.now().toUtc().toIso8601String(),
        }).toList(),
        'grievances': grievances.map((item) => {
          'clientUuid': item.clientUuid,
          'isAnonymous': item.isAnonymous,
          'lang': item.lang,
          'rawText': item.rawText,
          'createdAt': item.createdAt.toUtc().toIso8601String(),
        }).toList(),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Sync failed (${response.statusCode})');
    }
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final accepted = payload['accepted'] as Map<String, dynamic>;
    for (final item in (accepted['observations'] as List<dynamic>? ?? const [])) {
      await database.markObservationSynced(item['client_uuid'] as String);
    }
    for (final item in (accepted['grievances'] as List<dynamic>? ?? const [])) {
      await database.markGrievanceSynced(item['client_uuid'] as String);
    }
    return SyncResult(
      pushed: (accepted['observations'] as List<dynamic>? ?? const []).length +
          (accepted['grievances'] as List<dynamic>? ?? const []).length,
      serverTime: DateTime.parse(payload['serverTime'] as String),
    );
  }
}
