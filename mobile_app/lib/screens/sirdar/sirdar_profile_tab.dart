import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_role.dart';
import '../../services/mesh_sos_service.dart';
import '../../sync/sync_service.dart';
import '../../theme/app_theme.dart';
import '../role_select.dart';

class SirdarProfileTab extends StatefulWidget {
  final MockUser? user;
  const SirdarProfileTab({super.key, this.user});

  @override
  State<SirdarProfileTab> createState() => _SirdarProfileTabState();
}

class _SirdarProfileTabState extends State<SirdarProfileTab> {
  bool _isSyncing = false;
  String _lastSyncMsg = 'Tap SYNC NOW to force push';
  bool _sosBroadcasting = false;

  Future<void> _triggerManualSync() async {
    final syncSvc = Provider.of<SyncService?>(context, listen: false);
    if (syncSvc == null) return;

    setState(() {
      _isSyncing = true;
      _lastSyncMsg = 'Syncing offline records...';
    });

    try {
      final res = await syncSvc.sync();
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncMsg = '✓ Synced ${res.pushed} record(s) at ${TimeOfDay.now().format(context)}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Sync Complete: ${res.pushed} item(s) sent to server'),
            backgroundColor: AppTheme.greenVerified,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncMsg = 'Sync failed: network or server offline';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync Error: $e'),
            backgroundColor: AppTheme.amberAccent,
          ),
        );
      }
    }
  }

  Future<void> _triggerSosFromProfile() async {
    final sosSvc = Provider.of<MeshSosService?>(context, listen: false);
    if (sosSvc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SOS service unavailable'), backgroundColor: AppTheme.redDanger),
      );
      return;
    }

    setState(() => _sosBroadcasting = true);
    try {
      final res = await sosSvc.triggerSos();
      if (mounted) {
        setState(() => _sosBroadcasting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res.anySent
                ? '🚨 EMERGENCY SOS BROADCASTED! (${res.channelSummary})'
                : '🚨 SOS saved locally — will sync when network connects'),
            backgroundColor: AppTheme.redDanger,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _sosBroadcasting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS error: $e'), backgroundColor: AppTheme.redDanger),
        );
      }
    }
  }

  void _showApiUrlDialog() {
    final controller = TextEditingController(text: SyncService.effectiveApiBaseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configure Backend API URL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter host machine IP or backend URL (e.g. http://192.168.1.10:5000) for testing on physical phone:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Backend API Base URL',
                hintText: 'http://192.168.x.x:5000',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              SyncService.serverUrlOverride = controller.text.trim();
              Navigator.pop(ctx);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('API URL updated to: ${SyncService.effectiveApiBaseUrl}'),
                  backgroundColor: AppTheme.greenVerified,
                ),
              );
            },
            child: const Text('Save URL'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of KoylaNetra?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.redDanger, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                (route) => false,
              );
            },
            child: const Text('LOG OUT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final userName = user?.role.userName ?? 'S. Ramachandran';
    final userRoleName = user?.role.displayName ?? 'Sirdar (Grade I)';
    final empId = user?.role == UserRole.mineWorker
        ? 'MW-2024-0812'
        : user?.role == UserRole.contractorSup
            ? 'SUP-2024-1102'
            : 'SECL-2024-0492';
    final initialStr = userName.isNotEmpty ? userName.substring(0, 1) : 'U';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: AppTheme.amberAccent,
                child: Text(initialStr, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppTheme.amberAccent,
                  child: Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              Text(
                userName,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "$userRoleName · Employee ID: $empId",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // ── EMERGENCY SOS BUTTON IN PROFILE SCREEN
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton.icon(
            onPressed: _sosBroadcasting ? null : _triggerSosFromProfile,
            icon: _sosBroadcasting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.warning, color: Colors.white, size: 20),
            label: Text(
              _sosBroadcasting ? "BROADCASTING SOS..." : "TRIGGER EMERGENCY DISTRESS SOS",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redDanger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        _buildSectionHeader("Work Profile Info"),
        _buildProfileTile(Icons.work_outline, "Designation / Role", userRoleName),
        _buildProfileTile(Icons.location_city, "Assigned Unit", "Sardega OCP, District 4"),
        _buildProfileTile(Icons.timer_outlined, "Shift Schedule", "Shift A (06:00 - 14:00)"),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Account & Database Sync"),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: _isSyncing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync, color: AppTheme.amberAccent),
          ),
          title: const Text("Manual Sync Database", style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(_lastSyncMsg, style: const TextStyle(fontSize: 12)),
          trailing: OutlinedButton(
            onPressed: _isSyncing ? null : _triggerManualSync,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.amberAccent,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            ),
            child: const Text("SYNC NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          ),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.dns_outlined, color: Colors.blueGrey),
          ),
          title: const Text("Backend API Endpoint", style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(SyncService.effectiveApiBaseUrl, style: const TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.edit, size: 18, color: Colors.grey),
          onTap: _showApiUrlDialog,
        ),
        _buildProfileTile(Icons.language, "Language", "English (India)"),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Support"),
        _buildProfileTile(Icons.help_outline, "Help Center & Emergency Manual", ""),
        _buildProfileTile(Icons.info_outline, "App Version", "v1.0.0+1-release"),
        
        const SizedBox(height: 28),
        ElevatedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text("LOG OUT OF COALNETRA"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.redDanger,
            side: const BorderSide(color: AppTheme.redDanger),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 100), // Space for FAB
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.blueGrey),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
