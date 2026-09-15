import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../theme/app_theme.dart';
import '../shared/observations_tab.dart';
import '../observation_form.dart';
import 'sirdar_home_tab.dart';
import 'sirdar_map_tab.dart';
import 'sirdar_profile_tab.dart';

class SirdarHome extends StatefulWidget {
  final MockUser user;
  const SirdarHome({super.key, required this.user});

  @override
  State<SirdarHome> createState() => _SirdarHomeState();
}

class _SirdarHomeState extends State<SirdarHome> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = const [
    SirdarHomeTab(),
    ObservationsTab(), // Acts as 'Tasks'
    SirdarMapTab(),
    SirdarProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      extendBody: true, // Allows the FAB to sit nicely on the notch
      body: SafeArea(
        bottom: false, // Don't pad the bottom so IndexedStack fills the space under nav
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
            
            if (_selectedIndex == 0) ...[
              // Custom Header - Only on Home Tab
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.amberAccent,
                      foregroundImage: NetworkImage("https://i.pravatar.cc/150?u=siram"),
                      child: Text("SR", style: TextStyle(color: Colors.white)),
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
                          "Sirdar · District 4",
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
                    IconButton(
                      icon: Icon(Icons.menu, color: Colors.blueGrey[300]),
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
          // Immediate feedback to show button is active
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Opening Observation Form..."), duration: Duration(milliseconds: 500)),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ObservationFormScreen()),
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
              _buildNavItem(0, Icons.home, "Home"),
              _buildNavItem(1, Icons.assignment_outlined, "Tasks"),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(2, Icons.map_outlined, "Map"),
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
