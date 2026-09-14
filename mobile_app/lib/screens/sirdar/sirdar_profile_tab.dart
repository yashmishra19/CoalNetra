import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SirdarProfileTab extends StatelessWidget {
  const SirdarProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.amberAccent,
                foregroundImage: NetworkImage("https://i.pravatar.cc/150?u=siram"),
                child: Text("SR", style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              Positioned(
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
        const Center(
          child: Column(
            children: [
              Text(
                "S. Ramachandran",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Employee ID: SECL-2024-0492",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildSectionHeader("Work Info"),
        _buildProfileTile(Icons.work_outline, "Designation", "Sirdar (Grade I)"),
        _buildProfileTile(Icons.location_city, "Mine / Unit", "Sardega OCP, District 4"),
        _buildProfileTile(Icons.timer_outlined, "Shift Schedule", "Shift A (06:00 - 14:00)"),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Account & Security"),
        _buildProfileTile(Icons.sync, "Manual Sync", "Last sync: 2 hours ago", trailing: Text("SYNC NOW", style: TextStyle(color: AppTheme.amberAccent, fontWeight: FontWeight.bold, fontSize: 12))),
        _buildProfileTile(Icons.lock_outline, "Change PIN", ""),
        _buildProfileTile(Icons.language, "Language", "English (India)"),
        
        const SizedBox(height: 24),
        _buildSectionHeader("Support"),
        _buildProfileTile(Icons.help_outline, "Help Center", ""),
        _buildProfileTile(Icons.info_outline, "App Version", "v1.0.0+1-release"),
        
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppTheme.redDanger,
            side: const BorderSide(color: AppTheme.redDanger),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("LOG OUT"),
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

  Widget _buildProfileTile(IconData icon, String title, String subtitle, {Widget? trailing}) {
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
      onTap: () {},
    );
  }
}
