import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../shared/observations_tab.dart';
import '../observation_form.dart';
import '../shared/ai_risk_score_tab.dart';
import '../shared/statutory_compliance_tab.dart';
import '../shared/violation_workflow_tab.dart';
import '../shared/compliance_alerts_tab.dart';
import '../shared/escalation_tab.dart';
import '../shared/documents_tab.dart';
import '../shared/compliance_report_tab.dart';
import '../../widgets/sos_alert_banner.dart';
import '../shared/sos_beacon_screen.dart';
import 'sirdar_home_tab.dart';
import 'mine_gis_map_tab.dart';
import 'sirdar_profile_tab.dart';
import 'inspection_checklist_screen.dart';
import 'geo_inspection_screen.dart';

class SirdarHome extends StatefulWidget {
  final MockUser user;
  const SirdarHome({super.key, required this.user});

  @override
  State<SirdarHome> createState() => _SirdarHomeState();
}

class _SirdarHomeState extends State<SirdarHome> {
  int _selectedIndex = 0;

  // 10 tabs for Sirdar covering all TRRAM features
  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home_outlined, Icons.home, 'Home'),
    _NavItem(Icons.assignment_outlined, Icons.assignment, 'Compliance'),
    _NavItem(Icons.map_outlined, Icons.map, 'Map'),
    _NavItem(Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Sync Status Bar
            Container(
              width: double.infinity,
              color: AppTheme.amberAccent,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Text(
                "Offline · 3 records queued for sync",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            SOSAlertBanner(onOpenMap: () => setState(() => _selectedIndex = 2)),

            if (_selectedIndex == 0) ...[
              // Custom Header - Only on Home Tab
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.amberAccent,
                      foregroundImage:
                          NetworkImage("https://i.pravatar.cc/150?u=siram"),
                      child: Text("SR",
                          style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.role.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Sirdar · Sardega OCP",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // SOS Emergency Beacon Button
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
                    // Notification bell with alert badge
                    Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none,
                              color: Colors.blueGrey[300]),
                          onPressed: () => _showAlertSheet(context),
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
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.blueGrey[300]),
                      onPressed: () => _showQuickActions(context),
                    ),
                  ],
                ),
              ),
            ],

            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const SirdarHomeTab(),
                  const _SirdarComplianceHub(),
                  const MineGISMapTab(),
                  SirdarProfileTab(user: widget.user),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Opening Inspection Form..."),
                duration: Duration(milliseconds: 500)),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ObservationFormScreen()),
          );
        },
        backgroundColor: AppTheme.amberAccent,
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0),
              _buildNavItem(1),
              const SizedBox(width: 40), // FAB space
              _buildNavItem(2),
              _buildNavItem(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? item.activeIcon : item.icon,
            color: isSelected ? AppTheme.amberAccent : Colors.grey,
          ),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppTheme.amberAccent : Colors.grey,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showAlertSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: 360,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.bolt, color: AppTheme.redDanger),
                  SizedBox(width: 8),
                  Text('Compliance Alerts',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _alertTile('DGMS Report overdue in 3 days', 'CRITICAL',
                AppTheme.redDanger),
            _alertTile('Boiler cert expiring in 7 days', 'HIGH',
                Colors.deepOrange),
            _alertTile('Gas pattern detected – Face 3A', 'RECURRING',
                Colors.purple),
            _alertTile('Conveyor inspection due tomorrow', 'MEDIUM',
                AppTheme.amberAccent),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(String title, String badge, Color color) {
    return ListTile(
      dense: true,
      leading:
          Icon(Icons.circle, color: color, size: 10),
      title: Text(title, style: const TextStyle(fontSize: 13)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withAlpha(25),
            borderRadius: BorderRadius.circular(6)),
        child: Text(badge,
            style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
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
            const Text('Quick Actions',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _quickAction(
                  context,
                  Icons.checklist,
                  'Inspection\nChecklist',
                  AppTheme.cobaltBlue,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const InspectionChecklistScreen())),
                ),
                _quickAction(
                  context,
                  Icons.gps_fixed,
                  'Geo\nInspection',
                  AppTheme.greenVerified,
                  () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const GeoInspectionScreen())),
                ),
                _quickAction(context, Icons.psychology, 'AI Risk\nScore',
                    Colors.purple, () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 1);
                }),
                _quickAction(context, Icons.campaign, 'Escalation',
                    AppTheme.redDanger, () {
                  Navigator.pop(context);
                  setState(() => _selectedIndex = 1);
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(60)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

/// Sirdar's compliance hub – a scrollable menu of all compliance features
class _SirdarComplianceHub extends StatelessWidget {
  const _SirdarComplianceHub();

  @override
  Widget build(BuildContext context) {
    final features = [
      _Feature('AI Risk Score', Icons.psychology, Colors.purple,
          const AIRiskScoreTab()),
      _Feature('Statutory Compliance', Icons.gavel, AppTheme.cobaltBlue,
          const StatutoryComplianceTab()),
      _Feature('Violation Workflow', Icons.report_problem, AppTheme.redDanger,
          const ViolationWorkflowTab()),
      _Feature('Compliance Alerts', Icons.bolt, AppTheme.amberAccent,
          const ComplianceAlertsTab()),
      _Feature('Escalation System', Icons.campaign, Colors.deepOrange,
          const EscalationTab()),
      _Feature('Documents & OCR', Icons.folder_open, Colors.teal,
          const DocumentsTab()),
      _Feature('Generate Report', Icons.summarize, AppTheme.greenVerified,
          const ComplianceReportTab()),
      _Feature('Observations', Icons.assignment_outlined, Colors.blueGrey,
          const ObservationsTab()),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMPLIANCE FEATURES',
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
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}

class _Feature {
  final String label;
  final IconData icon;
  final Color color;
  final Widget screen;
  _Feature(this.label, this.icon, this.color, this.screen);
}
