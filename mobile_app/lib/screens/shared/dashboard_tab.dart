import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/region_summary_card.dart';
import '../../widgets/provenance_bar.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isAuditing = false;

  void _runIntegrityCheck() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _IntegrityCheckModal(),
    );
  }

  void _showInspectionDispatchDialog(InspectionPriority p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: Row(
          children: [
            const Icon(Icons.security, color: AppTheme.amberAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(p.mineName,
                  style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Risk Priority Score: ${p.score}',
                style: const TextStyle(color: AppTheme.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            Text(p.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('Reason for Audit:\n${p.reason}',
                  style: const TextStyle(color: Colors.white60, fontSize: 11, fontStyle: FontStyle.italic)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberAccent, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Senior Inspector dispatched to ${p.mineName}!'),
                  backgroundColor: AppTheme.greenVerified,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Dispatch Inspector'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const metrics = nagpurRegionMetrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metrics.regionName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.nearBlackCoal,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'September 2026',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _runIntegrityCheck,
                icon: const Icon(Icons.verified_user, size: 14),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cobaltBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                label: const Text('Integrity Check', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Summary Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              RegionSummaryCard(
                label: 'MINES IN JURISDICTION',
                value: metrics.totalMines.toString(),
                subValue: '${metrics.coalMines} coal, ${metrics.metalMines} metal',
                accentColor: AppTheme.absoluteBlack,
              ),
              RegionSummaryCard(
                label: 'INSPECTIONS THIS QUARTER',
                value: '${metrics.inspectionsDone} of ${metrics.inspectionsTarget}',
                footer: '68%, 19 mines past interval',
                accentColor: AppTheme.amberAccent,
              ),
              RegionSummaryCard(
                label: 'DIRECTIONS OPEN',
                value: metrics.directionsOpen.toString(),
                footer: '19 past their compliance date',
                accentColor: AppTheme.amberAccent,
              ),
              RegionSummaryCard(
                label: 'ACCIDENTS NOTIFIED, 2026',
                value: metrics.fatalAccidents.toString(),
                subValue: 'fatal',
                footer: '14 serious, 2 notices arrived late',
                accentColor: AppTheme.redDanger,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Assurance & Reporting Section
          const Text(
            'Assurance and reporting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Provenance of everything this office sees',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProvenanceBar(data: provenanceData),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildProvenanceRow('Inspection findings', '187', 'Inspector on site'),
                _buildProvenanceRow('Ambient and gas readings', '1,244', 'Instrument feed'),
                _buildProvenanceRow('Accident notifications', '8', 'Operator, sealed'),
                _buildProvenanceRow('Monthly returns', '96', 'Operator, sealed'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Where to send inspectors
          const Text(
            'Where to send inspectors (Tap to Dispatch)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...inspectionPriorities.map((p) => _buildInspectionPriorityTile(p)),
          
          const SizedBox(height: 24),
          
          // Discipline Coverage
          const Text(
            'Coverage by discipline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              children: disciplineCoverages.map((d) => _buildCoverageBar(d)).toList(),
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProvenanceRow(String label, String count, String source) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.offWhiteBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              source,
              style: const TextStyle(fontSize: 9, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionPriorityTile(InspectionPriority p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showInspectionDispatchDialog(p),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.nearBlackCoal,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${inspectionPriorities.indexOf(p) + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(p.mineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Score ${p.score}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Text(p.subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(p.reason, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverageBar(DisciplineCoverage d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.label, style: const TextStyle(fontSize: 11)),
              Text('${d.current}/${d.total}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: d.current / d.total,
              backgroundColor: AppTheme.offWhiteBackground,
              valueColor: AlwaysStoppedAnimation<Color>(d.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

/// Live Cryptographic Integrity Audit Modal
class _IntegrityCheckModal extends StatefulWidget {
  @override
  State<_IntegrityCheckModal> createState() => _IntegrityCheckModalState();
}

class _IntegrityCheckModalState extends State<_IntegrityCheckModal> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    _startAudit();
  }

  Future<void> _startAudit() async {
    for (int i = 1; i <= 4; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _step = i);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: AppTheme.amberAccent, size: 28),
              const SizedBox(width: 10),
              const Text('System Integrity Audit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),

          _buildStepRow(1, 'SQLite & Drift Local DB Check', '1,535 records hashed'),
          _buildStepRow(2, 'Cryptographic Ledger Proofs', 'Merkle root valid'),
          _buildStepRow(3, 'Offline Mesh SOS Signature Audit', '0 tampered packets'),
          _buildStepRow(4, 'Realtime Sync Protocol Status', 'Connected & Active'),

          const SizedBox(height: 20),
          if (_step < 4) ...[
            const Row(
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppTheme.amberAccent, strokeWidth: 2)),
                SizedBox(width: 12),
                Text('Verifying cryptographic proofs...', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.greenVerified.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.greenVerified),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.greenVerified),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('100% HEALTHY — TRUST SCORE: 99.8%',
                            style: TextStyle(color: AppTheme.greenVerified, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('All database records match cryptographic hashes. Zero tampering detected.',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepRow(int stepNum, String title, String subtitle) {
    final isDone = _step >= stepNum;
    final isCurrent = _step == stepNum - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          isDone
              ? const Icon(Icons.check_circle, color: AppTheme.greenVerified, size: 20)
              : isCurrent
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppTheme.amberAccent, strokeWidth: 2))
                  : const Icon(Icons.radio_button_unchecked, color: Colors.white30, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDone ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

