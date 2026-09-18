import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../theme/app_theme.dart';

/// SirdarMapTab — features:
/// 1. Real-time compass heading rotating mine schematic
/// 2. Heading-Up (rotating) vs North-Up (fixed) mode toggle
/// 3. AirTag-style directional SOS distress finder with bearing arrow & distance
class SirdarMapTab extends StatefulWidget {
  const SirdarMapTab({super.key});

  @override
  State<SirdarMapTab> createState() => _SirdarMapTabState();
}

class _SirdarMapTabState extends State<SirdarMapTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Compass stream
  StreamSubscription<CompassEvent>? _compassSubscription;
  double _heading = 0.0; // Heading in degrees (0..360)
  bool _headingUpMode = true; // True = Heading-Up mode, False = North-Up mode

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(_pulseController);

    // Listen to live device compass updates
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        setState(() {
          _heading = event.heading!;
        });
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase?>(context, listen: false);

    return Column(
      children: [
        // Top Toolbar: Search + Heading Mode Toggle + Compass Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search sector or worker...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Compass Toggle Button (Heading-Up vs North-Up)
              Container(
                decoration: BoxDecoration(
                  color: _headingUpMode ? AppTheme.amberAccent : AppTheme.nearBlackCoal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  tooltip: _headingUpMode ? 'Heading-Up (Compass Mode)' : 'North-Up (Fixed)',
                  icon: Icon(
                    _headingUpMode ? Icons.explore : Icons.navigation_outlined,
                    color: _headingUpMode ? Colors.black : Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _headingUpMode = !_headingUpMode);
                  },
                ),
              ),

              const SizedBox(width: 6),
              // Refresh Button
              Container(
                decoration: const BoxDecoration(color: AppTheme.nearBlackCoal, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
                  onPressed: () => setState(() {}),
                ),
              ),
            ],
          ),
        ),

        // Map area with Compass rotation + AirTag Finder
        Expanded(
          child: db == null
              ? const Center(child: Text('Database unavailable'))
              : StreamBuilder<List<LocationPing>>(
                  stream: db.watchRecentLocationPings(),
                  builder: (context, locSnapshot) {
                    return StreamBuilder<List<SosEvent>>(
                      stream: db.watchRecentSosEvents(),
                      builder: (context, sosSnapshot) {
                        final pings = locSnapshot.data ?? [];
                        final sosEvents = sosSnapshot.data ?? [];

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final mapWidth = constraints.maxWidth;
                            final mapHeight = constraints.maxHeight;

                            final rotationAngle = _headingUpMode ? -(_heading * math.pi / 180.0) : 0.0;

                            return Stack(
                              children: [
                                // 1. Rotating Mine Map Container
                                InteractiveViewer(
                                  minScale: 0.5,
                                  maxScale: 4.0,
                                  boundaryMargin: const EdgeInsets.all(250),
                                  child: Transform.rotate(
                                    angle: rotationAngle,
                                    child: Stack(
                                      children: [
                                        // Mine schematic background
                                        Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          color: const Color(0xFFE5ECEF),
                                          child: CustomPaint(painter: _MineSchematicPainter()),
                                        ),

                                        // Default Mine Sector Labels (Counter-rotated text so readable)
                                        _buildSectorLabel("Face 3A (UG)", 0.25, 0.35, mapWidth, mapHeight, rotationAngle),
                                        _buildSectorLabel("Dump-3 Slope", 0.70, 0.25, mapWidth, mapHeight, rotationAngle),
                                        _buildSectorLabel("Haul Road 2", 0.45, 0.60, mapWidth, mapHeight, rotationAngle),
                                        _buildSectorLabel("Sump-1 Dewatering", 0.20, 0.75, mapWidth, mapHeight, rotationAngle),

                                        // Location ping markers
                                        ...pings.take(20).map((ping) => _buildLocationMarker(ping, pings, mapWidth, mapHeight, rotationAngle)),

                                        // SOS markers (pulsing red)
                                        ...sosEvents.take(10).map((sos) => _buildSosMarker(sos, pings, mapWidth, mapHeight, rotationAngle)),
                                      ],
                                    ),
                                  ),
                                ),

                                // 2. Fixed Top-Right Compass Rose Indicator
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: _buildCompassRose(),
                                ),

                                // 3. AirTag-Style SOS Directional Finder Panel if distress active
                                if (sosEvents.isNotEmpty)
                                  Positioned(
                                    bottom: 60,
                                    left: 12,
                                    right: 12,
                                    child: _buildAirTagSosFinder(sosEvents.first, pings),
                                  )
                                else
                                  // Standard Legend when no SOS active
                                  Positioned(
                                    bottom: 12,
                                    left: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(235),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 8)],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          Row(children: [_legendDot(AppTheme.greenVerified), const SizedBox(width: 4), const Text('GPS Live', style: TextStyle(fontSize: 11))]),
                                          Row(children: [_legendDot(AppTheme.amberAccent), const SizedBox(width: 4), const Text('Last Known', style: TextStyle(fontSize: 11))]),
                                          Row(children: [_legendDot(AppTheme.redDanger), const SizedBox(width: 4), const Text('SOS Alert', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.redDanger))]),
                                          Text('${pings.length} Active · ${sosEvents.length} SOS', style: TextStyle(fontSize: 10, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  // AirTag Precision Finding panel showing real-time bearing arrow & distance
  Widget _buildAirTagSosFinder(SosEvent sos, List<LocationPing> pings) {
    // Current observer position (Field officer / self)
    double myLat = 21.4985;
    double myLng = 82.4985;
    if (pings.isNotEmpty) {
      myLat = pings.first.lat;
      myLng = pings.first.lng;
    }

    final targetLat = sos.lat ?? myLat + 0.0015;
    final targetLng = sos.lng ?? myLng + 0.0012;

    final distanceMeters = _calculateDistanceMeters(myLat, myLng, targetLat, targetLng);
    final initialBearingDegrees = _calculateBearingDegrees(myLat, myLng, targetLat, targetLng);

    // Relative angle for direction arrow: Target Bearing minus Device Compass Heading
    final relativeArrowAngleDegrees = initialBearingDegrees - _heading;
    final relativeArrowRadian = relativeArrowAngleDegrees * math.pi / 180.0;

    final cardinalDirection = _degreesToCardinal(initialBearingDegrees);

    Color statusColor;
    if (distanceMeters < 100) {
      statusColor = AppTheme.redDanger;
    } else if (distanceMeters < 500) {
      statusColor = AppTheme.amberAccent;
    } else {
      statusColor = Colors.blueAccent;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.nearBlackCoal,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: statusColor.withAlpha(120), blurRadius: 16, spreadRadius: 2),
        ],
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: statusColor.withAlpha(50), shape: BoxShape.circle),
                child: Icon(Icons.warning, color: statusColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚨 DISTRESS: ${sos.userName ?? sos.triggeredBy}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Role: ${sos.role.toUpperCase()} · Via: ${sos.sentViaChannel}',
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  cardinalDirection,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Big AirTag Directional Arrow + Distance Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Direction Arrow rotates live as user turns device
              Transform.rotate(
                angle: relativeArrowRadian,
                child: Icon(
                  Icons.navigation,
                  size: 42,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${distanceMeters.toStringAsFixed(0)} m',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: statusColor, height: 1.0),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    distanceMeters < 100 ? 'RESCUE CLOSE — IN IMMEDIATE SECTOR' : 'DISTRESS SIGNAL DETECTED NEARBY',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Top-Right Compass Rose showing N/S/E/W and current degree heading
  Widget _buildCompassRose() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.nearBlackCoal.withAlpha(220),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.amberAccent, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 6)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: -(_heading * math.pi / 180.0),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Text('N', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.redDanger)),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text('S', style: TextStyle(fontSize: 9, color: Colors.white70)),
                ),
              ],
            ),
          ),
          Text(
            '${_heading.round()}°',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectorLabel(String label, double relX, double relY, double mapWidth, double mapHeight, double counterRotation) {
    return Positioned(
      left: mapWidth * relX,
      top: mapHeight * relY,
      child: Transform.rotate(
        angle: -counterRotation, // Keep label text upright even when map rotates
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(40),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationMarker(LocationPing ping, List<LocationPing> allPings, double mapWidth, double mapHeight, double counterRotation) {
    final isLive = ping.locationConfidence == 'gps_live';
    final color = isLive ? AppTheme.greenVerified : AppTheme.amberAccent;

    final pos = _projectCoordinates(ping.lat, ping.lng, allPings, mapWidth, mapHeight);

    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 40,
      child: Transform.rotate(
        angle: -counterRotation, // Keep marker upright
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 4)],
              ),
              child: Text(
                '${ping.role.toUpperCase()} · ${ping.reportedBy.split("_").last}',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            Icon(Icons.person_pin_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildSosMarker(SosEvent sos, List<LocationPing> pings, double mapWidth, double mapHeight, double counterRotation) {
    final lat = sos.lat ?? (pings.isNotEmpty ? pings.first.lat : 21.5);
    final lng = sos.lng ?? (pings.isNotEmpty ? pings.first.lng : 82.5);

    final pos = _projectCoordinates(lat, lng, pings, mapWidth, mapHeight);

    return Positioned(
      left: pos.dx - 24,
      top: pos.dy - 48,
      child: Transform.rotate(
        angle: -counterRotation, // Keep SOS marker upright
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (ctx, _) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.redDanger,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.red.withAlpha(120), blurRadius: 8)],
                  ),
                  child: Text(
                    '🚨 SOS: ${sos.userName ?? sos.triggeredBy}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const Icon(Icons.warning_rounded, color: AppTheme.redDanger, size: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Offset _projectCoordinates(double lat, double lng, List<LocationPing> pings, double mapWidth, double mapHeight) {
    if (pings.length < 2) {
      return Offset(mapWidth * 0.45, mapHeight * 0.45);
    }

    double minLat = pings.first.lat;
    double maxLat = pings.first.lat;
    double minLng = pings.first.lng;
    double maxLng = pings.first.lng;

    for (final p in pings) {
      minLat = math.min(minLat, p.lat);
      maxLat = math.max(maxLat, p.lat);
      minLng = math.min(minLng, p.lng);
      maxLng = math.max(maxLng, p.lng);
    }

    final latSpan = (maxLat - minLat).abs() == 0 ? 0.001 : (maxLat - minLat).abs();
    final lngSpan = (maxLng - minLng).abs() == 0 ? 0.001 : (maxLng - minLng).abs();

    final normX = ((lng - minLng) / lngSpan).clamp(0.1, 0.85);
    final normY = (1.0 - ((lat - minLat) / latSpan)).clamp(0.15, 0.80);

    return Offset(mapWidth * normX, mapHeight * normY);
  }

  // Distance calculation using Haversine formula
  double _calculateDistanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0; // Earth radius in meters
    final dLat = (lat2 - lat1) * math.pi / 180.0;
    final dLon = (lon2 - lon1) * math.pi / 180.0;
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  // Initial bearing calculation
  double _calculateBearingDegrees(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = lat1 * math.pi / 180.0;
    final phi2 = lat2 * math.pi / 180.0;
    final deltaLambda = (lon2 - lon1) * math.pi / 180.0;

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final theta = math.atan2(y, x);
    final bearing = (theta * 180.0 / math.pi + 360.0) % 360.0;
    return bearing;
  }

  String _degreesToCardinal(double degrees) {
    const directions = ['N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE', 'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'];
    final index = ((degrees + 11.25) % 360 / 22.5).floor();
    return directions[index];
  }

  Widget _legendDot(Color color) {
    return Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

class _MineSchematicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = const Color(0xFFCFD8DC)..strokeWidth = 8..style = PaintingStyle.stroke;
    final benchPaint = Paint()..color = const Color(0xFFB0BEC5)..strokeWidth = 2..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = const Color(0xFFE0E7EB)..style = PaintingStyle.fill;

    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width * 0.85, height: size.height * 0.75), fillPaint);
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.5), Offset(size.width * 0.9, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.1), Offset(size.width * 0.5, size.height * 0.9), roadPaint);

    for (int i = 1; i <= 4; i++) {
      final r = i * size.width * 0.1;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: r * 2, height: r * 1.4),
        benchPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
