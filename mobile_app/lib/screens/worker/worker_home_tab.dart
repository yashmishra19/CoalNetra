import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WorkerHomeTab extends StatelessWidget {
  const WorkerHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendanceCard(),
          const SizedBox(height: 24),
          Text(
            "SAFETY BRIEFING",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.amberAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.amberAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.record_voice_over, color: AppTheme.amberAccent, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Morning Toolbox Talk",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Topic: Methane levels in District 4",
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill, color: AppTheme.amberAccent, size: 40),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "MY SAFETY GEAR (PPE)",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 12),
          _buildPPEGrid(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildAttendanceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.nearBlackCoal,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Shift A", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("06:00 - 14:00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.greenVerified.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.greenVerified),
                ),
                child: const Text("PUNCHED IN", style: TextStyle(color: AppTheme.greenVerified, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat("8.5h", "Avg Shift"),
              _buildStat("22", "Days Pres."),
              _buildStat("0", "Incidents"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildPPEGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.9,
      children: [
        _buildPPEItem(Icons.engineering, "Helmet", true),
        _buildPPEItem(Icons.visibility, "Goggles", true),
        _buildPPEItem(Icons.masks, "Mask", true),
        _buildPPEItem(Icons.back_hand, "Gloves", false),
        _buildPPEItem(Icons.do_not_step, "Boots", true),
        _buildPPEItem(Icons.flashlight_on, "Lamp", true),
      ],
    );
  }

  Widget _buildPPEItem(IconData icon, String label, bool checked) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: checked ? AppTheme.nearBlackCoal : Colors.grey[400]),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 11, color: checked ? Colors.black : Colors.grey)),
              ],
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Icon(
              checked ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: checked ? AppTheme.greenVerified : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
