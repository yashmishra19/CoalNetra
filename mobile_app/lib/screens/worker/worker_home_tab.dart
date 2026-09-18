import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../database/database.dart';
import '../../theme/app_theme.dart';

class WorkerHomeTab extends StatefulWidget {
  const WorkerHomeTab({super.key});

  @override
  State<WorkerHomeTab> createState() => _WorkerHomeTabState();
}

class _WorkerHomeTabState extends State<WorkerHomeTab> {
  // PPE checklist state
  final Map<String, ({IconData icon, String label, bool checked, bool mandatory})> _ppeItems = {
    'helmet': (icon: Icons.engineering, label: "Helmet", checked: true, mandatory: true),
    'goggles': (icon: Icons.visibility, label: "Goggles", checked: true, mandatory: false),
    'mask': (icon: Icons.masks, label: "Dust Mask", checked: true, mandatory: true),
    'gloves': (icon: Icons.back_hand, label: "Gloves", checked: false, mandatory: false),
    'boots': (icon: Icons.do_not_step, label: "Safety Boots", checked: true, mandatory: true),
    'lamp': (icon: Icons.flashlight_on, label: "Cap Lamp", checked: true, mandatory: true),
  };

  bool _isBriefingPlaying = false;
  bool _briefingCompleted = false;
  bool _isSubmittingPpe = false;
  bool _attendancePunched = true;

  int get _checkedCount => _ppeItems.values.where((item) => item.checked).length;
  int get _totalCount => _ppeItems.length;

  void _togglePpeItem(String key) {
    setState(() {
      final current = _ppeItems[key]!;
      _ppeItems[key] = (
        icon: current.icon,
        label: current.label,
        checked: !current.checked,
        mandatory: current.mandatory,
      );
    });
  }

  Future<void> _submitPpeDeclaration() async {
    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null) return;

    setState(() => _isSubmittingPpe = true);

    final missingMandatory = _ppeItems.values
        .where((item) => item.mandatory && !item.checked)
        .map((item) => item.label)
        .toList();

    try {
      final uuid = const Uuid().v4();
      final ppeSummary = _ppeItems.values
          .map((item) => '${item.label}: ${item.checked ? "OK" : "MISSING"}')
          .join(', ');

      await db.addObservation(ObservationsCompanion(
        orgId: const drift.Value('CIL-SECL-001'),
        reportedBy: const drift.Value('worker_demo'),
        category: const drift.Value('PPE Compliance Checklist'),
        location: const drift.Value('Face 3A - Entry Gate'),
        clientUuid: drift.Value(uuid),
        trustScore: drift.Value(missingMandatory.isEmpty ? 100.0 : 40.0),
        syncStatus: const drift.Value(0),
      ));

      if (mounted) {
        setState(() => _isSubmittingPpe = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(missingMandatory.isEmpty
                ? '✓ PPE Declaration Signed & Logged to Ledger ($_checkedCount/$_totalCount Items Verified)'
                : '⚠️ Logged with missing gear: ${missingMandatory.join(", ")}'),
            backgroundColor: missingMandatory.isEmpty ? AppTheme.greenVerified : AppTheme.amberAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmittingPpe = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log PPE checklist: $e')),
        );
      }
    }
  }

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
            "DAILY SAFETY BRIEFING",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.grey[700],
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildBriefingCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MY SAFETY GEAR (PPE)",
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.grey[700],
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _checkedCount == _totalCount
                      ? AppTheme.greenVerified.withAlpha(30)
                      : AppTheme.amberAccent.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$_checkedCount/$_totalCount Checked",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _checkedCount == _totalCount ? AppTheme.greenVerified : AppTheme.amberAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPPEGrid(),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSubmittingPpe ? null : _submitPpeDeclaration,
            icon: _isSubmittingPpe
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.verified_user_outlined),
            label: Text(
              _isSubmittingPpe ? "LOGGING PPE CHECK..." : "CONFIRM & SIGN PPE CHECKLIST",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.nearBlackCoal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 80), // Space for FAB & Nav
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
            color: Colors.black.withAlpha(30),
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
                  Text("Shift A · Face 3A", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("06:00 - 14:00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              InkWell(
                onTap: () {
                  setState(() => _attendancePunched = !_attendancePunched);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_attendancePunched ? 'Punched IN for Shift A' : 'Punched OUT'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _attendancePunched
                        ? AppTheme.greenVerified.withAlpha(40)
                        : Colors.red.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _attendancePunched ? AppTheme.greenVerified : Colors.red),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _attendancePunched ? Icons.check_circle : Icons.touch_app,
                        color: _attendancePunched ? AppTheme.greenVerified : Colors.red,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _attendancePunched ? "PUNCHED IN" : "PUNCH ATTENDANCE",
                        style: TextStyle(
                          color: _attendancePunched ? AppTheme.greenVerified : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildBriefingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.amberAccent.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.amberAccent.withAlpha(80)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over, color: AppTheme.amberAccent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Morning Toolbox Talk (Bhashini Audio)",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      "Topic: Methane levels & ventilation in District 4",
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isBriefingPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: AppTheme.amberAccent,
                  size: 40,
                ),
                onPressed: () {
                  setState(() {
                    _isBriefingPlaying = !_isBriefingPlaying;
                    _briefingCompleted = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isBriefingPlaying
                          ? 'Playing Audio Safety Briefing (Hindi / Odia / English)...'
                          : 'Audio Briefing Paused'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          if (_isBriefingPlaying) ...[
            const SizedBox(height: 8),
            const LinearProgressIndicator(color: AppTheme.amberAccent, backgroundColor: Colors.white),
          ],
          if (_briefingCompleted) ...[
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: AppTheme.greenVerified),
                SizedBox(width: 4),
                Text("Safety Briefing Listened & Acknowledged", style: TextStyle(fontSize: 11, color: AppTheme.greenVerified, fontWeight: FontWeight.bold)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPPEGrid() {
    final keys = _ppeItems.keys.toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: keys.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (context, index) {
        final key = keys[index];
        final item = _ppeItems[key]!;
        return _buildPPEItem(key, item.icon, item.label, item.checked, item.mandatory);
      },
    );
  }

  Widget _buildPPEItem(String key, IconData icon, String label, bool checked, bool mandatory) {
    return GestureDetector(
      onTap: () => _togglePpeItem(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: checked ? Colors.white : Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked ? AppTheme.greenVerified : AppTheme.amberAccent,
            width: checked ? 1.5 : 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 28,
                      color: checked ? AppTheme.nearBlackCoal : Colors.grey[600],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: checked ? FontWeight.bold : FontWeight.normal,
                        color: checked ? Colors.black : Colors.red.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (mandatory && !checked)
                      const Text(
                        "REQUIRED",
                        style: TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Icon(
                checked ? Icons.check_circle : Icons.error_outline,
                size: 16,
                color: checked ? AppTheme.greenVerified : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
