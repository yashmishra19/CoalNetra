import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Recurring Violation Detection + Predictive Compliance Alerts
/// Combined into one alerts tab for Sirdar
class ComplianceAlertsTab extends StatefulWidget {
  const ComplianceAlertsTab({super.key});

  @override
  State<ComplianceAlertsTab> createState() => _ComplianceAlertsTabState();
}

class _ComplianceAlertsTabState extends State<ComplianceAlertsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_RecurringViolation> _recurring = [
    _RecurringViolation(
      title: 'Gas levels exceed limit at Face 3A',
      zone: 'Face Gallery 3A',
      category: 'Safety',
      occurrences: 7,
      period: 'last 30 days',
      pattern: 'Every Tuesday & Thursday 06:00–08:00',
      riskDelta: '+12 pts',
      suggestion: 'Schedule targeted gas purging before morning shift.',
    ),
    _RecurringViolation(
      title: 'Dust suppression inactive during haul',
      zone: 'Haul Road 2',
      category: 'Environment',
      occurrences: 5,
      period: 'last 21 days',
      pattern: 'Afternoon shift, 13:00–15:00',
      riskDelta: '+8 pts',
      suggestion: 'Automate sprinkler activation on haul-road sensor trigger.',
    ),
    _RecurringViolation(
      title: 'PPE non-compliance – contractor workers',
      zone: 'Conveyor Belt 4',
      category: 'Labour',
      occurrences: 4,
      period: 'last 14 days',
      pattern: 'Monday/Wednesday, all shifts',
      riskDelta: '+6 pts',
      suggestion:
          'Issue show-cause notice to contractor. Mandatory re-training.',
    ),
    _RecurringViolation(
      title: 'Equipment pre-shift test skipped',
      zone: 'Shaft Bottom',
      category: 'Equipment',
      occurrences: 3,
      period: 'last 10 days',
      pattern: 'Night shift handover',
      riskDelta: '+5 pts',
      suggestion: 'Add mandatory digital sign-off before night shift start.',
    ),
  ];

  final List<_PredictiveAlert> _predictive = [
    _PredictiveAlert(
      title: 'DGMS Quarterly Report overdue in 3 days',
      confidence: 0.94,
      category: 'Statutory',
      deadline: '29 Sep 2026',
      action: 'Assign report generation to compliance officer today.',
      severity: 'CRITICAL',
      color: AppTheme.redDanger,
    ),
    _PredictiveAlert(
      title: 'Boiler operator certificate expiring in 7 days',
      confidence: 0.89,
      category: 'Labour',
      deadline: '03 Oct 2026',
      action: 'Schedule renewal at district office. Upload new cert.',
      severity: 'HIGH',
      color: Colors.deepOrange,
    ),
    _PredictiveAlert(
      title: 'Pump House B likely to trigger gas alarm next shift',
      confidence: 0.76,
      category: 'Safety',
      deadline: 'Next shift · 06:00',
      action: 'Pre-inspect ventilation ducts at Pump House B before shift.',
      severity: 'HIGH',
      color: Colors.deepOrange,
    ),
    _PredictiveAlert(
      title: 'Conveyor belt tension inspection due in 2 days',
      confidence: 0.82,
      category: 'Equipment',
      deadline: '28 Sep 2026',
      action: 'Schedule mechanical inspection with documented readings.',
      severity: 'MEDIUM',
      color: AppTheme.amberAccent,
    ),
    _PredictiveAlert(
      title: 'Monthly labour returns not submitted',
      confidence: 0.91,
      category: 'Labour',
      deadline: '30 Sep 2026',
      action: 'Contractor to submit Form-B by month end.',
      severity: 'MEDIUM',
      color: AppTheme.amberAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header banner
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.nearBlackCoal,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.amberAccent.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology,
                    color: AppTheme.amberAccent, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI COMPLIANCE INTELLIGENCE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5)),
                    Text(
                        'Pattern detection + predictive alerts · Updated 1h ago',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.amberAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.amberAccent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.loop, size: 16),
                    const SizedBox(width: 6),
                    Text('Recurring (${_recurring.length})',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt, size: 16),
                    const SizedBox(width: 6),
                    Text('Predictive (${_predictive.length})',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Recurring violations
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _recurring.length,
                itemBuilder: (context, i) =>
                    _buildRecurringCard(_recurring[i]),
              ),

              // Predictive alerts
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _predictive.length,
                itemBuilder: (context, i) =>
                    _buildPredictiveCard(_predictive[i]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecurringCard(_RecurringViolation rv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.purple.withAlpha(80)),
        boxShadow: [
          BoxShadow(
              color: Colors.purple.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.loop, size: 12, color: Colors.purple),
                    const SizedBox(width: 4),
                    Text('${rv.occurrences}× in ${rv.period}',
                        style: const TextStyle(
                            color: Colors.purple,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(rv.category,
                    style:
                        const TextStyle(fontSize: 10, color: Colors.blueGrey)),
              ),
              const Spacer(),
              Text(rv.riskDelta,
                  style: const TextStyle(
                      color: AppTheme.redDanger,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Text(rv.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.place_outlined, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text(rv.zone,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.access_time, size: 13, color: Colors.blueGrey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Pattern: ${rv.pattern}',
                      style:
                          const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline,
                  size: 14, color: AppTheme.amberAccent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(rv.suggestion,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.nearBlackCoal,
                        fontStyle: FontStyle.italic)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: const Text('Create CAPA',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: const Text('Escalate',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveCard(_PredictiveAlert pa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: pa.color, width: 4)),
        boxShadow: [
          BoxShadow(
              color: pa.color.withAlpha(12),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pa.color.withAlpha(25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(pa.severity,
                    style: TextStyle(
                        color: pa.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, size: 11, color: Colors.blueGrey),
                    const SizedBox(width: 3),
                    Text('${(pa.confidence * 100).round()}% confidence',
                        style: const TextStyle(
                            fontSize: 10, color: Colors.blueGrey)),
                  ],
                ),
              ),
              const Spacer(),
              Text(pa.category,
                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Text(pa.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
              const SizedBox(width: 4),
              Text('Deadline: ${pa.deadline}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          // Confidence bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pa.confidence,
              minHeight: 6,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(pa.color),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: pa.color.withAlpha(10),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: pa.color.withAlpha(40)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline, size: 14, color: pa.color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Recommended Action: ${pa.action}',
                    style: TextStyle(fontSize: 11, color: pa.color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: pa.color,
                    side: BorderSide(color: pa.color),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: const Text('Dismiss',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pa.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                  child: const Text('Take Action',
                      style: TextStyle(fontSize: 11)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecurringViolation {
  final String title;
  final String zone;
  final String category;
  final int occurrences;
  final String period;
  final String pattern;
  final String riskDelta;
  final String suggestion;

  _RecurringViolation({
    required this.title,
    required this.zone,
    required this.category,
    required this.occurrences,
    required this.period,
    required this.pattern,
    required this.riskDelta,
    required this.suggestion,
  });
}

class _PredictiveAlert {
  final String title;
  final double confidence;
  final String category;
  final String deadline;
  final String action;
  final String severity;
  final Color color;

  _PredictiveAlert({
    required this.title,
    required this.confidence,
    required this.category,
    required this.deadline,
    required this.action,
    required this.severity,
    required this.color,
  });
}
