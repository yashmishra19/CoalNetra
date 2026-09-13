import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../shared/grievances_tab.dart';
import '../shared/observations_tab.dart';
import 'worker_home_tab.dart';
import '../sirdar/sirdar_profile_tab.dart';

class WorkerHome extends StatefulWidget {
  final MockUser user;
  const WorkerHome({super.key, required this.user});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    WorkerHomeTab(),
    ObservationsTab(),
    GrievancesTab(),
    SirdarProfileTab(), // Reusing profile tab UI
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
                      foregroundImage: NetworkImage("https://i.pravatar.cc/150?u=worker"),
                      child: Text("RW", style: TextStyle(color: Colors.white)),
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
                          "Mining Worker · Face 3A",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.notifications_none, color: Colors.blueGrey[300]),
                      onPressed: () {},
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
        onPressed: () {
          setState(() => _selectedIndex = 2); // Quick jump to Grievances
        },
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
              _buildNavItem(0, Icons.home_outlined, "Home"),
              _buildNavItem(1, Icons.assignment_outlined, "Safety"),
              const SizedBox(width: 40),
              _buildNavItem(2, Icons.report_problem_outlined, "Grievance"),
              _buildNavItem(3, Icons.person_outline, "Profile"),
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
          Icon(
            icon,
            color: isSelected ? AppTheme.amberAccent : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppTheme.amberAccent : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
