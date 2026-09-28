import 'package:flutter/material.dart';
import '../screens/shared/sos_beacon_screen.dart';
import '../services/sos_service.dart';
import '../theme/app_theme.dart';

class SOSAlertBanner extends StatelessWidget {
  final VoidCallback? onOpenMap;

  const SOSAlertBanner({super.key, this.onOpenMap});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SOSService.instance,
      builder: (context, child) {
        final isOwnActive = SOSService.instance.isSOSActive;
        final networkBeacons = SOSService.instance.networkBeacons;

        if (!isOwnActive && networkBeacons.isEmpty) {
          return const SizedBox.shrink();
        }

        if (isOwnActive) {
          final pos = SOSService.instance.currentPosition;
          final latText = pos != null
              ? '${pos.latitude.toStringAsFixed(4)}°, ${pos.longitude.toStringAsFixed(4)}°'
              : 'Unavailable';

          return Container(
            width: double.infinity,
            color: const Color(0xFFDC2626),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.sensors, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'LOCAL SOS SESSION ACTIVE ON THIS DEVICE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'GPS: $latText · ${SOSService.instance.signalSynced ? 'Server acknowledged' : 'Saved locally · awaiting server'}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SOSBeaconScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.redDanger,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 30),
                  ),
                  child: const Text(
                    'MANAGE SOS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }

        final target = networkBeacons.first;

        return Container(
          width: double.infinity,
          color: const Color(0xFF7F1D1D),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.amberAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.black,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'REMOTE SOS: ${target.minerName} (${target.role})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${target.distanceMeters == null ? 'Distance unknown' : '${target.distanceMeters}m approximate'} · ${target.locationName} · ${target.isBleAirTagMesh ? 'Direct BLE' : 'Mine server'}${target.rssi == null ? '' : ' · RSSI ${target.rssi} dBm'}',
                      style: TextStyle(color: Colors.red[100], fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (onOpenMap != null)
                ElevatedButton(
                  onPressed: onOpenMap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amberAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    minimumSize: const Size(0, 30),
                  ),
                  child: const Text(
                    'TRACK ON MAP',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
