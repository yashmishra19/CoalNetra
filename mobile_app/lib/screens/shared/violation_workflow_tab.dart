import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Violation → Corrective Action Workflow
/// detect → assign → correct → verify → close
class ViolationWorkflowTab extends StatefulWidget {
  const ViolationWorkflowTab({super.key});

  @override
  State<ViolationWorkflowTab> createState() => _ViolationWorkflowTabState();
}

class _ViolationWorkflowTabState extends State<ViolationWorkflowTab> {
  String _filterStatus = 'All';
  final List<String> _statusFilters = ['All', 'Detected', 'Assigned', 'Correcting', 'Verifying', 'Closed'];

  final List<_Violation> _violations = [
    _Violation(
      id: 'VIO-2024-089',
      title: 'Loose roof bolt at Junction 2',
      category: 'Safety',
      zone: 'Junction 2',
      detectedBy: 'S. Oram (Sirdar)',
      detectedOn: '24 Sep 2026',
      assignedTo: 'Mining Overseer',
      dueDate: '26 Sep 2026',
      currentStep: 1, // Assigned
      priority: 'CRITICAL',
      priorityColor: AppTheme.redDanger,
      isRecurring: false,
    ),
    _Violation(
      id: 'VIO-2024-091',
      title: 'Dust suppression off in Zone 3A',
      category: 'Environment',
      zone: 'Face Gallery 3A',
      detectedBy: 'AI System (Sensor)',
      detectedOn: '25 Sep 2026',
      assignedTo: 'Env. Officer',
      dueDate: '27 Sep 2026',
      currentStep: 2, // Correcting
      priority: 'HIGH',
      priorityColor: Colors.deepOrange,
      isRecurring: true,
    ),
    _Violation(
      id: 'VIO-2024-085',
      title: 'Fire extinguisher discharged – Pump House',
      category: 'Safety',
      zone: 'Pump House B',
      detectedBy: 'S. Oram (Sirdar)',
      detectedOn: '20 Sep 2026',
      assignedTo: 'Safety Officer',
      dueDate: '22 Sep 2026',
      currentStep: 3, // Verifying
      priority: 'HIGH',
      priorityColor: Colors.deepOrange,
      isRecurring: false,
    ),
    _Violation(
      id: 'VIO-2024-078',
      title: 'Worker PPE non-compliance – Conveyor',
      category: 'Labour',
      zone: 'Conveyor Belt 4',
      detectedBy: 'S. Oram (Sirdar)',
      detectedOn: '18 Sep 2026',
      assignedTo: 'Contractor Sup.',
      dueDate: '20 Sep 2026',
      currentStep: 4, // Closed
      priority: 'MEDIUM',
      priorityColor: AppTheme.amberAccent,
      isRecurring: false,
    ),
    _Violation(
      id: 'VIO-2024-093',
      title: 'Winding engine pre-shift test skipped',
      category: 'Equipment',
      zone: 'Shaft Bottom',
      detectedBy: 'AI System (Checklist)',
      detectedOn: '26 Sep 2026',
      assignedTo: 'Mechanical Eng.',
      dueDate: '26 Sep 2026',
      currentStep: 0, // Detected
      priority: 'CRITICAL',
      priorityColor: AppTheme.redDanger,
      isRecurring: true,
    ),
  ];

  static const List<String> _steps = [
    'Detected',
    'Assigned',
    'Correcting',
    'Verifying',
    'Closed',
  ];

  List<_Violation> get _filtered {
    if (_filterStatus == 'All') return _violations;
    return _violations
        .where((v) => _steps[v.currentStep] == _filterStatus)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pipeline header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.nearBlackCoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VIOLATION PIPELINE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(_steps.length, (i) {
                  final count = _violations
                      .where((v) => v.currentStep == i)
                      .length;
                  final isLast = i == _steps.length - 1;
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6),
                                decoration: BoxDecoration(
                                  color: count > 0
                                      ? AppTheme.amberAccent.withAlpha(40)
                                      : Colors.white12,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$count',
                                      style: TextStyle(
                                        color: count > 0
                                            ? AppTheme.amberAccent
                                            : Colors.white38,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _steps[i],
                                      style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 9),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!isLast)
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.white24, size: 12),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        // Filter tabs
        Container(
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: _statusFilters.map((s) {
                final sel = _filterStatus == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filterStatus = s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.nearBlackCoal
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 11,
                          color: sel ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Violation cards
        Expanded(
          child: _filtered.isEmpty
              ? const Center(
                  child: Text('No violations in this stage.',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filtered.length,
                  itemBuilder: (context, i) =>
                      _buildViolationCard(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildViolationCard(_Violation v) {
    final nextStepLabel =
        v.currentStep < _steps.length - 1 ? _steps[v.currentStep + 1] : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: v.priorityColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.report_problem,
                      color: v.priorityColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(v.id,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                  fontFamily: 'monospace')),
                          const SizedBox(width: 8),
                          if (v.isRecurring)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.purple.withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '⟳ RECURRING',
                                style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.purple,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(v.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: v.priorityColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(v.priority,
                                style: TextStyle(
                                    color: v.priorityColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          Text(v.category,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                          const SizedBox(width: 6),
                          Text('· ${v.zone}',
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Workflow stepper
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: List.generate(_steps.length, (i) {
                final done = i < v.currentStep;
                final current = i == v.currentStep;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: done
                                    ? AppTheme.greenVerified
                                    : current
                                        ? AppTheme.amberAccent
                                        : Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                done
                                    ? Icons.check
                                    : current
                                        ? Icons.adjust
                                        : Icons.circle_outlined,
                                color: done || current
                                    ? Colors.white
                                    : Colors.grey,
                                size: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _steps[i],
                              style: TextStyle(
                                fontSize: 8,
                                color: done
                                    ? AppTheme.greenVerified
                                    : current
                                        ? AppTheme.amberAccent
                                        : Colors.grey,
                                fontWeight: current
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (i < _steps.length - 1)
                        Expanded(
                          child: Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 14),
                            color: done
                                ? AppTheme.greenVerified.withAlpha(80)
                                : Colors.grey[200],
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          // Footer details + action
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assigned to: ${v.assignedTo}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                      Text('Due: ${v.dueDate}',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                if (nextStepLabel != null)
                  ElevatedButton(
                    onPressed: () => _advanceStep(v),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amberAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: const Size(0, 32),
                    ),
                    child: Text(
                      '→ $nextStepLabel',
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _advanceStep(_Violation v) {
    setState(() {
      if (v.currentStep < _steps.length - 1) {
        v.currentStep++;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          '${v.id} advanced to: ${_steps[v.currentStep]}',
          style: const TextStyle(fontSize: 12)),
      backgroundColor: AppTheme.greenVerified,
      duration: const Duration(seconds: 2),
    ));
  }
}

class _Violation {
  final String id;
  final String title;
  final String category;
  final String zone;
  final String detectedBy;
  final String detectedOn;
  final String assignedTo;
  final String dueDate;
  int currentStep;
  final String priority;
  final Color priorityColor;
  final bool isRecurring;

  _Violation({
    required this.id,
    required this.title,
    required this.category,
    required this.zone,
    required this.detectedBy,
    required this.detectedOn,
    required this.assignedTo,
    required this.dueDate,
    required this.currentStep,
    required this.priority,
    required this.priorityColor,
    required this.isRecurring,
  });
}
