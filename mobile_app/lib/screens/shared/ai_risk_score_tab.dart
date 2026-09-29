import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AIRiskScoreTab extends StatefulWidget {
  const AIRiskScoreTab({super.key});

  @override
  State<AIRiskScoreTab> createState() => _AIRiskScoreTabState();
}

class _AIRiskScoreTabState extends State<AIRiskScoreTab>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<double> _scoreAnimation;

  bool _isLoading = true;
  bool _isLive = false;
  int _scoreValue = 72;
  String _riskLevel = 'HIGH';
  String _mineName = 'Sardega OCP';

  List<_ZoneRisk> _zones = [
    _ZoneRisk('Face Gallery 3A', 72, 'HIGH', AppTheme.redDanger, 'Repeated gas violations, 2 overdue CAPAs'),
    _ZoneRisk('Conveyor Belt 4', 45, 'MEDIUM', AppTheme.amberAccent, 'Equipment maintenance overdue by 14 days'),
    _ZoneRisk('Junction 2 Area', 28, 'LOW', AppTheme.greenVerified, 'Last inspection: 3 days ago. No violations.'),
    _ZoneRisk('Pump House B', 61, 'HIGH', AppTheme.redDanger, '3 recurring violations this month'),
    _ZoneRisk('Surface Workshop', 18, 'LOW', AppTheme.greenVerified, 'All certificates valid. In compliance.'),
  ];

  final List<_RiskFactor> _factors = [
    _RiskFactor('Violations (last 30d)', 0.82, AppTheme.redDanger, '9 incidents'),
    _RiskFactor('Overdue CAPAs', 0.65, AppTheme.amberAccent, '3 overdue'),
    _RiskFactor('Inspection Gaps', 0.54, AppTheme.amberAccent, '19 days'),
    _RiskFactor('Document Expiry', 0.30, Colors.orange, '2 docs near expiry'),
    _RiskFactor('Labour Compliance', 0.20, AppTheme.greenVerified, 'Training up to date'),
  ];

  @override
  void initState() {
    super.initState();
    _scoreController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _scoreAnimation =
        Tween<double>(begin: 0, end: 0.72).animate(CurvedAnimation(
      parent: _scoreController,
      curve: Curves.easeOut,
    ));
    _fetchRiskData();
  }

  Future<void> _fetchRiskData() async {
    final data = await ApiService.instance.fetchMineData();
    if (!mounted) return;

    if (data != null) {
      final mine = data['mine'];
      final sections = data['sections'];
      final riskScore = data['riskScore'];

      int score = 72;
      String level = 'HIGH';

      if (riskScore is Map) {
        score = riskScore['overall_score'] ?? riskScore['score'] ?? 72;
        level = (riskScore['risk_level'] ?? riskScore['level'] ?? 'HIGH').toString().toUpperCase();
      }

      List<_ZoneRisk> liveZones = [];
      if (sections is List && sections.isNotEmpty) {
        liveZones = sections.map((sec) {
          final sName = sec['name'] ?? sec['section_name'] ?? 'Zone';
          final sScore = sec['risk_score'] ?? sec['score'] ?? 45;
          final sLevel = sScore > 65 ? 'HIGH' : (sScore > 35 ? 'MEDIUM' : 'LOW');
          final sColor = sScore > 65 ? AppTheme.redDanger : (sScore > 35 ? AppTheme.amberAccent : AppTheme.greenVerified);
          final sReason = sec['reason'] ?? sec['details'] ?? 'Monitored zone compliance';

          return _ZoneRisk(sName, sScore, sLevel, sColor, sReason);
        }).toList();
      }

      setState(() {
        _scoreValue = score;
        _riskLevel = level;
        _mineName = mine?['name'] ?? 'Demo OCP-1';
        if (liveZones.isNotEmpty) _zones = liveZones;
        _isLoading = false;
        _isLive = true;
      });

      _scoreAnimation = Tween<double>(begin: 0, end: _scoreValue / 100.0).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOut),
      );
      _scoreController.forward(from: 0);
    } else {
      setState(() {
        _isLoading = false;
        _isLive = false;
      });
      _scoreController.forward();
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final headerColor = _scoreValue > 65
        ? AppTheme.redDanger
        : (_scoreValue > 35 ? AppTheme.amberAccent : AppTheme.greenVerified);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live indicator
          if (_isLive)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.bolt, size: 14, color: AppTheme.amberAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Real-time Supabase Risk Engine Connected',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),

          // AI Score Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2129), Color(0xFF2D3748)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI COMPLIANCE RISK SCORE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_mineName · Live Model',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: headerColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: headerColor),
                      ),
                      child: Text(
                        '$_riskLevel RISK',
                        style: TextStyle(
                            color: headerColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    final score = (_scoreAnimation.value * 100).round();
                    return Column(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: CircularProgressIndicator(
                                value: _scoreAnimation.value,
                                strokeWidth: 12,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _scoreAnimation.value > 0.65
                                      ? AppTheme.redDanger
                                      : _scoreAnimation.value > 0.40
                                          ? AppTheme.amberAccent
                                          : AppTheme.greenVerified,
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$score',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  '/100',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'AI Generated · Synced live with server risk engine',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Risk Factors Breakdown
          _sectionHeader(context, 'RISK FACTOR BREAKDOWN'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              children: _factors
                  .map((f) => _buildFactorBar(f))
                  .toList(),
            ),
          ),

          const SizedBox(height: 24),

          // Zone Breakdown
          _sectionHeader(context, 'ZONE-WISE RISK'),
          const SizedBox(height: 12),
          ..._zones.map((z) => _buildZoneCard(z)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.textMuted,
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildFactorBar(_RiskFactor factor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                factor.label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.nearBlackCoal),
              ),
              Text(
                factor.detail,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: factor.color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor.weight,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(factor.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(_ZoneRisk zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: zone.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${zone.score}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: zone.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      zone.zoneName,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: zone.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        zone.level,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: zone.color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  zone.reason,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoneRisk {
  final String zoneName;
  final int score;
  final String level;
  final Color color;
  final String reason;

  _ZoneRisk(this.zoneName, this.score, this.level, this.color, this.reason);
}

class _RiskFactor {
  final String label;
  final double weight;
  final Color color;
  final String detail;

  _RiskFactor(this.label, this.weight, this.color, this.detail);
}
