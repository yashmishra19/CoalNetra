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
  Map<Permission, PermissionStatus> _statuses = {};

  final List<_PermissionItem> _items = [
    _PermissionItem(
      permission: Permission.locationAlways,
      title: 'Location (Always)',
      subtitle: 'Required for active GPS tracking and accurate SOS emergency pinpointing in underground/opencast mines.',
      icon: Icons.location_on,
      isRequired: true,
    ),
    _PermissionItem(
      permission: Permission.nearbyWifiDevices,
      title: 'Nearby Wi-Fi Devices',
      subtitle: 'Required for peer-to-peer Wi-Fi Direct SOS mesh network when mobile towers have no signal.',
      icon: Icons.wifi_tethering,
      isRequired: true,
    ),
    _PermissionItem(
      permission: Permission.bluetoothScan,
      title: 'Bluetooth & Nearby Scanning',
      subtitle: 'Required for Bluetooth Low Energy mesh relay to forward distress signals between nearby devices.',
      icon: Icons.bluetooth_searching,
      isRequired: true,
    ),
    _PermissionItem(
      permission: Permission.notification,
      title: 'Emergency Notifications',
      subtitle: 'Required to sound loud distress alarms and emergency alerts even when the screen is locked.',
      icon: Icons.notifications_active,
      isRequired: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkCurrentStatuses();
  }

  Future<void> _checkCurrentStatuses() async {
    final Map<Permission, PermissionStatus> current = {};
    for (final item in _items) {
      current[item.permission] = await item.permission.status;
    }
    if (mounted) {
      setState(() => _statuses = current);
    }
  }

  Future<void> _grantAllPermissions() async {
    setState(() => _isRequesting = true);

    try {
      final permissionsToRequest = _items.map((e) => e.permission).toList();
      final Map<Permission, PermissionStatus> results = await permissionsToRequest.request();

      if (mounted) {
        setState(() {
          _statuses = results;
          _isRequesting = false;
        });
      }

      await _proceedIfReady();
    } catch (_) {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Future<void> _proceedIfReady() async {
    if (!mounted) return;

    // Start background services with identity
    final appServices = Provider.of<AppServices>(context, listen: false);
    await appServices.initForRole(
      role: widget.role,
      userId: widget.userId,
      userName: widget.userName,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allRequiredGranted = _items
        .where((i) => i.isRequired)
        .every((i) => _statuses[i.permission]?.isGranted ?? false);

    return Scaffold(
      backgroundColor: AppTheme.nearBlackCoal,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Top Header
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CoalNetra Access Gate',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          'Enable required safety sensors for offline SOS relay',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'PERMISSIONS REQUIRED UNDER ONE ROOF',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.amberAccent, letterSpacing: 1.1),
              ),
              const SizedBox(height: 12),

              // List of Permissions
              Expanded(
                child: ListView.separated(
                  itemCount: _items.length,
                  separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final status = _statuses[item.permission];
                    final isGranted = status?.isGranted ?? false;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isGranted ? AppTheme.greenVerified : Colors.white12,
                          width: isGranted ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(item.icon, color: isGranted ? AppTheme.greenVerified : AppTheme.amberAccent, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    const SizedBox(width: 6),
                                    if (item.isRequired)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: AppTheme.amberAccent.withAlpha(40),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Required', style: TextStyle(fontSize: 9, color: AppTheme.amberAccent, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: const TextStyle(fontSize: 12, color: Colors.white60, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isGranted ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isGranted ? AppTheme.greenVerified : Colors.white38,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRequesting ? null : _grantAllPermissions,
                  icon: _isRequesting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Icon(allRequiredGranted ? Icons.arrow_forward : Icons.security, color: Colors.black),
                  label: Text(
                    _isRequesting
                        ? 'GRANTING PERMISSIONS...'
                        : allRequiredGranted
                            ? 'PROCEED TO COALNETRA'
                            : 'GRANT ALL PERMISSIONS AT ONCE',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black, letterSpacing: 0.8),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.amberAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => _proceedIfReady(),
                  child: const Text(
                    'Skip Optional & Proceed with Defaults',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionItem {
  final Permission permission;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isRequired;

  _PermissionItem({
    required this.permission,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isRequired,
  });
}
