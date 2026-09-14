import 'package:flutter/material.dart';
import '../models/mock_data.dart';
import '../theme/app_theme.dart';

class RiskVectorBar extends StatelessWidget {
  final RiskVector vector;

  const RiskVectorBar({super.key, required this.vector});

  Color get _barColor {
    if (vector.isCritical) return AppTheme.redDanger;
    if (vector.isWarning) return AppTheme.amberAccent;
    return AppTheme.greenVerified;
  }

  Color get _badgeColor {
    if (vector.isCritical) return AppTheme.redDanger;
    if (vector.isWarning) return AppTheme.amberAccent;
    return AppTheme.greenVerified;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  vector.label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.nearBlackCoal,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${vector.value}%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: vector.value / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor),
              minHeight: 7,
            ),
          ),
        ],
      ),
    );
  }
}
