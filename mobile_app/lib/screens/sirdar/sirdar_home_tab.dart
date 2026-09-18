import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../theme/app_theme.dart';
import '../observation_form.dart';

class SirdarHomeTab extends StatelessWidget {
  const SirdarHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Officer Header
          const Padding(
            padding: EdgeInsets.only(bottom: 12, left: 2, right: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('B. Oraon', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.ink, height: 1.15)),
                SizedBox(height: 2),
                Text('Overman · Certificate 1st class', style: TextStyle(fontSize: 13, color: AppTheme.ink2)),
                SizedBox(height: 4),
                Text(
                  'Your district today: Benches 3 to 5, Haul Road North, Dump-3 toe, Sump-1',
                  style: TextStyle(fontSize: 13, color: AppTheme.ink, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // 2. Statutory Round button — navigates to round checklist (observation list)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 11),
            decoration: BoxDecoration(color: AppTheme.graphite, borderRadius: BorderRadius.circular(10)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  // Navigate to observation form in 'CAPA Closure' mode (round inspection)
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const ObservationFormScreen(initialCategory: 'Safety Hazard'),
                  ));
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('STATUTORY ROUND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF8FA6B0), letterSpacing: 0.09 * 11)),
                      const SizedBox(height: 2),
                      const Text('Continue round', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                      const SizedBox(height: 10),
                      // Live progress bar from pending observations in DB
                      _RoundProgressBar(),
                      const SizedBox(height: 8),
                      const Text('Tap to log next inspection point', style: TextStyle(fontSize: 13, color: Color(0xFFC7D4DA))),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Shift report due clock
          Container(
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.panel,
              border: const Border(left: BorderSide(color: AppTheme.steel, width: 4)),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time, size: 17, color: AppTheme.steel),
                SizedBox(width: 8),
                Text('Shift report due 22:00', style: TextStyle(fontSize: 13.5, color: AppTheme.ink)),
                Spacer(),
                Text('3h 40m', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.ink)),
              ],
            ),
          ),

          // 4. Three Capture Tiles — all actually navigate
          Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: Row(
              children: [
                Expanded(child: _buildCaptureTile(context, Icons.warning_amber_rounded, 'Observation', false, 'Safety Hazard')),
                const SizedBox(width: 8),
                Expanded(child: _buildCaptureTile(context, Icons.block_outlined, 'Near miss', true, 'Near-miss')),
                const SizedBox(width: 8),
                Expanded(child: _buildCaptureTile(context, Icons.bar_chart_outlined, 'Reading', false, 'Statutory Reading')),
              ],
            ),
          ),

          // 5. My Actions Card — from real DB (pending observations as proxy)
          _MyActionsCard(),

          // 6. Handover card (static — filled from shift handover notes in real deployment)
          _buildPrototypeCard(
            title: 'Handover from Shift A',
            count: 2,
            child: Column(
              children: [
                _buildListRow(
                  context: context,
                  dotColor: AppTheme.amberAccent,
                  title: 'Water accumulation at Dump-3 toe',
                  subtitle: 'Pump ran 4 hours. High risk of slope failure after rain.',
                  trailing: 'Action Required',
                  isTrailingCrit: true,
                  onTap: () => _showHandoverDetailDialog(context, 'Water accumulation at Dump-3 toe', 'Pump ran 4 hours. High risk of slope failure after rain.\n\nAssigned to: Shift B Sirdar\nStatus: Pending Inspection'),
                ),
                _buildListRow(
                  context: context,
                  dotColor: AppTheme.ink3,
                  title: 'Dozer DT-14 reversing alarm weak',
                  subtitle: 'Workshop informed at 13:10. Keep workers clear on North bench.',
                  trailing: 'In Progress',
                  isTrailingCrit: false,
                  onTap: () => _showHandoverDetailDialog(context, 'Dozer DT-14 reversing alarm weak', 'Workshop informed at 13:10. Keep workers clear on North bench.\n\nAssigned to: Maintenance Workshop\nStatus: Under Repair'),
                ),
              ],
            ),
          ),

          // 7. Legal note
          const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 24, left: 2, right: 2),
            child: Text(
              'Your records are sealed when they sync. If anyone asks later what you inspected and when, this is your evidence.',
              style: TextStyle(fontSize: 12, color: AppTheme.ink3, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureTile(BuildContext context, IconData icon, String label, bool isWarn, String category) {
    return Container(
      height: 86,
      decoration: BoxDecoration(color: AppTheme.panel, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(8)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => ObservationFormScreen(initialCategory: category),
            ));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 26, color: isWarn ? AppTheme.amberAccent : AppTheme.graphite),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.ink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrototypeCard({required String title, required int count, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppTheme.panel, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 11, 13, 0),
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.ink)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(color: AppTheme.redDanger, borderRadius: BorderRadius.circular(10)),
                  child: Text('$count', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  void _showHandoverDetailDialog(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in, color: AppTheme.amberAccent),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(details, style: const TextStyle(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ObservationFormScreen(initialCategory: title),
              ));
            },
            child: const Text('Log Action / Inspection'),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow({
    required BuildContext context,
    required Color dotColor,
    required String title,
    required String subtitle,
    required String trailing,
    required bool isTrailingCrit,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.lineSoft))),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.ink)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
                ],
              ),
            ),
            if (trailing.isNotEmpty) ...[
              const SizedBox(width: 10),
              Text(trailing, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isTrailingCrit ? AppTheme.redDanger : AppTheme.ink2)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows actual pending observation count from Drift DB as a progress bar
class _RoundProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null) return const SizedBox.shrink();

    return StreamBuilder<List<Observation>>(
      stream: db.select(db.observations).watch(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? [];
        final done = all.where((o) => o.syncStatus == 1).length;
        final total = all.isEmpty ? 11 : all.length + 5; // 5 remaining as placeholder
        final progress = all.isEmpty ? 0.55 : done / total;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 9,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(5)),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(decoration: BoxDecoration(color: AppTheme.amberAccent, borderRadius: BorderRadius.circular(5))),
              ),
            ),
            const SizedBox(height: 6),
            Text('$done logged this shift', style: const TextStyle(fontSize: 12, color: Color(0xFFC7D4DA))),
          ],
        );
      },
    );
  }
}

/// Shows real pending observations as CAPA-style action items
class _MyActionsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null) return const SizedBox.shrink();

    return StreamBuilder<List<Observation>>(
      stream: (db.select(db.observations)..where((t) => t.syncStatus.equals(0))..limit(3)).watch(),
      builder: (context, snapshot) {
        final pending = snapshot.data ?? [];

        final rows = <Widget>[];
        for (final obs in pending) {
          rows.add(_actionRow(
            context,
            dotColor: AppTheme.amberAccent,
            title: obs.category,
            subtitle: obs.location,
            trailing: 'Pending sync',
            isTrailingCrit: true,
          ));
        }
        if (rows.isEmpty) {
          rows.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            child: Text('No pending actions. All clear.', style: TextStyle(fontSize: 13, color: AppTheme.ink2)),
          ));
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: AppTheme.panel, border: Border.all(color: AppTheme.line), borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 0),
                child: Row(
                  children: [
                    const Text('My actions', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: AppTheme.ink)),
                    const Spacer(),
                    if (pending.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(color: AppTheme.redDanger, borderRadius: BorderRadius.circular(10)),
                        child: Text('${pending.length}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ...rows,
            ],
          ),
        );
      },
    );
  }

  Widget _actionRow(BuildContext context, {required Color dotColor, required String title, required String subtitle, required String trailing, required bool isTrailingCrit}) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.assignment_turned_in, color: AppTheme.amberAccent),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location: $subtitle', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Status: $trailing', style: const TextStyle(fontSize: 13, color: AppTheme.redDanger, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                const Text('Observation recorded locally and queued for DB sync.', style: TextStyle(fontSize: 12, color: AppTheme.ink2)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberAccent, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ObservationFormScreen(initialCategory: title),
                  ));
                },
                child: const Text('Edit / Add Note'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppTheme.lineSoft))),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppTheme.ink)),
                  const SizedBox(height: 1),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.ink2)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(trailing, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: isTrailingCrit ? AppTheme.redDanger : AppTheme.ink2)),
          ],
        ),
      ),
    );
  }
}
