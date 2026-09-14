import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;
import '../database/database.dart';
import '../theme/app_theme.dart';

class ObservationFormScreen extends StatefulWidget {
  final String? initialCategory;
  const ObservationFormScreen({super.key, this.initialCategory});

  @override
  State<ObservationFormScreen> createState() => _ObservationFormScreenState();
}

class _ObservationFormScreenState extends State<ObservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _category;
  String _severity = 'Medium';
  Position? _currentPosition;
  bool _isQrScan = false;
  bool _isSaving = false;

  final List<String> _categories = [
    'Safety Hazard',
    'Near-miss',
    'Incident',
    'Statutory Reading',
    'CAPA Closure'
  ];

  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory ?? 'Safety Hazard';
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 2),
        ),
      );
      
      if (mounted) {
        setState(() => _currentPosition = position);
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _saveObservation() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isSaving = true);

    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null) {
      setState(() => _isSaving = false);
      return;
    }

    final uuid = const Uuid().v4();
    final locString = _isQrScan 
        ? 'QR-FACE-3A' 
        : (_currentPosition != null ? '${_currentPosition!.latitude}, ${_currentPosition!.longitude}' : 'Manual Location');

    try {
      await db.addObservation(ObservationsCompanion(
        orgId: const drift.Value('CIL-SECL-001'),
        reportedBy: const drift.Value('field_officer_01'),
        category: drift.Value(_category),
        location: drift.Value(locString),
        clientUuid: drift.Value(uuid),
        trustScore: drift.Value(_currentPosition != null || _isQrScan ? 98.0 : 40.0),
        syncStatus: const drift.Value(0),
      ));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted to ledger!'), backgroundColor: AppTheme.greenVerified),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhiteBackground,
      appBar: AppBar(
        title: Text(_category == 'Statutory Reading' ? 'Statutory Reading' : 'Field Reporting'),
        actions: [
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: _isQrScan ? AppTheme.amberAccent : Colors.white),
            onPressed: () => setState(() => _isQrScan = !_isQrScan),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLocationStatus(),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Report Category'),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _severity,
                      decoration: const InputDecoration(labelText: 'Severity'),
                      items: _severities.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (v) => setState(() => _severity = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_category == 'Statutory Reading') ...[
                _buildStatutoryFields(),
              ] else if (_category == 'CAPA Closure') ...[
                _buildClosureFields(),
              ] else ...[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Description of Observation', alignLabelWithHint: true),
                  maxLines: 3,
                  validator: (v) => (v == null || v.isEmpty) ? 'Description required' : null,
                ),
              ],
              
              const SizedBox(height: 24),
              const Text('EVIDENCE CAPTURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              _buildEvidenceGrid(),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveObservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cobaltBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('SUBMIT TO SYSTEM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    bool active = _currentPosition != null || _isQrScan;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppTheme.greenVerified.withAlpha(20) : AppTheme.amberAccent.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? AppTheme.greenVerified : AppTheme.amberAccent),
      ),
      child: Row(
        children: [
          Icon(_isQrScan ? Icons.qr_code : Icons.gps_fixed, color: active ? AppTheme.greenVerified : AppTheme.amberAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _isQrScan ? "Location Verified via QR: Face 3A" : (_currentPosition != null ? "GPS Position Locked (Trust: 98%)" : "Acquiring Location..."),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: active ? AppTheme.greenVerified : AppTheme.amberAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutoryFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'CH4 %'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'CO (ppm)'), keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Air Velocity (m/s)'), keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'Dust (mg/m3)'), keyboardType: TextInputType.number)),
          ],
        ),
      ],
    );
  }

  Widget _buildClosureFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("REF: CAPA-2024-082", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("Issue: Exposed electrical wiring at Pump House 4", style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(labelText: 'Action Taken / Verification Notes'),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildEvidenceGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _evidenceTile(Icons.camera_alt, "Photo"),
        _evidenceTile(Icons.mic, "Voice"),
        _evidenceTile(Icons.sensors, "Sensor Log"),
      ],
    );
  }

  Widget _evidenceTile(IconData icon, String label) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.cobaltBlue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
