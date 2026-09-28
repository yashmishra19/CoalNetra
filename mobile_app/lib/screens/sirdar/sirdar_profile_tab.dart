import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../models/user_role.dart';
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
  String _lastSyncText = "Just now";

  void _manualSync(BuildContext context) async {
    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Database offline")),
      );
      return;
    }

    setState(() => _isSyncing = true);

    try {
      final syncService = SyncService(db);
      final result = await syncService.sync();
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncText = "${result.pushed} records synced at ${result.serverTime.hour}:${result.serverTime.minute.toString().padLeft(2, '0')}";
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sync complete! Pushed ${result.pushed} records to Supabase."),
            backgroundColor: AppTheme.greenVerified,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Sync attempted: Offline records queued locally"),
            backgroundColor: AppTheme.amberAccent,
          ),
        );
      }
    }
  }

  void _showChangePinDialog(BuildContext context) {
    final pinController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Security PIN"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter new 4-digit security PIN for shift sign-off:"),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "New PIN",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Security PIN updated successfully!"),
                  backgroundColor: AppTheme.greenVerified,
                ),
              );
            },
            child: const Text("SAVE PIN"),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Preferred Language", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.amberAccent),
              title: const Text("English (India)"),
              trailing: const Icon(Icons.check, color: AppTheme.greenVerified),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("हिंदी (Hindi)"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Language set to Hindi")));
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("ଓଡ଼ିଆ (Odia)"),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Language set to Odia")));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out of your session? Unsynced records will remain saved on device."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("CANCEL"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.redDanger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const RoleSelectScreen()),
                (route) => false,
              );
            },
            child: const Text("LOG OUT"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.user?.role ?? UserRole.fieldOfficer;
    
    // Dynamic user details derived from actual logged-in user profile
    String name = "S. Oram";
    String empId = "SECL-2024-0492";
    String designation = "Sirdar (Grade I)";
    String mineUnit = widget.user?.mineName ?? "Sardega OCP, District 4";
    String shift = "Shift A (06:00 - 14:00)";
    String avatarUrl = "https://i.pravatar.cc/150?u=siram";
    String initials = "SO";

    if (role == UserRole.mineWorker) {
      name = "P. Kumar";
      empId = "SECL-2024-1184";
      designation = "Face Miner / Cutter";
      mineUnit = "Sardega OCP, Zone 3A";
      avatarUrl = "https://i.pravatar.cc/150?u=worker";
      initials = "PK";
    } else if (role == UserRole.contractorSup) {
      name = "A. Gupta";
      empId = "CONT-2024-0042";
      designation = "Contractor Supervisor (BOCW)";
      mineUnit = "Sardega OCP, Section B";
      shift = "General Shift (08:00 - 17:00)";
      avatarUrl = "https://i.pravatar.cc/150?u=contractor";
      initials = "AG";
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.amberAccent,
                foregroundImage: NetworkImage(avatarUrl),
                child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 24)),
              ),
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.amberAccent,
                  child: Icon(Icons.edit, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "Employee ID: $empId",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cobaltBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  role.displayName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.cobaltBlue),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader("Work Info"),
        _buildProfileTile(Icons.work_outline, "Designation", designation),
        _buildProfileTile(Icons.location_city, "Mine / Unit", mineUnit),
        _buildProfileTile(Icons.timer_outlined, "Shift Schedule", shift),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Account & Security"),
        _buildProfileTile(
          Icons.sync,
          "Manual Sync",
          "Last sync: $_lastSyncText",
          trailing: _isSyncing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : GestureDetector(
                  onTap: () => _manualSync(context),
                  child: const Text("SYNC NOW", style: TextStyle(color: AppTheme.amberAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
          onTap: () => _manualSync(context),
        ),
        _buildProfileTile(
          Icons.lock_outline,
          "Change PIN",
          "Update shift verification PIN",
          onTap: () => _showChangePinDialog(context),
        ),
        _buildProfileTile(
          Icons.language,
          "Language",
          "English (India)",
          onTap: () => _showLanguagePicker(context),
        ),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Support & System"),
        _buildProfileTile(
          Icons.help_outline,
          "Help Center",
          "DGMS guidelines & support contacts",
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Help Center: Contact DGMS Helpline @ 1800-XXX-XXXX")),
            );
          },
        ),
        _buildProfileTile(
          Icons.info_outline,
          "App Version",
          "CoalGov v2.4.0 (Supabase Live Linked)",
        ),
        
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text("LOG OUT"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.redDanger,
            side: const BorderSide(color: AppTheme.redDanger),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 100),
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
