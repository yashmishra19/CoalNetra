import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../shared/dashboard_tab.dart';

import '../shared/grievances_tab.dart';
import '../shared/ai_risk_score_tab.dart';
import '../shared/statutory_compliance_tab.dart';
import '../shared/violation_workflow_tab.dart';
import '../shared/compliance_alerts_tab.dart';
import '../shared/escalation_tab.dart';
import '../shared/documents_tab.dart';
import '../shared/compliance_report_tab.dart';
import '../shared/sos_beacon_screen.dart';
import '../sirdar/sirdar_profile_tab.dart';
import 'contractors_tab.dart';
import 'contractor_labour_tab.dart';

class ContractorHome extends StatefulWidget {
  final MockUser user;
  const ContractorHome({super.key, required this.user});

  @override
  State<ContractorHome> createState() => _ContractorHomeState();
}

class _ContractorHomeState extends State<ContractorHome> {
  int _selectedIndex = 0;

  // 6 bottom-nav tabs; sub-features accessible from "Compliance" hub
  List<Widget> get _tabs => [
    const DashboardTab(),
    const _ContractorComplianceHub(),
    const ContractorLabourTab(),
    const ContractorsTab(),
    const GrievancesTab(),
    SirdarProfileTab(user: widget.user),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppTheme.amberAccent, size: 28),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Contractor Portal",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "Under Sirdar Supervision · Sardega OCP",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SOSBeaconScreen(
                            userName: widget.user.role.userName,
                            role: widget.user.role.displayName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.redDanger,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppTheme.redDanger.withOpacity(0.4), blurRadius: 6),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.sensors, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "SOS",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () => _showAlertsSheet(context),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.redDanger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Stats Row (only on dashboard tab)
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildQuickStat("—", "Active Sites", Colors.blue),
                    const SizedBox(width: 8),
                    _buildQuickStat("—", "Open CAPAs", Colors.orange),
                    const SizedBox(width: 8),
                    _buildQuickStat("—", "Compliance", Colors.green),
                  ],
                ),
              ),

            const SizedBox(height: 8),
            Expanded(
              child: IndexedStack(
                  index: _selectedIndex, children: _tabs),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.amberAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined), label: 'Stats'),
          BottomNavigationBarItem(
              icon: Icon(Icons.gavel_outlined), label: 'Compliance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.groups_outlined), label: 'Labour'),
          BottomNavigationBarItem(
              icon: Icon(Icons.handshake_outlined), label: 'Contractors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Grievance'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            Text(label,
                style: const TextStyle(fontSize: 9, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  void _showAlertsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Compliance Alerts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _alertTile('ESI Registration expired – C. Civil Works',
                AppTheme.redDanger),
            _alertTile('BOCW not submitted – C. Civil Works',
                AppTheme.redDanger),
            _alertTile('4 workers training overdue – A. Constructions',
                AppTheme.amberAccent),
            _alertTile('Monthly labour returns due: 30 Sep',
                Colors.orange),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(String text, Color color) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.circle, color: color, size: 10),
      title: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}

/// Contractor compliance hub with all TRRAM feature cards
class _ContractorComplianceHub extends StatelessWidget {
  const _ContractorComplianceHub();

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature('AI Risk Score', Icons.psychology, Colors.purple,
          const AIRiskScoreTab()),
      _Feature('Statutory Rules', Icons.gavel, AppTheme.cobaltBlue,
          const StatutoryComplianceTab()),
      _Feature('Violation Workflow', Icons.report_problem, AppTheme.redDanger,
          const ViolationWorkflowTab()),
      _Feature('Compliance Alerts', Icons.bolt, AppTheme.amberAccent,
          const ComplianceAlertsTab()),
      _Feature('Escalation', Icons.campaign, Colors.deepOrange,
          const EscalationTab()),
      _Feature('Documents & OCR', Icons.folder_open, Colors.teal,
          const DocumentsTab()),
      _Feature('Generate Report', Icons.summarize, AppTheme.greenVerified,
          const ComplianceReportTab()),
      _Feature('CAPA Tracker', Icons.task_alt, Colors.blueGrey,
          const CapasTabWrapper()),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRRAM COMPLIANCE FEATURES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: features.length,
            itemBuilder: (context, i) {
              final f = features[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: AppTheme.nearBlackCoal,
                          foregroundColor: Colors.white,
                          title: Text(f.label,
                              style: const TextStyle(fontSize: 15)),
                        ),
                        backgroundColor: AppTheme.offWhiteBackground,
                        body: f.screen,
                      ),
                    ),
                  );
                },
                child: Container(
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: f.color.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(f.icon, color: f.color, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        f.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// Thin wrapper so CapasTab can be pushed from a hub card
class CapasTabWrapper extends StatelessWidget {
  const CapasTabWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    // Import from shared
    return const _CapasTabPlaceholder();
  }
}

class _CapasTabPlaceholder extends StatelessWidget {
  const _CapasTabPlaceholder();
  @override
  Widget build(BuildContext context) {
    // The real tab is in shared/capas_tab.dart; this lets us navigate to it
    return const Center(
      child: Text('CAPA Tracker (see bottom nav → CAPAs tab)'),
    );
  }
}

class _Feature {
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;
  _Feature(this.label, this.icon, this.color, this.screen);
}
