import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../services/api_service.dart';
import '../../sync/sync_service.dart';
import '../../theme/app_theme.dart';

class StatutoryComplianceTab extends StatefulWidget {
  const StatutoryComplianceTab({super.key});

  @override
  State<StatutoryComplianceTab> createState() => _StatutoryComplianceTabState();
}

class _StatutoryComplianceTabState extends State<StatutoryComplianceTab> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Safety',
    'Environment',
    'Labour',
    'Equipment',
  ];

  bool _isLoading = true;
  bool _isLive = false;
  bool _loadFailed = false;
  List<_ComplianceRule> _rules = [];

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() {
      _isLoading = true;
    });

    final database = Provider.of<AppDatabase?>(context, listen: false);
    if (database != null) {
      final cached = await database.getCachedObligations();
      if (!mounted) return;
      if (cached.isNotEmpty) {
        setState(() {
          _rules = cached.map(_fromCached).toList();
          _isLoading = false;
          _isLive = false;
        });
      }
    }

    final data = await ApiService.instance.fetchObligations();
    if (!mounted) return;

    if (data != null && data['obligations'] is List) {
      final remote = (data['obligations'] as List)
          .whereType<Map>()
          .map((row) => Map<String, dynamic>.from(row))
          .map(_fromRemote)
          .toList();
      final pendingIds = <String>{};
      if (database != null) {
        final pending = await database.getPendingObligationUpdates();
        pendingIds.addAll(pending.map((row) => row.remoteId));
        final rowsToCache = remote
            .where((rule) => !pendingIds.contains(rule.remoteId))
            .map((rule) => _toCached(rule))
            .toList();
        await database.cacheObligations(rowsToCache);
      }
      final localPending = database == null
          ? <_ComplianceRule>[]
          : (await database.getPendingObligationUpdates())
                .map(_fromCached)
                .toList();
      final localDemo = database == null
          ? <_ComplianceRule>[]
          : (await database.getCachedObligations())
                .where((row) => row.syncStatus == 2)
                .map(_fromCached)
                .toList();
      final merged = <String, _ComplianceRule>{
        for (final rule in remote) rule.remoteId: rule,
        for (final rule in localPending) rule.remoteId: rule,
        for (final rule in localDemo) rule.remoteId: rule,
      }.values.toList();

      setState(() {
        _rules = merged;
        _isLoading = false;
        _isLive = true;
        _loadFailed = false;
      });
    } else {
      setState(() {
        if (_rules.isEmpty) _rules = [];
        _isLoading = false;
        _isLive = false;
        _loadFailed = true;
      });
    }
  }

  _ComplianceRule _fromCached(CachedObligation row) => _ComplianceRule(
    remoteId: row.remoteId,
    id: row.remoteId.substring(0, 8).toUpperCase(),
    title: row.title,
    category: row.category,
    frequency: row.frequency,
    dueDate: row.dueDate,
    officer: row.ownerRole.replaceAll('_', ' '),
    evidence: row.evidenceRequired,
    status: row.status,
    syncPending: row.syncStatus == 0,
    localDemo: row.syncStatus == 2,
  );

  _ComplianceRule _fromRemote(Map<String, dynamic> row) {
    final title = (row['title'] ?? 'Statutory obligation').toString();
    final description = (row['description'] ?? '').toString();
    final text = '$title $description'.toLowerCase();
    final dueDate =
        DateTime.tryParse(row['due_date']?.toString() ?? '') ?? DateTime.now();
    final references = [row['cmr_2017_ref'], row['oshwc_2020_ref']]
        .where((value) => value != null && value.toString().isNotEmpty)
        .join(' · ');
    final remoteId = (row['id'] ?? '').toString();
    return _ComplianceRule(
      remoteId: remoteId,
      id: remoteId.length >= 8
          ? remoteId.substring(0, 8).toUpperCase()
          : 'RULE',
      title: title,
      category: _categoryFor(text),
      frequency: (row['frequency'] ?? 'SCHEDULED').toString(),
      dueDate: dueDate,
      officer: (row['owner_role'] ?? 'MINE_MANAGER').toString().replaceAll(
        '_',
        ' ',
      ),
      evidence: references.isEmpty
          ? 'Evidence requirement not specified'
          : references,
      status: (row['status'] ?? 'PENDING').toString().toUpperCase(),
      syncPending: false,
      localDemo: false,
    );
  }

  CachedObligationsCompanion _toCached(_ComplianceRule rule) =>
      CachedObligationsCompanion(
        remoteId: drift.Value(rule.remoteId),
        mineId: const drift.Value('55555555-5555-5555-5555-555555555501'),
        title: drift.Value(rule.title),
        description: const drift.Value(null),
        frequency: drift.Value(rule.frequency),
        ownerRole: drift.Value(rule.officer.replaceAll(' ', '_')),
        dueDate: drift.Value(rule.dueDate.toUtc()),
        status: drift.Value(rule.status),
        category: drift.Value(rule.category),
        evidenceRequired: drift.Value(rule.evidence),
        updatedAt: drift.Value(DateTime.now().toUtc()),
        syncStatus: const drift.Value(1),
      );

  String _categoryFor(String text) {
    if (text.contains('dust') ||
        text.contains('water') ||
        text.contains('environment') ||
        text.contains('drain')) {
      return 'Environment';
    }
    if (text.contains('contractor') ||
        text.contains('worker') ||
        text.contains('medical') ||
        text.contains('labour')) {
      return 'Labour';
    }
    if (text.contains('equipment') ||
        text.contains('pump') ||
        text.contains('engine') ||
        text.contains('brake')) {
      return 'Equipment';
    }
    return 'Safety';
  }

  Future<void> _updateRule(
    _ComplianceRule rule, {
    String? status,
    DateTime? dueDate,
  }) async {
    final database = Provider.of<AppDatabase?>(context, listen: false);
    if (database == null) return;
    await database.updateObligationOffline(
      remoteId: rule.remoteId,
      status: status,
      dueDate: dueDate,
    );
    if (!rule.localDemo) {
      try {
        await SyncService(database).sync();
      } catch (_) {}
    }
    final pending = await database.getPendingObligationUpdates();
    final syncPending = pending.any((item) => item.remoteId == rule.remoteId);
    if (!mounted) return;
    setState(() {
      _rules = _rules
          .map(
            (item) => item.remoteId == rule.remoteId
                ? item.copyWith(
                    status: status,
                    dueDate: dueDate,
                    syncPending: syncPending,
                  )
                : item,
          )
          .toList();
      _isLive = !rule.localDemo && !syncPending;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          rule.localDemo
              ? 'Local demo change saved on this device.'
              : syncPending
              ? 'Saved on device. Waiting for database sync.'
              : 'Saved and synced to the database.',
        ),
      ),
    );
  }

  Future<void> _selectDueDate(_ComplianceRule rule) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: rule.dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) await _updateRule(rule, dueDate: picked);
  }

  List<_ComplianceRule> get _filtered {
    if (_selectedCategory == 'All') return _rules;
    return _rules.where((r) => r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final overdue = _rules.where((r) => r.displayStatus == 'OVERDUE').length;
    final compliant = _rules.where((r) => r.status == 'COMPLETED').length;

    return Column(
      children: [
        // Live data indicator banner
        if (_isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            color: AppTheme.greenVerified.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_done,
                  size: 14,
                  color: AppTheme.greenVerified,
                ),
                const SizedBox(width: 6),
                Text(
                  _rules.any((rule) => rule.syncPending)
                      ? 'Supabase data loaded · local edits pending sync'
                      : 'Live statutory rules from Supabase',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),

        // Summary strip
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.nearBlackCoal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSumStat('${_rules.length}', 'Total Rules', Colors.white70),
              _buildDivider(),
              _buildSumStat('$compliant', 'Compliant', AppTheme.greenVerified),
              _buildDivider(),
              _buildSumStat('$overdue', 'Overdue', AppTheme.redDanger),
            ],
          ),
        ),

        // Category filter
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = _categories[i];
              final selected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.amberAccent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? AppTheme.amberAccent
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Rules list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadRules,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filtered.isEmpty ? 1 : _filtered.length,
              itemBuilder: (context, i) => _filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isLoading
                                ? Icons.sync
                                : Icons.rule_folder_outlined,
                            size: 36,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isLoading
                                ? 'Loading statutory rules...'
                                : _loadFailed
                                ? 'Could not load statutory rules. Pull to retry.'
                                : 'No statutory rules are available.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    )
                  : _buildRuleCard(_filtered[i]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard(_ComplianceRule rule) {
    Color statusColor;
    IconData statusIcon;
    switch (rule.displayStatus) {
      case 'OVERDUE':
        statusColor = AppTheme.redDanger;
        statusIcon = Icons.error_outline;
        break;
      case 'DUE TODAY':
        statusColor = AppTheme.amberAccent;
        statusIcon = Icons.schedule;
        break;
      case 'EXPIRING SOON':
        statusColor = Colors.orange;
        statusIcon = Icons.timelapse;
        break;
      default:
        statusColor = AppTheme.greenVerified;
        statusIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          rule.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                rule.id,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${rule.frequency} · ${rule.dueDate.toLocal().toIso8601String().split('T').first}',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rule.localDemo
                ? 'LOCAL DEMO'
                : rule.syncPending
                ? 'PENDING SYNC'
                : rule.displayStatus,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(14).copyWith(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                _buildInfoRow(
                  Icons.person,
                  'Responsible Officer',
                  rule.officer,
                ),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.assignment,
                  'Evidence Required',
                  rule.evidence,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: rule.status,
                  decoration: const InputDecoration(labelText: 'Update status'),
                  items: const [
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(value: 'OVERDUE', child: Text('Overdue')),
                    DropdownMenuItem(
                      value: 'COMPLETED',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'EXEMPTED',
                      child: Text('Exempted'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null && value != rule.status) {
                      _updateRule(rule, status: value);
                    }
                  },
                ),
                TextButton.icon(
                  onPressed: () => _selectDueDate(rule),
                  icon: const Icon(Icons.edit_calendar, size: 16),
                  label: const Text('Change due date'),
                ),
                const SizedBox(height: 8),
                Text(
                  rule.localDemo
                      ? 'Bundled demo record · edits are saved on this device only'
                      : rule.syncPending
                      ? 'Saved on this device · waiting for network sync'
                      : 'Database record · edits sync to the server',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildSumStat(String val, String lbl, Color clr) {
    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: clr,
          ),
        ),
        Text(lbl, style: const TextStyle(fontSize: 11, color: Colors.white60)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 24, width: 1, color: Colors.white24);
  }
}

class _ComplianceRule {
  final String remoteId;
  final String id;
  final String title;
  final String category;
  final String frequency;
  final DateTime dueDate;
  final String officer;
  final String evidence;
  final String status;
  final bool syncPending;
  final bool localDemo;

  _ComplianceRule({
    required this.remoteId,
    required this.id,
    required this.title,
    required this.category,
    required this.frequency,
    required this.dueDate,
    required this.officer,
    required this.evidence,
    required this.status,
    required this.syncPending,
    required this.localDemo,
  });

  String get displayStatus {
    if (status == 'PENDING' && dueDate.isBefore(DateTime.now()))
      return 'OVERDUE';
    if (status == 'COMPLETED') return 'COMPLIANT';
    return status;
  }

  _ComplianceRule copyWith({
    String? status,
    DateTime? dueDate,
    bool? syncPending,
    bool? localDemo,
  }) => _ComplianceRule(
    remoteId: remoteId,
    id: id,
    title: title,
    category: category,
    frequency: frequency,
    dueDate: dueDate ?? this.dueDate,
    officer: officer,
    evidence: evidence,
    status: status ?? this.status,
    syncPending: syncPending ?? this.syncPending,
    localDemo: localDemo ?? this.localDemo,
  );
}
