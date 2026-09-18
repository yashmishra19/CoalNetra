import 'package:flutter/material.dart';
import '../../models/user_role.dart';
import '../../services/mesh_sos_service.dart';
import '../../theme/app_theme.dart';
import '../shared/grievances_tab.dart';
import '../shared/observations_tab.dart';
import 'worker_home_tab.dart';
import '../sirdar/sirdar_profile_tab.dart';
import 'package:provider/provider.dart';

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
      const GrievancesTab(),
      SirdarProfileTab(user: widget.user),
    ];
  }

  Future<void> _triggerSos() async {
    final sosSvc = Provider.of<MeshSosService?>(context, listen: false);
    if (sosSvc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS: Call +91-112'), backgroundColor: AppTheme.redDanger),
      );
      return;
    }
    setState(() { _sosActive = true; _sosStatusMessage = 'Broadcasting SOS…'; });
    try {
      final result = await sosSvc.triggerSos();
      if (mounted) {
        setState(() { _sosStatusMessage = result.anySent ? '✓ SOS sent via ${result.channelSummary}' : 'SOS stored — syncs when online'; });
        Future.delayed(const Duration(seconds: 5), () { if (mounted) setState(() => _sosActive = false); });
      }
    } catch (_) {
      if (mounted) {
        setState(() { _sosStatusMessage = 'SOS stored locally'; });
        Future.delayed(const Duration(seconds: 5), () { if (mounted) setState(() => _sosActive = false); });
      }
    }
  }

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
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.amberAccent,
                      child: Text(
                        widget.user.role.userName.substring(0, 1),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.role.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Mining Worker · Face 3A', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
            // SOS active status strip
            if (_sosActive)
              Container(
                color: AppTheme.redDanger,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_sosStatusMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
              ),
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _tabs),
            ),
            // EMERGENCY SOS bar
            GestureDetector(
              onTap: _triggerSos,
              child: Container(
                width: double.infinity,
                height: 44,
                color: _sosActive ? AppTheme.redDanger.withAlpha(180) : AppTheme.redDanger,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _sosActive ? 'SOS ACTIVE...' : 'EMERGENCY — TAP TO ALERT',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
                    ),
                  ],
                ),
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
