import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../shared/observations_tab.dart';
import '../shared/grievances_tab.dart';

import '../shared/compliance_alerts_tab.dart';
import '../shared/documents_tab.dart';
import '../shared/sos_beacon_screen.dart';
import '../sirdar/sirdar_profile_tab.dart';
import 'worker_home_tab.dart';

class WorkerHome extends StatefulWidget {
  final MockUser user;
  const WorkerHome({super.key, required this.user});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  int _selectedIndex = 0;

  // Worker sees: Home, Safety Observations, Documents (own certs), Alerts, Grievance, Profile
  List<Widget> get _tabs => [
    const WorkerHomeTab(),
    const ObservationsTab(),
    const DocumentsTab(),      // worker's own certificates / training records
    const ComplianceAlertsTab(), // predictive alerts that affect the worker
    const GrievancesTab(),
    SirdarProfileTab(user: widget.user),
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
            if (_selectedIndex == 0) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.amberAccent,
                      foregroundImage: NetworkImage(
                          "https://i.pravatar.cc/150?u=worker"),
                      child:
                          Text("RW", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.role.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "Mining Worker · Face 3A",
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
                          icon: Icon(Icons.notifications_none,
                              color: Colors.blueGrey[300]),
                          onPressed: () => _showWorkerAlerts(context),
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
            ],
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _tabs,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _selectedIndex = 4), // Quick jump to Grievances
        backgroundColor: AppTheme.amberAccent,
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
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
              _buildNavItem(0, Icons.home_outlined, 'Home'),
              _buildNavItem(1, Icons.assignment_outlined, 'Safety'),
              const SizedBox(width: 40),
              _buildNavItem(3, Icons.bolt_outlined, 'Alerts'),
              _buildNavItem(5, Icons.person_outline, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isSelected ? AppTheme.amberAccent : Colors.grey),
          Text(
            label,
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

  void _showWorkerAlerts(BuildContext context) {
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
            const Text('Your Alerts',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            _alertTile(Icons.medical_information,
                'Medical fitness cert. expires in 30 days', Colors.orange),
            _alertTile(Icons.engineering,
                'Safety training refresher due: 30 Sep', AppTheme.amberAccent),
            _alertTile(Icons.warning,
                'Gas alert in Face 3A – extra care on entry', AppTheme.redDanger),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _alertTile(IconData icon, String text, Color color) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 20),
      title: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
