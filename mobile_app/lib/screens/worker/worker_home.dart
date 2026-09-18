import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import '../shared/grievances_tab.dart';
import '../shared/observations_tab.dart';
import 'worker_home_tab.dart';
import '../sirdar/sirdar_profile_tab.dart';
import 'package:provider/provider.dart';

import '../sirdar/sirdar_map_tab.dart';

class WorkerHome extends StatefulWidget {
  final MockUser user;
  const WorkerHome({super.key, required this.user});

  @override
  State<WorkerHome> createState() => _WorkerHomeState();
}

class _WorkerHomeState extends State<WorkerHome> {
  int _selectedIndex = 0;
  bool _sosActive = false;
  String _sosStatusMessage = '';

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const WorkerHomeTab(),
      const ObservationsTab(),
      const SirdarMapTab(),
      const GrievancesTab(),
      SirdarProfileTab(user: widget.user),
    ];
  }

  Future<void> _triggerSos() async {
    final appServices = Provider.of<AppServices>(context, listen: false);
    final sosSvc = appServices.meshSosService;

    if (sosSvc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS: Call +91-112'), backgroundColor: AppTheme.redDanger),
      );
      return;
    }

    setState(() {
      _sosActive = true;
      _sosStatusMessage = '🚨 Broadcasting SOS over Cellular, WiFi & Bluetooth…';
    });

    try {
      final result = await sosSvc.triggerSos();
      if (mounted) {
        setState(() {
          _sosStatusMessage = result.anySent
              ? '✓ SOS SENT via ${result.channelSummary}'
              : 'SOS stored in SQLite — will push when online';
        });
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) setState(() => _sosActive = false);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _sosStatusMessage = 'SOS stored locally in DB'; });
        Future.delayed(const Duration(seconds: 6), () {
          if (mounted) setState(() => _sosActive = false);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenW = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      body: SafeArea(
        // Let bottom nav handle its own safe-area padding
        bottom: false,
        child: Column(
          children: [
            // ── Top Header with Worker Info + RED SOS PANIC BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.amberAccent,
                    child: Text(
                      widget.user.role.userName.isNotEmpty
                          ? widget.user.role.userName.substring(0, 1)
                          : 'P',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.user.role.userName.isNotEmpty
                              ? widget.user.role.userName
                              : 'P. Kumar',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('Mining Worker · Face 3A',
                            style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // PROMINENT RED SOS PANIC BUTTON
                  ElevatedButton.icon(
                    onPressed: _triggerSos,
                    icon: const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.white),
                    label: const Text('SOS',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.redDanger,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Live SOS Alert Banner
            if (_sosActive)
              Container(
                width: double.infinity,
                color: AppTheme.redDanger,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        _sosStatusMessage,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),

            // ── Tab Content
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _tabs),
            ),

            // ── FULL-WIDTH RED EMERGENCY SOS BUTTON
            GestureDetector(
              onTap: _triggerSos,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: _sosActive ? AppTheme.redDanger.withAlpha(200) : AppTheme.redDanger,
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.redDanger.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, -2)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _sosActive
                            ? 'DISTRESS SOS ACTIVE & BROADCASTING'
                            : screenW < 360
                                ? '🚨 EMERGENCY — ALERT MINE STAFF'
                                : '🚨 EMERGENCY — TAP TO ALERT ALL MINE STAFF',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        // Responsive height: nav items + system bottom inset
        padding: EdgeInsets.only(bottom: bottomPad > 0 ? bottomPad : 4),
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, "Home"),
              _buildNavItem(1, Icons.assignment_outlined, Icons.assignment, "Safety"),
              _buildNavItem(2, Icons.map_outlined, Icons.map, "Map"),
              _buildNavItem(3, Icons.report_problem_outlined, Icons.report_problem, "Grievance"),
              _buildNavItem(4, Icons.person_outline, Icons.person, "Profile"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppTheme.amberAccent : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? AppTheme.amberAccent : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
