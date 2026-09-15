import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SirdarHomeTab extends StatelessWidget {
  const SirdarHomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S INSPECTION SCHEDULE",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildScheduleItem(
            context,
            "Face Gallery 3A",
            "08:30 AM - 10:00 AM",
            "Statutory Inspection",
            true,
          ),
          _buildScheduleItem(
            context,
            "Conveyor Belt 4",
            "11:00 AM - 12:00 PM",
            "Maintenance Audit",
            false,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ASSIGNED CAPAs",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey[600],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text("3 PENDING", style: TextStyle(color: AppTheme.redDanger, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildCapaCard(
            "Fix loose roof bolt at Junction 2",
            "Due: Today, 14:00",
            "URGENT",
            AppTheme.redDanger,
          ),
          const SizedBox(height: 12),
          _buildCapaCard(
            "Replace worn fire extinguisher",
            "Due: 15 Sep",
            "MEDIUM",
            AppTheme.amberAccent,
          ),
          const SizedBox(height: 24),
          Text(
            "STATUTORY READINGS",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildStatutoryGrid(),
          const SizedBox(height: 24),
          Text(
            "Section Risk Level",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _buildRiskIndicator(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, String location, String time, String type, bool completed) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: completed ? AppTheme.greenVerified.withAlpha(50) : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: completed ? AppTheme.greenVerified.withAlpha(20) : AppTheme.cobaltBlue.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed ? Icons.check : Icons.pending_actions,
              color: completed ? AppTheme.greenVerified : AppTheme.cobaltBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(location, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("$time • $type", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          if (!completed)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cobaltBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                minimumSize: const Size(60, 30),
              ),
              child: const Text("START", style: TextStyle(fontSize: 10)),
            ),
        ],
      ),
    );
  }

  Widget _buildCapaCard(String title, String dueDate, String priority, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(priority, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
              Text(dueDate, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt, size: 14),
                label: const Text("CLOSE WITH PHOTO", style: TextStyle(fontSize: 10)),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.0,
      children: [
        _buildStatTile(Icons.air, "GAS", "0.02%"),
        _buildStatTile(Icons.grain, "DUST", "1.2 mg"),
        _buildStatTile(Icons.water_drop, "WATER", "240L"),
      ],
    );
  }

  Widget _buildStatTile(IconData icon, String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.cobaltBlue, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.greenVerified.withAlpha(200), AppTheme.greenVerified],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield, color: Colors.white, size: 40),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("STABLE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
              Text("Normal operation conditions", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
