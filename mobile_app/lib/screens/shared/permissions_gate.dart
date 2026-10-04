import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/app_services.dart';
import '../../theme/app_theme.dart';
import 'package:provider/provider.dart';

class PermissionsGateScreen extends StatefulWidget {
  final Widget nextScreen;
  final String role;
  final String userId;
  final String userName;

  const PermissionsGateScreen({
    super.key,
    required this.nextScreen,
    required this.role,
    required this.userId,
    required this.userName,
  });

  @override
  State<PermissionsGateScreen> createState() => _PermissionsGateScreenState();
}

class _PermissionsGateScreenState extends State<PermissionsGateScreen> {
  bool _isRequesting = false;
  String? _errorMessage;
  bool _hasAutoProceeded = false;

  // Store status per index
  final List<PermissionStatus?> _statuses = List.filled(4, null);

  // User override state — allows user to deselect/disable any permission in app
  final List<bool> _userEnabled = List.filled(4, true);

  // ── Permission definitions ─────────────────────────────────────────────
  static const _titles = [
    'Location (Always)',
    'Nearby Wi-Fi Devices',
    'Bluetooth & Nearby Scanning',
    'Emergency Notifications',
  ];

  static const _subtitles = [
    'Required for GPS tracking and accurate SOS pinpointing in underground/opencast mines.',
    'Required for peer-to-peer Wi-Fi SOS mesh network when mobile towers have no signal.',
    'Required for Bluetooth Low Energy mesh relay to forward distress signals between nearby devices.',
    'Required to sound loud distress alarms and emergency alerts even when the screen is locked.',
  ];

  static const _icons = [
    Icons.location_on,
    Icons.wifi_tethering,
    Icons.bluetooth_searching,
    Icons.notifications_active,
  ];

  static const _required = [true, true, true, false];

  Permission _permissionAt(int i) {
    switch (i) {
      case 0: return Permission.locationWhenInUse;
      case 1: return Permission.nearbyWifiDevices;
      case 2: return Permission.bluetoothScan;
      default: return Permission.notification;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAndMaybeAutoProceed();
  }

  /// Check whether all required permissions (indices 0, 1, 2) are already
  /// granted. If so, skip the gate entirely and proceed directly.
  Future<void> _checkAndMaybeAutoProceed() async {
    await _checkCurrentStatuses();
    if (!mounted || _hasAutoProceeded) return;

    // Check if all REQUIRED permissions are already granted at OS level
    final allRequiredGranted = List.generate(4, (i) => i)
        .where((i) => _required[i])
        .every((i) => _statuses[i]?.isGranted ?? false);

    if (allRequiredGranted) {
      _hasAutoProceeded = true;
      await _proceed();
    }
  }

  Future<PermissionStatus> _checkSinglePermission(int i) async {
    try {
      final status = await _permissionAt(i).status;
      if (status.isGranted) return PermissionStatus.granted;

      // Legacy Android fallback checks (Android < 13 / API < 33)
      final locationGranted = _statuses[0]?.isGranted ?? false;

      if (i == 1 && locationGranted) {
        return PermissionStatus.granted;
      }
      if (i == 2 && locationGranted && (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied)) {
        return PermissionStatus.granted;
      }
      if (i == 3 && (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied)) {
        return PermissionStatus.granted;
      }

      return status;
    } catch (_) {
      return PermissionStatus.granted;
    }
  }

  Future<void> _checkCurrentStatuses() async {
    for (int i = 0; i < 4; i++) {
      final status = await _checkSinglePermission(i);
      if (mounted) setState(() => _statuses[i] = status);
    }
  }

  /// Toggle permission ON / OFF on card tap
  Future<void> _togglePermission(int index) async {
    if (_isRequesting) return;

    final isOsGranted = _statuses[index]?.isGranted ?? false;
    final isCurrentlyActive = isOsGranted && _userEnabled[index];

    if (isCurrentlyActive) {
      // User wants to DESELECT / TURN OFF this permission in app
      setState(() {
        _userEnabled[index] = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_titles[index]} disabled for this session.'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.blueGrey.shade800,
            action: SnackBarAction(
              label: 'Revoke in Settings',
              textColor: AppTheme.amberAccent,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else {
      // User wants to ENABLE / SELECT this permission
      setState(() {
        _userEnabled[index] = true;
      });

      if (!isOsGranted) {
        // Request OS permission if not yet granted
        await _requestSingle(index);
      } else if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ ${_titles[index]} re-enabled.'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppTheme.greenVerified,
          ),
        );
      }
    }
  }

  Future<void> _requestSingle(int index) async {
    if (_isRequesting) return;

    final currentStatus = _statuses[index];
    if (currentStatus?.isPermanentlyDenied ?? false) {
      _showOpenSettingsDialog(_titles[index]);
      return;
    }

    setState(() { _isRequesting = true; _errorMessage = null; });
    try {
      PermissionStatus result;
      try {
        result = await _permissionAt(index).request();
      } catch (_) {
        result = PermissionStatus.denied;
      }

      if (!result.isGranted) {
        result = await _checkSinglePermission(index);
      }

      if (mounted) {
        setState(() {
          _statuses[index] = result;
          if (result.isGranted) {
            _userEnabled[index] = true;
          }
          _isRequesting = false;
        });
      }

      if (result.isPermanentlyDenied && mounted) {
        _showOpenSettingsDialog(_titles[index]);
      }
    } catch (e) {
      if (mounted) setState(() { _isRequesting = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _grantAllPermissions() async {
    if (_isRequesting) return;
    setState(() { _isRequesting = true; _errorMessage = null; });

    try {
      for (int i = 0; i < 4; i++) {
        _userEnabled[i] = true;
        if (_statuses[i]?.isGranted ?? false) continue;

        PermissionStatus result;
        try {
          result = await _permissionAt(i).request();
        } catch (_) {
          result = PermissionStatus.denied;
        }

        if (!result.isGranted) {
          result = await _checkSinglePermission(i);
        }

        if (mounted) setState(() => _statuses[i] = result);
        await Future.delayed(const Duration(milliseconds: 250));
      }

      if (mounted) setState(() => _isRequesting = false);

      final locationGranted = _statuses[0]?.isGranted ?? false;
      if (locationGranted) {
        await _proceed();
      }
    } catch (e) {
      if (mounted) setState(() { _isRequesting = false; _errorMessage = e.toString(); });
    }
  }

  Future<void> _proceed() async {
    if (!mounted) return;
    setState(() { _isRequesting = true; _errorMessage = null; });

    try {
      final appServices = Provider.of<AppServices>(context, listen: false);
      await appServices.initForRole(
        role: widget.role,
        userId: widget.userId,
        userName: widget.userName,
      );
    } catch (e) {
      debugPrint('AppServices init error: $e');
    }

    if (!mounted) return;
    setState(() => _isRequesting = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  void _showOpenSettingsDialog(String permissionName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text('Manage System Permission', style: TextStyle(color: Colors.white)),
        content: Text(
          '$permissionName OS permissions can be enabled or revoked directly in your device Settings.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await openAppSettings();
              await Future.delayed(const Duration(milliseconds: 500));
              await _checkCurrentStatuses();
            },
            child: const Text('Open System Settings', style: TextStyle(color: AppTheme.amberAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = List.generate(4, (i) => i)
        .where((i) => _userEnabled[i] && (_statuses[i]?.isGranted ?? false))
        .length;

    final locationActive = _userEnabled[0] && (_statuses[0]?.isGranted ?? false);

    return Scaffold(
      backgroundColor: AppTheme.nearBlackCoal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ── Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.amberAccent.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_outlined, color: AppTheme.amberAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CoalNetra Access Gate',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Tap any permission card to enable or deselect sensor ($activeCount/4 Active)',
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PERMISSIONS & SAFETY SENSORS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.amberAccent, letterSpacing: 1.1),
                  ),
                  TextButton.icon(
                    onPressed: () => openAppSettings(),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 20)),
                    icon: const Icon(Icons.settings, size: 13, color: Colors.white54),
                    label: const Text('OS Settings', style: TextStyle(fontSize: 11, color: Colors.white54)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Error message
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent, fontSize: 11))),
                    ],
                  ),
                ),

              // ── Permission list with Switch & deselect support
              Expanded(
                child: ListView.separated(
                  itemCount: 4,
                  separatorBuilder: (_, _x) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final status = _statuses[i];
                    final isOsGranted = status?.isGranted ?? false;
                    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;
                    final isUserEnabled = _userEnabled[i];
                    final isActive = isOsGranted && isUserEnabled;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _togglePermission(i),
                        borderRadius: BorderRadius.circular(12),
                        splashColor: AppTheme.amberAccent.withAlpha(30),
                        highlightColor: Colors.white10,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.greenVerified.withAlpha(20)
                                : isUserEnabled
                                    ? Colors.white.withAlpha(15)
                                    : Colors.black45,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isActive
                                  ? AppTheme.greenVerified
                                  : isUserEnabled
                                      ? (isPermanentlyDenied ? Colors.redAccent.withAlpha(100) : AppTheme.amberAccent.withAlpha(80))
                                      : Colors.white12,
                              width: isActive ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(_icons[i],
                                  color: isActive
                                      ? AppTheme.greenVerified
                                      : isUserEnabled
                                          ? AppTheme.amberAccent
                                          : Colors.white30,
                                  size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [
                                      Flexible(
                                        child: Text(_titles[i],
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: isUserEnabled ? Colors.white : Colors.white38),
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                      const SizedBox(width: 6),
                                      if (_required[i])
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: AppTheme.amberAccent.withAlpha(isActive ? 40 : 15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text('Required',
                                              style: TextStyle(
                                                  fontSize: 9,
                                                  color: isActive ? AppTheme.amberAccent : Colors.white38,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                    ]),
                                    const SizedBox(height: 4),
                                    Text(_subtitles[i],
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: isUserEnabled ? Colors.white60 : Colors.white30,
                                            height: 1.3)),
                                    const SizedBox(height: 6),
                                    Text(
                                      isActive
                                          ? '✓ Active — Tap card to deselect'
                                          : !isUserEnabled
                                              ? '✕ Deselected by User — Tap to enable'
                                              : isPermanentlyDenied
                                                  ? 'Blocked in System — Tap for Settings'
                                                  : 'Tap card to grant permission',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? AppTheme.greenVerified
                                            : !isUserEnabled
                                                ? Colors.white38
                                                : isPermanentlyDenied
                                                    ? Colors.redAccent
                                                    : AppTheme.amberAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Interactive Switch / Checkbox visual
                              status == null
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 2))
                                  : Transform.scale(
                                      scale: 0.85,
                                      child: Switch(
                                        value: isActive,
                                        onChanged: (_) => _togglePermission(i),
                                        activeColor: AppTheme.greenVerified,
                                        activeTrackColor: AppTheme.greenVerified.withAlpha(80),
                                        inactiveThumbColor: isUserEnabled ? AppTheme.amberAccent : Colors.white30,
                                        inactiveTrackColor: Colors.white10,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 14),

              // ── Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRequesting
                      ? null
                      : () {
                          if (activeCount == 0) {
                            _grantAllPermissions();
                          } else {
                            _proceed();
                          }
                        },
                  icon: _isRequesting
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Icon(activeCount == 4 ? Icons.arrow_forward : activeCount > 0 ? Icons.check_circle_outline : Icons.security,
                          color: Colors.black),
                  label: Text(
                    _isRequesting
                        ? 'INITIALIZING...'
                        : activeCount == 4
                            ? 'PROCEED TO COALNETRA'
                            : activeCount > 0
                                ? 'PROCEED WITH $activeCount/4 SENSORS ACTIVE'
                                : 'ENABLE ALL PERMISSIONS AT ONCE',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black, letterSpacing: 0.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeCount > 0 ? AppTheme.amberAccent : Colors.grey.shade400,
                    disabledBackgroundColor: AppTheme.amberAccent.withAlpha(80),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Skip & System Settings shortcuts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => openAppSettings(),
                    child: const Text('Open Android Settings', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ),
                  TextButton(
                    onPressed: _isRequesting ? null : () => _proceed(),
                    child: Text(
                      locationActive ? 'Skip Optional & Proceed' : 'Proceed Offline',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

