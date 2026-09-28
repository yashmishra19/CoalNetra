import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Geo-tagged Field Inspection – Inspector records issue + GPS + timestamp + photos.
class GeoInspectionScreen extends StatefulWidget {
  const GeoInspectionScreen({super.key});

  @override
  State<GeoInspectionScreen> createState() => _GeoInspectionScreenState();
}

class _GeoInspectionScreenState extends State<GeoInspectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedZone = 'Face Gallery 3A';
  String _selectedCategory = 'Safety';
  String _selectedSeverity = 'Medium';
  bool _gpsLocked = true;
  int _photoCount = 0;

  final List<String> _zones = [
    'Face Gallery 3A',
    'Conveyor Belt 4',
    'Junction 2',
    'Pump House B',
    'Surface Workshop',
    'Shaft Bottom',
  ];
  final List<String> _categories = [
    'Safety',
    'Environment',
    'Labour',
    'Equipment',
    'Infrastructure',
  ];
  final List<_Severity> _severities = [
    _Severity('Critical', AppTheme.redDanger),
    _Severity('High', Colors.deepOrange),
    _Severity('Medium', AppTheme.amberAccent),
    _Severity('Low', AppTheme.greenVerified),
  ];

  @override
  void dispose() {
    _descController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sev = _severities.firstWhere((s) => s.label == _selectedSeverity);

    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.nearBlackCoal,
        foregroundColor: Colors.white,
        title: const Text('Geo-tagged Field Inspection',
            style: TextStyle(fontSize: 15)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              backgroundColor:
                  _gpsLocked ? AppTheme.greenVerified : AppTheme.amberAccent,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _gpsLocked ? Icons.gps_fixed : Icons.gps_not_fixed,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _gpsLocked ? 'GPS LOCKED' : 'ACQUIRING...',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GPS Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.nearBlackCoal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.amberAccent),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GPS Coordinates (Auto-captured)',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                          SizedBox(height: 2),
                          Text('21.2787° N, 83.6341° E',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace')),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Timestamp',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 10)),
                        Text(
                          '26 Sep 2026\n15:10 IST',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionLabel('ZONE / LOCATION'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedZone,
                decoration: const InputDecoration(
                    hintText: 'Select zone',
                    prefixIcon: Icon(Icons.place_outlined)),
                items: _zones
                    .map((z) =>
                        DropdownMenuItem(value: z, child: Text(z)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedZone = v!),
              ),

              const SizedBox(height: 16),
              _sectionLabel('INSPECTION CATEGORY'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.cobaltBlue
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.cobaltBlue
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              _sectionLabel('SEVERITY'),
              const SizedBox(height: 8),
              Row(
                children: _severities.map((s) {
                  final selected = _selectedSeverity == s.label;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedSeverity = s.label),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? s.color.withAlpha(30)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected ? s.color : Colors.grey[200]!,
                              width: selected ? 2 : 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          s.label,
                          style: TextStyle(
                            color: selected ? s.color : Colors.grey,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              _sectionLabel('ISSUE DESCRIPTION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the safety/compliance issue observed...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Description required' : null,
              ),

              const SizedBox(height: 16),
              _sectionLabel('PHOTO EVIDENCE'),
              const SizedBox(height: 8),

              // Photo attach row
              Row(
                children: [
                  ...List.generate(
                    _photoCount,
                    (i) => Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.cobaltBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppTheme.cobaltBlue.withAlpha(80)),
                      ),
                      child: const Center(
                        child: Icon(Icons.image,
                            color: AppTheme.cobaltBlue, size: 30),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_photoCount < 4) {
                        setState(() => _photoCount++);
                      }
                    },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              color: Colors.grey[500]),
                          Text('Add',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              _sectionLabel('REMARKS / CORRECTIVE SUGGESTION'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _remarksController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'e.g. Immediate stoppage of work, notify mine manager...',
                ),
              ),

              const SizedBox(height: 24),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submitInspection,
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(
                    'SUBMIT INSPECTION · ${sev.label.toUpperCase()}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sev.color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  void _submitInspection() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Inspection submitted · $_selectedZone · GPS tagged · $_photoCount photo(s)',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.greenVerified,
          duration: const Duration(seconds: 4),
        ),
      );
      Navigator.pop(context);
    }
  }
}

class _Severity {
  final String label;
  final Color color;
  _Severity(this.label, this.color);
}
