import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegionSummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String? subValue;
  final String? footer;
  final Color? accentColor;

  const RegionSummaryCard({
    super.key,
    required this.label,
    required this.value,
    this.subValue,
    this.footer,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: accentColor ?? Colors.grey.shade300, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.nearBlackCoal,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(width: 4),
                Text(
                  subValue!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
          if (footer != null) ...[
            const Spacer(),
            Text(
              footer!,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
