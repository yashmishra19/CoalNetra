import 'dart:convert';
import 'package:http/http.dart' as http;

/// Central API service that talks to the Express/Supabase backend.
/// All endpoints return `null` on failure so the UI can show a
/// graceful error state instead of crashing.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Default to the Android emulator loopback; override via --dart-define
  static const String _base = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:5000',
  );

  static const String _mineId = '55555555-5555-5555-5555-555555555501';
  static const String _regionId = '11111111-1111-1111-1111-111111111101';

  // ─── helpers ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> _get(String path) async {
    try {
      final uri = Uri.parse('$_base$path');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, dynamic>?> _post(
      String path, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .post(uri,
              headers: {'content-type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // ─── Compliance / Obligations ─────────────────────────────────────────────

  /// Returns {obligations: [...], summary: {...}}
  Future<Map<String, dynamic>?> fetchObligations({String? status}) async {
    final q = status != null ? '?status=$status' : '';
    return _get('/api/obligations?mineId=$_mineId$q');
  }

  // ─── CAPAs ────────────────────────────────────────────────────────────────

  /// Returns {capas: [...], summary: {...}}
  Future<Map<String, dynamic>?> fetchCapas({
    String? status,
    String? severity,
  }) async {
    final q = [
      'mineId=$_mineId',
      if (status != null) 'status=$status',
      if (severity != null) 'severity=$severity',
    ].join('&');
    return _get('/api/capas?$q');
  }

  // ─── Observations ─────────────────────────────────────────────────────────

  /// Returns {observations: [...], count: N}
  Future<Map<String, dynamic>?> fetchObservations({int limit = 50}) async {
    return _get('/api/observations?mineId=$_mineId&limit=$limit');
  }

  // ─── Incidents ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchIncidents() async {
    return _get('/api/incidents?mineId=$_mineId');
  }

  // ─── Directions ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchDirections() async {
    return _get('/api/directions?regionId=$_regionId');
  }

  // ─── Mine & Risk Score ────────────────────────────────────────────────────

  /// Returns {mine: {...}, sections: [...], riskScore: {...}}
  Future<Map<String, dynamic>?> fetchMineData() async {
    return _get('/api/mine?mineId=$_mineId');
  }

  // ─── Today / Dashboard ───────────────────────────────────────────────────

  Future<Map<String, dynamic>?> fetchToday() async {
    return _get('/api/today?mineId=$_mineId');
  }

  Future<Map<String, dynamic>?> fetchActiveSos() async {
    return _get('/api/sync/sos/active?mineId=$_mineId');
  }

  // ─── Sync: push observations + grievances ────────────────────────────────

  Future<Map<String, dynamic>?> syncPush({
    required List<Map<String, dynamic>> observations,
    required List<Map<String, dynamic>> grievances,
  }) async {
    return _post('/api/sync/push', {
      'observations': observations,
      'grievances': grievances,
    });
  }

  // ─── Health check ────────────────────────────────────────────────────────

  Future<bool> isServerReachable() async {
    final result = await _get('/api/health');
    return result != null;
  }
}
