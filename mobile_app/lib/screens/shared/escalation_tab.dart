import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Automated Escalation System – shows escalation trails for overdue issues.
class EscalationTab extends StatefulWidget {
  const EscalationTab({super.key});

  @override
  State<EscalationTab> createState() => _EscalationTabState();
}

class _EscalationTabState extends State<EscalationTab> {
  final List<_EscalationCase> _cases = [
    _EscalationCase(
      id: 'ESC-2024-001',
      title: 'Gas readings exceed safe limits – Face 3A',
      priority: 'CRITICAL',
      priorityColor: AppTheme.redDanger,
      currentLevel: 2,
      steps: [
        _EscStep('Inspector / Sirdar', 'S. Oram', 'Reported on 22 Sep', true, '22 Sep 06:15'),
        _EscStep('Mine Manager', 'R. Patel', 'Notified on 22 Sep', true, '22 Sep 07:00'),
        _EscStep('Corporate Safety', 'HQ SECL', 'Escalated – no action taken', true, '24 Sep 09:30'),
        _EscStep('DGMS Regulator', 'DGMS Bilaspur', 'Awaiting regulator response', false, ''),
      ],
    ),
    _EscalationCase(
      id: 'ESC-2024-003',
      title: 'Winding engine defect – Shaft Bottom',
      priority: 'CRITICAL',
      priorityColor: AppTheme.redDanger,
      currentLevel: 1,
      steps: [
        _EscStep('Inspector / Sirdar', 'S. Oram', 'Defect reported on 24 Sep', true, '24 Sep 14:00'),
        _EscStep('Mine Manager', 'R. Patel', 'Under review – no closure yet', true, '24 Sep 15:00'),
        _EscStep('Corporate Safety', 'HQ SECL', 'Pending escalation (auto in 48h)', false, ''),
        _EscStep('DGMS Regulator', 'DGMS Bilaspur', '', false, ''),
      ],
    ),
    _EscalationCase(
      id: 'ESC-2024-005',
      title: 'Contractor BOCW non-compliance – 14 workers',
      priority: 'HIGH',
      priorityColor: Colors.deepOrange,
      currentLevel: 1,
      steps: [
        _EscStep('Inspector / Sirdar', 'S. Oram', 'Identified on 20 Sep', true, '20 Sep 10:00'),
        _EscStep('Mine Manager', 'R. Patel', 'Contractor notified, pending', true, '21 Sep 09:00'),
        _EscStep('Corporate Safety', 'HQ SECL', 'Will escalate in 12h if unresolved', false, ''),
        _EscStep('DGMS Regulator', 'DGMS Bilaspur', '', false, ''),
      ],
    ),
  ];

  static const List<String> _levelLabels = [
    'Inspector',
    'Mine Manager',
    'Corporate',
    'DGMS Regulator',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.nearBlackCoal,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.redDanger.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.campaign,
                    color: AppTheme.redDanger, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AUTOMATED ESCALATION SYSTEM',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5)),
                    Text(
                        'Overdue critical issues auto-escalate up the chain',
                        style: TextStyle(color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Level legend
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _levelBadge('L1', 'Inspector', AppTheme.cobaltBlue),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              _levelBadge('L2', 'Manager', AppTheme.amberAccent),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              _levelBadge('L3', 'Corporate', Colors.deepOrange),
              const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
              _levelBadge('L4', 'DGMS', AppTheme.redDanger),
            ],
          ),
        ),

        // Cases
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cases.length,
            itemBuilder: (context, i) => _buildCaseCard(_cases[i]),
          ),
        ),
      ],
    );
  }

  Widget _levelBadge(String level, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          alignment: Alignment.center,
          child: Text(level,
              style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  Widget _buildCaseCard(_EscalationCase c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: c.priorityColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(c.priority,
                                style: TextStyle(
                                    color: c.priorityColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Text(c.id,
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[500],
                                  fontFamily: 'monospace')),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(c.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Escalation trail
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: List.generate(c.steps.length, (i) {
                final step = c.steps[i];
                final isActive = i == c.currentLevel;
                final isDone = i < c.currentLevel;
                final isLast = i == c.steps.length - 1;

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline dot + line
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppTheme.greenVerified
                                  : isActive
                                      ? c.priorityColor
                                      : Colors.grey[200],
                              shape: BoxShape.circle,
                              border: isActive
                                  ? Border.all(
                                      color: c.priorityColor, width: 2)
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                'L${i + 1}',
                                style: TextStyle(
                                  color: isDone || isActive
                                      ? Colors.white
                                      : Colors.grey,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 2,
                                color: isDone
                                    ? AppTheme.greenVerified.withAlpha(80)
                                    : Colors.grey[200],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Step details
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    _levelLabels[i],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isDone || isActive
                                          ? AppTheme.nearBlackCoal
                                          : Colors.grey,
                                    ),
                                  ),
                                  if (isActive)
                                    Container(
                                      margin: const EdgeInsets.only(left: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color:
                                            c.priorityColor.withAlpha(20),
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'CURRENT',
                                        style: TextStyle(
                                            color: c.priorityColor,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              Text(step.officer,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blueGrey)),
                              if (step.note.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(step.note,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                        fontStyle: FontStyle.italic)),
                              ],
                              if (step.timestamp.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(step.timestamp,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey)),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Action row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.history, size: 14),
                    label: const Text('Full History',
                        style: TextStyle(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_upward, size: 14),
                    label: const Text('Force Escalate',
                        style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: c.priorityColor,
                        foregroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EscalationCase {
  final String id;
  final String title;
  final String priority;
  final Color priorityColor;
  int currentLevel;
  final List<_EscStep> steps;

  _EscalationCase({
    required this.id,
    required this.title,
    required this.priority,
    required this.priorityColor,
    required this.currentLevel,
    required this.steps,
  });
}

class _EscStep {
  final String role;
  final String officer;
  final String note;
  final bool done;
  final String timestamp;

  _EscStep(this.role, this.officer, this.note, this.done, this.timestamp);
}
