import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class _MockCapa {
  final String id;
  final String title;
  final String dueDate;
  final String severity;
  final String assignedTo;
  final int escalationLevel;

  const _MockCapa({
    required this.id,
    required this.title,
    required this.dueDate,
    required this.severity,
    required this.assignedTo,
    this.escalationLevel = 0,
  });
}

const _capas = [
  _MockCapa(
    id: 'CAPA-0021',
    title: 'Fix haul road drainage at Sector B',
    dueDate: '12 Sep 2026',
    severity: 'Critical',
    assignedTo: 'R. Mahato',
    escalationLevel: 1,
  ),
  _MockCapa(
    id: 'CAPA-0019',
    title: 'Dust suppression at OB Dump #3',
    dueDate: '18 Sep 2026',
    severity: 'Major',
    assignedTo: 'S. Oram',
  ),
  _MockCapa(
    id: 'CAPA-0017',
    title: 'Update fire extinguisher log — Pump House',
    dueDate: '25 Sep 2026',
    severity: 'Minor',
    assignedTo: 'A. Gupta',
  ),
];

class CapasTab extends StatelessWidget {
  const CapasTab({super.key});

  Color _severityColor(String s) {
    switch (s) {
      case 'Critical':
        return AppTheme.redDanger;
      case 'Major':
        return AppTheme.amberAccent;
      default:
        return AppTheme.greenVerified;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Corrective Actions',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text('${_capas.length} open · Sardega OCP',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ..._capas.map((capa) => _buildCard(capa)),
      ],
    );
  }

  Widget _buildCard(_MockCapa capa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: _severityColor(capa.severity), width: 4),
          top: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(capa.id,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.amberAccent)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _severityColor(capa.severity).withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  capa.severity,
                  style: TextStyle(
                      fontSize: 10,
                      color: _severityColor(capa.severity),
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(capa.title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(capa.assignedTo,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
              const Spacer(),
              const Icon(Icons.calendar_today_outlined,
                  size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Due: ${capa.dueDate}',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          if (capa.escalationLevel > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.arrow_upward,
                    size: 12, color: AppTheme.redDanger),
                const SizedBox(width: 4),
                Text(
                  'Escalated to Level ${capa.escalationLevel}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.redDanger),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
