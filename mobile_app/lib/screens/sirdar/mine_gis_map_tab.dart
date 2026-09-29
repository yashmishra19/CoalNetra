import 'package:flutter/material.dart';
import '../../services/sos_service.dart';
import '../../theme/app_theme.dart';

/// GIS Mine Digital Map – Displays mine boundaries, zones, inspections,
/// incidents, violations, risk areas, and nearby BLE/server SOS locations.
class MineGISMapTab extends StatefulWidget {
  const MineGISMapTab({super.key});

  @override
  State<MineGISMapTab> createState() => _MineGISMapTabState();
}

class _MineGISMapTabState extends State<MineGISMapTab> {
  final List<_MapFilter> _filters = [
    _MapFilter('Nearby SOS', Icons.sensors, Colors.redAccent),
    _MapFilter('Risk Zones', Icons.warning_amber, Colors.red[300]!),
    _MapFilter('Violations', Icons.report, AppTheme.redDanger),
    _MapFilter('Inspections', Icons.search, AppTheme.cobaltBlue),
    _MapFilter('Incidents', Icons.local_hospital, Colors.orange),
    _MapFilter('Boundaries', Icons.crop_free, Colors.grey),
  ];
  final Set<String> _activeFilters = {
    'Violations',
    'Inspections',
    'Risk Zones',
    'Nearby SOS',
  };

  final List<_MapPin> _pins = [
    _MapPin(
      'Face Gallery 3A',
      0.18,
      0.30,
      'HIGH RISK · 3 violations',
      AppTheme.redDanger,
      Icons.warning,
    ),
    _MapPin(
      'Conveyor Belt 4',
      0.55,
      0.45,
      'MEDIUM RISK · 1 overdue',
      AppTheme.amberAccent,
      Icons.trending_up,
    ),
    _MapPin(
      'Junction 2',
      0.35,
      0.62,
      'LOW RISK · Last insp. 3 days ago',
      AppTheme.greenVerified,
      Icons.check_circle,
    ),
    _MapPin(
      'Pump House B',
      0.70,
      0.25,
      'HIGH RISK · Gas alarm on 24 Sep',
      AppTheme.redDanger,
      Icons.local_fire_department,
    ),
    _MapPin(
      'Surface Workshop',
      0.80,
      0.70,
      'COMPLIANT',
      AppTheme.greenVerified,
      Icons.check,
    ),
    _MapPin(
      'Shaft Bottom',
      0.25,
      0.80,
      'INSPECTION DUE',
      AppTheme.cobaltBlue,
      Icons.search,
    ),
  ];

  _MapPin? _selected;
  SOSBeaconData? _selectedSosBeacon;

  @override
  void initState() {
    super.initState();
    SOSService.instance.startNearbyDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SOSService.instance,
      builder: (context, child) {
        final sosBeacons = SOSService.instance.networkBeacons;

        return Column(
          children: [
            // Filter chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final active = _activeFilters.contains(f.label);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        avatar: Icon(
                          f.icon,
                          size: 14,
                          color: active ? f.color : Colors.grey,
                        ),
                        label: Text(
                          f.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: active ? f.color : Colors.grey,
                            fontWeight: active
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: active,
                        selectedColor: f.color.withOpacity(0.15),
                        checkmarkColor: f.color,
                        side: BorderSide(
                          color: active ? f.color : Colors.grey[300]!,
                        ),
                        onSelected: (v) {
                          setState(() {
                            if (v) {
                              _activeFilters.add(f.label);
                            } else {
                              _activeFilters.remove(f.label);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Schematic map canvas
            Expanded(
              child: Stack(
                children: [
                  // Map background – styled schematic
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A2A1A), Color(0xFF0D1A0D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CustomPaint(painter: _MineSchemePainter()),
                  ),

                  // Mine boundary label
                  const Positioned(
                    top: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SARDEGA OCP',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          'Mahanadi Coalfields Ltd. · Schematic View',
                          style: TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),

                  // Regular Map Pins
                  ..._pins.map((pin) {
                    if (!_shouldShow(pin)) return const SizedBox.shrink();
                    return Positioned(
                      left: MediaQuery.of(context).size.width * pin.relX - 18,
                      top:
                          (MediaQuery.of(context).size.height * 0.6) * pin.relY,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedSosBeacon = null;
                          _selected = _selected == pin ? null : pin;
                        }),
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: pin.color.withOpacity(0.8),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: _selected == pin ? 2.5 : 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: pin.color.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                pin.icon,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                pin.name.split(' ').take(2).join(' '),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // GPS placement is shown only for beacons inside the demo boundary.
                  if (_activeFilters.contains('Nearby SOS'))
                    ...sosBeacons.map((b) {
                      if (!_isInsideDemoMine(b)) return const SizedBox.shrink();
                      return Positioned(
                        left:
                            MediaQuery.of(context).size.width * _sosRelX(b) -
                            24,
                        top:
                            (MediaQuery.of(context).size.height * 0.6) *
                            _sosRelY(b),
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selected = null;
                            _selectedSosBeacon = _selectedSosBeacon == b
                                ? null
                                : b;
                          }),
                          child: Column(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.8),
                                      blurRadius: 20,
                                      spreadRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.sensors,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[900],
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.amberAccent),
                                ),
                                child: Text(
                                  'SOS: ${b.minerName}${b.distanceMeters == null ? '' : ' (~${b.distanceMeters}m)'}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                  // Selected regular pin card
                  if (_selected != null)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: _buildDetailCard(_selected!),
                    ),

                  // Selected server-reported SOS detail
                  if (_selectedSosBeacon != null)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: _buildSosBeaconCard(_selectedSosBeacon!),
                    ),

                  // Legend
                  if (_selected == null && _selectedSosBeacon == null)
                    Positioned(bottom: 20, right: 16, child: _buildLegend()),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  bool _shouldShow(_MapPin pin) {
    if (pin.color == AppTheme.redDanger &&
        !_activeFilters.contains('Violations') &&
        !_activeFilters.contains('Risk Zones'))
      return false;
    if (pin.color == AppTheme.amberAccent &&
        !_activeFilters.contains('Violations'))
      return false;
    if (pin.color == AppTheme.cobaltBlue &&
        !_activeFilters.contains('Inspections'))
      return false;
    return true;
  }

  bool _isInsideDemoMine(SOSBeaconData beacon) {
    final latitude = beacon.latitude;
    final longitude = beacon.longitude;
    return latitude != null &&
        longitude != null &&
        latitude >= 20.01 &&
        latitude <= 20.06 &&
        longitude >= 78.11 &&
        longitude <= 78.16;
  }

  double _sosRelX(SOSBeaconData beacon) =>
      0.1 + ((beacon.longitude! - 78.11) / 0.05) * 0.8;

  double _sosRelY(SOSBeaconData beacon) =>
      0.2 + ((20.06 - beacon.latitude!) / 0.05) * 0.6;

  Widget _buildSosBeaconCard(SOSBeaconData beacon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F0A0A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${beacon.isBleAirTagMesh ? 'BLE SOS' : 'SERVER SOS'}: ${beacon.minerName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Role: ${beacon.role} · ${beacon.locationName}',
                      style: TextStyle(color: Colors.red[200], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => setState(() => _selectedSosBeacon = null),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSosMetric(
                'GPS distance',
                beacon.distanceMeters == null
                    ? 'Unavailable'
                    : 'About ${beacon.distanceMeters} m',
                Icons.near_me,
                AppTheme.amberAccent,
              ),
              _buildSosMetric(
                'Coordinates',
                beacon.latitude == null || beacon.longitude == null
                    ? 'Unavailable'
                    : '${beacon.latitude!.toStringAsFixed(5)}, ${beacon.longitude!.toStringAsFixed(5)}',
                Icons.location_on,
                Colors.cyanAccent,
              ),
              _buildSosMetric(
                'Received',
                beacon.timestamp.toLocal().toString().substring(0, 16),
                Icons.access_time,
                Colors.white70,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'BLE proximity uses RSSI and is approximate. This schematic plots GPS only inside demo-mine bounds; radio dispatch is not connected.',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSosMetric(String title, String val, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(_MapPin pin) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.nearBlackCoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pin.color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(pin.icon, color: pin.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pin.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                onPressed: () => setState(() => _selected = null),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            pin.detail,
            style: TextStyle(
              color: pin.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors, color: Colors.redAccent, size: 12),
          SizedBox(width: 4),
          Text(
            'Nearby SOS signals',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _MapFilter {
  final String label;
  final IconData icon;
  final Color color;

  _MapFilter(this.label, this.icon, this.color);
}

class _MapPin {
  final String name;
  final double relX;
  final double relY;
  final String detail;
  final Color color;
  final IconData icon;

  _MapPin(this.name, this.relX, this.relY, this.detail, this.color, this.icon);
}

class _MineSchemePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.white12
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.2);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    path.lineTo(size.width * 0.9, size.height * 0.8);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
