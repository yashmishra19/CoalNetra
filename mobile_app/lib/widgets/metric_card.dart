import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? trend;
  final String? subLabel;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.trend,
    this.subLabel,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isReductionPositive = label.toLowerCase() == 'open obligations';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (trend != null)
                Text(
                  trend!,
                  style: TextStyle(
                    fontSize: 9,
                    color: trend!.contains('-')
                      ? (isReductionPositive ? AppTheme.greenVerified : AppTheme.redDanger)
                      : AppTheme.greenVerified,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppTheme.nearBlackCoal,
              height: 1.0,
            ),
          ),
          if (subLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              'CONTRIBUTING FACTORS',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel!,
              style: const TextStyle(fontSize: 10, color: AppTheme.nearBlackCoal),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
