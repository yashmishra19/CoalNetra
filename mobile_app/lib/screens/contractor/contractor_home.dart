import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../shared/dashboard_tab.dart';
import '../shared/observations_tab.dart';
import '../shared/capas_tab.dart';
import '../shared/grievances_tab.dart';
import '../sirdar/sirdar_profile_tab.dart';
import 'contractors_tab.dart';

class ContractorHome extends StatefulWidget {
  final MockUser user;
  const ContractorHome({super.key, required this.user});

  @override
  State<ContractorHome> createState() => _ContractorHomeState();
}

class _ContractorHomeState extends State<ContractorHome> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    DashboardTab(),
    ObservationsTab(),
    CapasTab(),
    ContractorsTab(),
    GrievancesTab(),
    SirdarProfileTab(),
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
                        "CoalGov Admin",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "Contractor Management Portal",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.notifications_none),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            // Stats Row
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildQuickStat("4", "Active Sites", Colors.blue),
                    const SizedBox(width: 8),
                    _buildQuickStat("12", "Open CAPAs", Colors.orange),
                    const SizedBox(width: 8),
                    _buildQuickStat("98%", "Safety Score", Colors.green),
                  ],
                ),
              ),

            const SizedBox(height: 16),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _tabs),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Stats'),
          BottomNavigationBarItem(icon: Icon(Icons.remove_red_eye_outlined), label: 'Safety'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'CAPAs'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Workers'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Grievance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
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
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
