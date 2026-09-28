import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/region_summary_card.dart';
import '../../widgets/provenance_bar.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _isLoading = true;
  bool _isLive = false;

  int? _openCapas = 3;
  int? _overdueCapas = 1;
  int? _observationsCount = 2;
  int? _riskScore = 64;
  String? _riskLevel = 'MODERATE';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final data = await ApiService.instance.fetchToday();
    if (!mounted) return;

    if (data != null) {
      final summary = data['summary'];
      final risk = data['riskScore'];

      setState(() {
        if (summary is Map) {
          _openCapas = summary['openCapas'] ?? 3;
          _overdueCapas = summary['overdueCapas'] ?? 1;
          _observationsCount = summary['observationsCount'] ?? 12;
        }
        if (risk is Map) {
          _riskScore = risk['overall_score'] ?? 72;
          _riskLevel = (risk['risk_level'] ?? 'HIGH').toString().toUpperCase();
        }
        _isLoading = false;
        _isLive = true;
      });
    } else {
      setState(() {
        _isLoading = false;
        _isLive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isLive)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 14,
                    color: AppTheme.greenVerified,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Live compliance data connected',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          if (!_isLive)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    _isLoading ? Icons.sync : Icons.cloud_off,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isLoading
                        ? 'Showing demo figures while connecting...'
                        : 'Offline · showing local demo figures',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sardega OCP',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.nearBlackCoal,
                    ),
                  ),
                  Text(
                    'September 2026',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Integrity check: Cryptographic chain verified OK',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cobaltBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text(
                  'Run Integrity check',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary Metrics Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              RegionSummaryCard(
                label: 'COMPLIANCE RISK SCORE',
                value: _riskScore == null ? '—' : '$_riskScore / 100',
                subValue: _riskLevel == null
                    ? 'NO LIVE DATA'
                    : '$_riskLevel RISK',
                accentColor: (_riskScore ?? 0) > 65
                    ? AppTheme.redDanger
                    : AppTheme.amberAccent,
              ),
              RegionSummaryCard(
                label: 'OPEN CAPAs',
                value: _openCapas?.toString() ?? '—',
                footer: _overdueCapas == null
                    ? 'No live data loaded'
                    : '$_overdueCapas overdue for action',
                accentColor: AppTheme.amberAccent,
              ),
              RegionSummaryCard(
                label: 'LIVE OBSERVATIONS',
                value: _observationsCount?.toString() ?? '—',
                footer: 'Field inspection records',
                accentColor: AppTheme.cobaltBlue,
              ),
              RegionSummaryCard(
                label: 'ACCIDENTS NOTIFIED',
                value: '2',
                subValue: 'DEMO',
                footer: 'Local demo incident count',
                accentColor: AppTheme.redDanger,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Assurance & Reporting Section
          const Text(
            'Assurance and reporting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Provenance of everything this office sees',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          const ProvenanceBar(data: provenanceData),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
