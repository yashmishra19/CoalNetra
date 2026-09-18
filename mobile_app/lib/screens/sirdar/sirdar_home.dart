import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../models/user_role.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import '../shared/observations_tab.dart';
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
  bool _sosActive = false;
  String _sosStatusMessage = '';
  String _currentMode = 'opencast';

  // Real-time pending count from Drift stream
  int _pendingCount = 0;
  Timer? _pendingCountTimer;

  // GPS confidence from LocationService
  String _locationConfidence = 'acquiring...';
  Timer? _locationTimer;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const SirdarHomeTab(),
      const ObservationsTab(),
      const SirdarMapTab(),
      SirdarProfileTab(user: widget.user),
    ];
    _startPollingPendingCount();
    _startPollingLocationStatus();
  }

  @override
  void dispose() {
    _pendingCountTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startPollingPendingCount() {
    _refreshPendingCount();
    _pendingCountTimer = Timer.periodic(const Duration(seconds: 10), (_) => _refreshPendingCount());
  }

  Future<void> _refreshPendingCount() async {
    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null || !mounted) return;
    try {
      final count = await db.getPendingCount();
      if (mounted) setState(() => _pendingCount = count);
    } catch (_) {}
  }

  void _startPollingLocationStatus() {
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final appServices = Provider.of<AppServices>(context, listen: false);
      final locSvc = appServices.locationService;
      if (locSvc == null || !mounted) return;
      final snap = await locSvc.getCurrentSnapshot();
      if (mounted) {
        setState(() {
          _locationConfidence = snap.confidence == 'gps_live' ? 'GPS live' : 'Last known';
        });
      }
    });
  }

  Future<void> _triggerSos() async {
    final appServices = Provider.of<AppServices>(context, listen: false);
    final sosSvc = appServices.meshSosService;
    if (sosSvc == null) {
      _showSosResult('SOS service unavailable. Call +91-112.');
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
              ? '✓ SOS sent via ${result.channelSummary}'
              : 'SOS stored — will send when online';
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _sosActive = false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _sosStatusMessage = 'SOS stored locally — syncs when connected';
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _sosActive = false);
        });
      }
    }
  }

  void _showSosResult(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.redDanger),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Status bar — intrinsic height (no fixed px that clips)
            Container(
              color: AppTheme.graphite,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _timeNow(),
                    style: const TextStyle(color: Color(0xFFCFD9DD), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const Row(children: [
                    Icon(Icons.signal_cellular_4_bar, size: 14, color: Color(0xFFCFD9DD)),
                    SizedBox(width: 6),
                    Icon(Icons.battery_5_bar, size: 14, color: Color(0xFFCFD9DD)),
                  ]),
                ],
              ),
            ),

            // ── App bar
            Container(
              color: AppTheme.graphite,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Shift B', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Demo OCP-1 · Wani Area', style: TextStyle(fontSize: 11.5, color: Colors.grey[400])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.terrain, color: Colors.white, size: 20),
                    onPressed: () {
                      setState(() => _currentMode = _currentMode == 'opencast' ? 'underground' : 'opencast');
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Switched to ${_currentMode.toUpperCase()} mode'),
                        duration: const Duration(milliseconds: 1000),
                      ));
                    },
                  ),
                ],
              ),
            ),

            // ── Sync strip (real pending count + GPS confidence)
            Container(
              color: AppTheme.graphite2,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(23),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _pendingCount > 0 ? AppTheme.amberAccent : AppTheme.greenVerified,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _pendingCount > 0 ? '$_pendingCount pending' : 'Synced',
                          style: const TextStyle(color: Color(0xFFCFD9DD), fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '📍 $_locationConfidence',
                      style: const TextStyle(color: Color(0xFFCFD9DD), fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currentMode == 'opencast' ? 'OC' : 'UG',
                    style: const TextStyle(color: Color(0xFFCFD9DD), fontSize: 12),
                  ),
                  const Spacer(),
                  const Text('4h 12m left', style: TextStyle(color: Color(0xFFCFD9DD), fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // ── SOS active sheet
            if (_sosActive)
              Container(
                color: AppTheme.redDanger,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_sosStatusMessage, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),

            // ── Main tab content
            Expanded(
              child: IndexedStack(index: _selectedIndex, children: _tabs),
            ),

            // ── EMERGENCY button + bottom nav
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _triggerSos,
                  child: Container(
                    width: double.infinity,
                    height: 46,
                    color: _sosActive ? AppTheme.redDanger.withAlpha(180) : AppTheme.redDanger,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.warning, color: Colors.white, size: 17),
                        const SizedBox(width: 9),
                        Text(
                          _sosActive ? 'SOS BROADCASTING...' : 'EMERGENCY',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: AppTheme.panel,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomTab(0, Icons.home_filled, 'Shift'),
                      _buildBottomTab(1, Icons.done_all, 'Actions'),
                      _buildBottomTab(2, Icons.map_outlined, 'Map'),
                      _buildBottomTab(3, Icons.person, 'Profile'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomTab(int index, IconData icon, String label) {
    final bool isSelected = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 21, color: isSelected ? AppTheme.graphite : AppTheme.ink3),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.graphite : AppTheme.ink3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeNow() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
