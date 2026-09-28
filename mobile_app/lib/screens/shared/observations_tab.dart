import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Offline-First Observations tab that displays live Supabase data when connected,
/// and seamlessly falls back to SQLite local database & cached observations when offline.
class ObservationsTab extends StatefulWidget {
  const ObservationsTab({super.key});

  @override
  State<ObservationsTab> createState() => _ObservationsTabState();
}

class _ObservationsTabState extends State<ObservationsTab> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db != null) {
      final cached = await db.getAllObservations();
      if (!mounted) return;
      if (cached.isNotEmpty) {
        setState(() {
          _items = cached.map(_localItem).toList();
          _loading = false;
          _isLive = false;
        });
      }
    }

    final result = await ApiService.instance.fetchObservations();

    if (!mounted) return;

    if (result != null && result['observations'] is List) {
      final remoteItems = List<Map<String, dynamic>>.from(
        result['observations'] as List,
      );
      if (db != null) await db.cacheRemoteObservations(remoteItems);
      final pending = db == null
          ? <Observation>[]
          : await db.getPendingObservations();
      if (!mounted) return;
      final merged = <String, Map<String, dynamic>>{
        for (final item in remoteItems)
          (item['client_uuid'] ?? item['id']).toString(): item,
        for (final observation in pending)
          observation.clientUuid: _localItem(observation),
      };
      setState(() {
        _items = merged.values.toList();
        _loading = false;
        _isLive = true;
      });
      return;
    }

    // Offline mode: show the device ledger, including already-synced rows.
    List<Map<String, dynamic>> localItems = [];
    if (db != null) {
      try {
        final local = await db.getAllObservations();
        localItems = local.map(_localItem).toList();
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _items = localItems;
      _loading = false;
      _isLive = false;
    });
  }

  Map<String, dynamic> _localItem(Observation observation) => {
    'id': 'LOCAL-${observation.clientUuid.substring(0, 6).toUpperCase()}',
    'client_uuid': observation.clientUuid,
    'category': observation.category,
    'severity': observation.severity,
    'description': observation.description,
    'location': observation.location,
    'status': observation.syncStatus == 2
      ? 'LOCAL DEMO'
      : observation.syncStatus == 1
      ? 'SYNCED'
      : 'PENDING SYNC',
    'client_created_at': observation.createdAt.toIso8601String(),
  };

  Color _categoryColor(String? cat) {
    switch ((cat ?? '').toLowerCase()) {
      case 'safety hazard':
      case 'safety':
        return AppTheme.redDanger;
      case 'environment':
        return AppTheme.greenVerified;
      case 'labour':
        return AppTheme.cobaltBlue;
      case 'equipment':
        return AppTheme.amberAccent;
      default:
        return AppTheme.amberAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Live / Offline Status Header Strip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: _isLive
              ? AppTheme.greenVerified.withOpacity(0.12)
              : AppTheme.amberAccent.withOpacity(0.15),
          child: Row(
            children: [
              Icon(
                _isLive ? Icons.cloud_done : Icons.wifi_off,
                size: 14,
                color: _isLive ? AppTheme.greenVerified : AppTheme.amberAccent,
              ),
              const SizedBox(width: 6),
              Text(
                _isLive
                    ? 'Connected · Live Supabase Data'
                    : 'Offline Mode · Local SQLite Ledger Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _isLive ? Colors.green[800] : Colors.orange[900],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Safety Observations',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.amberAccent),
                onPressed: _load,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _isLive
                      ? AppTheme.greenVerified
                      : AppTheme.amberAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${_items.length} records · ${_isLive ? "Live from Supabase" : "Offline Cache & Local DB"}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
              itemCount: _items.length,
              itemBuilder: (context, i) => _buildCard(_items[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> obs) {
    final cat = obs['category'] as String? ?? 'Safety Hazard';
    final severity = obs['severity'] as String? ?? 'MEDIUM';
    final loc = obs['location'] as String? ?? 'Face Gallery 3A';
    final id =
        obs['id']?.toString() ?? obs['client_uuid']?.toString() ?? 'OBS-2026';
    final date =
        obs['client_created_at'] as String? ??
        obs['server_created_at'] as String? ??
        '';
    final dateStr = date.isNotEmpty
        ? date.substring(0, date.length > 10 ? 10 : date.length)
        : 'Today';
    final status = obs['status'] as String? ?? 'OPEN';
    final color = _categoryColor(cat);
    final severityColor = severity == 'CRITICAL' || severity == 'HIGH'
        ? AppTheme.redDanger
        : severity == 'MEDIUM'
        ? AppTheme.amberAccent
        : AppTheme.greenVerified;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '#${id.length > 12 ? id.substring(0, 12) : id}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.amberAccent,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    if (severity.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: severityColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          severity,
                          style: TextStyle(
                            fontSize: 9,
                            color: severityColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  cat,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        loc,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (dateStr.isNotEmpty)
                      Text(
                        dateStr,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'CLOSED' || status == 'Closed'
                            ? AppTheme.greenVerified.withOpacity(0.15)
                            : AppTheme.amberAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 9,
                          color: status == 'CLOSED' || status == 'Closed'
                              ? AppTheme.greenVerified
                              : AppTheme.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
