import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../theme/app_theme.dart';

/// SirdarMapTab — shows real location pings and SOS events from Drift DB.
/// Green = GPS live, Amber = last known, Red pulsing = SOS alert.
class SirdarMapTab extends StatefulWidget {
  const SirdarMapTab({super.key});

  @override
  State<SirdarMapTab> createState() => _SirdarMapTabState();
}

class _SirdarMapTabState extends State<SirdarMapTab> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase?>(context, listen: false);

    return Column(
      children: [
        // Search / filter bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search location or asset...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Map area with live markers
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

                        return Stack(
                          children: [
                            // Mine schematic background
                            Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: const Color(0xFFE8EDF2),
                              child: CustomPaint(painter: _MineSchematicPainter()),
                            ),

                            // Location ping markers
                            ...pings.take(20).map((ping) => _buildLocationMarker(ping)),

                            // SOS markers (pulsing red)
                            ...sosEvents.take(5).map((sos) => _buildSosMarker(sos)),

                            // Map controls
                            Positioned(
                              bottom: 100,
                              right: 16,
                              child: Column(
                                children: [
                                  _mapButton(Icons.my_location, () {}),
                                  const SizedBox(height: 12),
                                  _mapButton(Icons.layers, () {}),
                                ],
                              ),
                            ),

                            // Legend
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 80,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(230),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Live field positions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _legendDot(AppTheme.greenVerified),
                                        const SizedBox(width: 4),
                                        const Text('GPS live', style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 12),
                                        _legendDot(AppTheme.amberAccent),
                                        const SizedBox(width: 4),
                                        const Text('Last known', style: TextStyle(fontSize: 11)),
                                        const SizedBox(width: 12),
                                        _legendDot(AppTheme.redDanger),
                                        const SizedBox(width: 4),
                                        const Text('SOS', style: TextStyle(fontSize: 11)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${pings.length} personnel tracked · ${sosEvents.length} SOS events today',
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Empty state
                            if (pings.isEmpty && sosEvents.isEmpty)
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: Colors.white.withAlpha(200), borderRadius: BorderRadius.circular(12)),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_searching, size: 40, color: AppTheme.steel),
                                      const SizedBox(height: 8),
                                      const Text('Acquiring positions...', style: TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      Text('GPS pings every 2 min', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Place markers at deterministic positions based on lat/lng relative to a
  /// mine-centre reference point. In production, replace with a real map tile.
  Widget _buildLocationMarker(LocationPing ping) {
    final bool isLive = ping.locationConfidence == 'gps_live';
    final color = isLive ? AppTheme.greenVerified : AppTheme.amberAccent;

    // Map lat/lng delta to screen coordinates (simple linear projection)
    final x = _lngToX(ping.lng);
    final y = _latToY(ping.lat);

    return Positioned(
      left: x - 30,
      top: y - 50,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 3)],
            ),
            child: Text(
              '${ping.role.toUpperCase()[0]} · ${isLive ? 'Live' : '⚠ Last'}',
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Icon(Icons.person_pin_circle, color: color, size: 28),
        ],
      ),
    );
  }

  Widget _buildSosMarker(SosEvent sos) {
    if (sos.lat == null || sos.lng == null) return const SizedBox.shrink();
    final x = _lngToX(sos.lng!);
    final y = _latToY(sos.lat!);

    return Positioned(
      left: x - 20,
      top: y - 55,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, __) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(color: AppTheme.redDanger, borderRadius: BorderRadius.circular(4)),
                child: const Text('SOS!', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const Icon(Icons.warning_rounded, color: AppTheme.redDanger, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Simple projection: maps lat/lng to screen x/y in 300x400 virtual space
  // Reference centre: 21.5°N, 82.5°E (central India opencast belt)
  double _lngToX(double lng) {
    final screenWidth = MediaQuery.of(context).size.width;
    return ((lng - 82.4) * 5000).clamp(20.0, screenWidth - 60);
  }

  double _latToY(double lat) {
    final screenHeight = MediaQuery.of(context).size.height * 0.55;
    return ((21.6 - lat) * 5000).clamp(20.0, screenHeight - 80);
  }

  Widget _mapButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: IconButton(icon: Icon(icon, color: Colors.blueGrey), onPressed: onTap),
    );
  }

  Widget _legendDot(Color color) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

/// Simple mine schematic — grey roads and bench lines without needing a network image
class _MineSchematicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()..color = const Color(0xFFCFD8DC)..strokeWidth = 8..style = PaintingStyle.stroke;
    final benchPaint = Paint()..color = const Color(0xFFB0BEC5)..strokeWidth = 2..style = PaintingStyle.stroke;
    final fillPaint = Paint()..color = const Color(0xFFE0E7EB)..style = PaintingStyle.fill;

    // Outer mine boundary (ellipse)
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width * 0.85, height: size.height * 0.75), fillPaint);

    // Haul roads
    canvas.drawLine(Offset(size.width * 0.1, size.height * 0.5), Offset(size.width * 0.9, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.5, size.height * 0.1), Offset(size.width * 0.5, size.height * 0.9), roadPaint);

    // Bench terraces
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
