import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../services/mesh_sos_service.dart';
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
  bool _sosActive = false;
  String _sosStatusMessage = '';

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
  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: AppTheme.amberAccent, size: 24),
                const SizedBox(width: 10),
                const Text('Contractor Compliance Alerts',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            _buildNotificationItem('VTC Expiry Warning', 'Contractor #4 - 3 workers due for VTC renewal', AppTheme.redDanger),
            _buildNotificationItem('Offline Mesh Sync Complete', '14 observations synced via Wi-Fi Direct relay', AppTheme.greenVerified),
            _buildNotificationItem('DGMS Statutory Return Due', 'Monthly Form IV return deadline in 3 days', AppTheme.amberAccent),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(15),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ],
      ),
    );
  }

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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CoalNetra Admin',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            overflow: TextOverflow.ellipsis),
                        Text('Contractor Management Portal',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: AppTheme.amberAccent),
                    onPressed: () => _showNotificationsModal(context),
                  ),
                ],
              ),
            ),
            if (_selectedIndex == 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildQuickStat('4', 'Active Sites', Colors.blue),
                    const SizedBox(width: 8),
                    _buildQuickStat('12', 'Open CAPAs', Colors.orange),
                    const SizedBox(width: 8),
                    _buildQuickStat('98%', 'Safety Score', Colors.green),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // SOS status strip
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
            Expanded(child: IndexedStack(index: _selectedIndex, children: _tabs)),
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
