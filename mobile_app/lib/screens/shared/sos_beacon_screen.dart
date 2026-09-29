import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/sos_service.dart';

class SOSBeaconScreen extends StatefulWidget {
  final String userName;
  final String role;

  const SOSBeaconScreen({
    super.key,
    this.userName = 'Mine user',
    this.role = 'Field user',
  });

  @override
  State<SOSBeaconScreen> createState() => _SOSBeaconScreenState();
}

class _SOSBeaconScreenState extends State<SOSBeaconScreen> {
  int _secondsActive = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    SOSService.instance.startNearbyDiscovery();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && SOSService.instance.isSOSActive) {
        setState(() => _secondsActive++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsActive ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsActive % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SOSService.instance,
      builder: (context, child) {
        final active = SOSService.instance.isSOSActive;
        final signalSynced = SOSService.instance.signalSynced;
        final position = SOSService.instance.currentPosition;
        final location = position == null
            ? 'Location unavailable'
            : '${position.latitude.toStringAsFixed(5)}, '
                  '${position.longitude.toStringAsFixed(5)}';

        return Scaffold(
          backgroundColor: const Color(0xFF160909),
          appBar: AppBar(
            backgroundColor: const Color(0xFF7F1D1D),
            foregroundColor: Colors.white,
            title: const Text('SOS status'),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? Icons.sensors : Icons.sensors_off,
                        size: 72,
                        color: active ? Colors.redAccent : Colors.white54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        active
                            ? 'LOCAL SOS ACTIVE - $_formattedTime'
                            : 'SOS INACTIVE',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A1717),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const Text(
                          'Nearby app phones can discover this device by BLE while it is running. GPS updates also queue for mine-server delivery; phones outside radio range only see it after network sync. Keep this screen open for strongest scan and location continuity.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Location: $location',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        active
                            ? '${SOSService.instance.bleError ?? 'BLE beacon active'} · ${signalSynced ? 'server acknowledged' : 'network sync pending'}'
                            : 'No active signal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: signalSynced
                              ? Colors.greenAccent
                              : Colors.amberAccent,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (active)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _confirmCancel,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('Stop local session'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _secondsActive = 0;
                              SOSService.instance.triggerSOS(
                                userName: widget.userName,
                                role: widget.role,
                              );
                            },
                            icon: const Icon(Icons.sensors),
                            label: const Text('Start local session'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop local SOS session?'),
        content: const Text(
          'This only stops this device local tracking session.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue session'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Stop session'),
          ),
        ],
      ),
    );

    if (confirmed == true) SOSService.instance.cancelSOS();
  }
}
