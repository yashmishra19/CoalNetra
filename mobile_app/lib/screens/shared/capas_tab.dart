import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

/// Live CAPAs list from Supabase. Supports status filter tabs.
class CapasTab extends StatefulWidget {
  const CapasTab({super.key});

  @override
  State<CapasTab> createState() => _CapasTabState();
}

class _CapasTabState extends State<CapasTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _capas = [];
  Map<String, dynamic> _summary = {};
  bool _loading = true;
  bool _error = false;

  static const _tabs = ['ALL', 'OPEN', 'ESCALATED', 'PENDING_VERIFICATION', 'VERIFIED'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = false; });
    final result = await ApiService.instance.fetchCapas();
    if (mounted) {
      setState(() {
        _loading = false;
        if (result == null) {
          _error = true;
        } else {
          _capas = List<Map<String, dynamic>>.from(result['capas'] as List? ?? []);
          _summary = result['summary'] as Map<String, dynamic>? ?? {};
        }
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final tab = _tabs[_tabController.index];
    if (tab == 'ALL') return _capas;
    return _capas.where((c) => c['status'] == tab).toList();
  }

  Color _severityColor(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'CRITICAL': return AppTheme.redDanger;
      case 'HIGH':     return Colors.deepOrange;
      case 'MEDIUM':   return AppTheme.amberAccent;
      default:         return AppTheme.greenVerified;
    }
  }

  Color _statusColor(String? s) {
    switch ((s ?? '').toUpperCase()) {
      case 'ESCALATED':            return AppTheme.redDanger;
      case 'OPEN':                 return AppTheme.amberAccent;
      case 'PENDING_VERIFICATION': return Colors.purple;
      case 'VERIFIED':             return AppTheme.greenVerified;
      default:                     return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error) return _errorState();

    return Column(
      children: [
        // Summary strip
        Container(
          color: AppTheme.nearBlackCoal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _stat('${_summary['total'] ?? _capas.length}', 'Total', Colors.white),
              _divider(),
              _stat('${_summary['open'] ?? 0}', 'Open', AppTheme.amberAccent),
              _divider(),
              _stat('${_summary['escalated'] ?? 0}', 'Escalated', AppTheme.redDanger),
              _divider(),
              _stat('${_summary['overdue'] ?? 0}', 'Overdue', Colors.deepOrange),
            ],
          ),
        ),

        // Source badge
        Container(
          width: double.infinity,
          color: AppTheme.greenVerified.withAlpha(15),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.greenVerified, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              const Text('Live data · Supabase', style: TextStyle(fontSize: 10, color: AppTheme.greenVerified, fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              GestureDetector(onTap: _load, child: const Icon(Icons.refresh, size: 14, color: AppTheme.greenVerified)),
            ],
          ),
        ),

        // Status tabs
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.amberAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.amberAccent,
          tabs: _tabs.map((t) => Tab(text: t.replaceAll('_', ' '))).toList(),
        ),

        // List
        Expanded(
          child: _filtered.isEmpty
              ? Center(child: Text('No ${_tabs[_tabController.index]} CAPAs',
                  style: const TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) => _buildCard(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> capa) {
    final id = capa['id']?.toString() ?? '';
    final shortId = id.length > 8 ? id.substring(0, 8) : id;
    final title = capa['description'] as String? ??
        capa['violation_type'] as String? ??
        'Corrective Action';
    final severity = capa['severity'] as String? ?? 'MEDIUM';
    final status = capa['status'] as String? ?? 'OPEN';
    final assignedTo = capa['assigned_to_name'] as String? ??
        capa['assigned_to'] as String? ?? '—';
    final dueDate = (capa['due_date'] as String? ?? '').substring(
        0, (capa['due_date'] as String? ?? '').length > 10 ? 10 : (capa['due_date'] as String? ?? '').length);
    final isOverdue = capa['isOverdue'] == true;
    final daysUntilDue = capa['daysUntilDue'] as int?;
    final escalated = status == 'ESCALATED';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _severityColor(severity), width: 4),
          top: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#$shortId',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.amberAccent,
                        fontFamily: 'monospace')),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _severityColor(severity).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(severity,
                      style: TextStyle(
                          fontSize: 9,
                          color: _severityColor(severity),
                          fontWeight: FontWeight.bold)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(status.replaceAll('_', ' '),
                      style: TextStyle(
                          fontSize: 9,
                          color: _statusColor(status),
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 13, color: Colors.grey),
                const SizedBox(width: 4),
                Text(assignedTo,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  dueDate.isNotEmpty ? 'Due: $dueDate' : '—',
                  style: TextStyle(
                      fontSize: 12,
                      color: isOverdue ? AppTheme.redDanger : Colors.grey,
                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
            if (isOverdue || escalated) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  if (isOverdue) ...[
                    const Icon(Icons.warning, size: 12, color: AppTheme.redDanger),
                    const SizedBox(width: 4),
                    Text(
                      'OVERDUE${daysUntilDue != null ? ' by ${daysUntilDue.abs()}d' : ''}',
                      style: const TextStyle(fontSize: 11, color: AppTheme.redDanger, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (escalated) ...[
                    const Icon(Icons.arrow_upward, size: 12, color: AppTheme.redDanger),
                    const SizedBox(width: 4),
                    const Text('Escalated',
                        style: TextStyle(fontSize: 11, color: AppTheme.redDanger)),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 32, color: Colors.white12);

  Widget _errorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('Cannot reach server', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberAccent, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
