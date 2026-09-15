import 'package:flutter/material.dart';
import '../models/mock_data.dart';

class ProvenanceBar extends StatelessWidget {
  final List<ProvenanceSegment> data;

  const ProvenanceBar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 12,
            child: Row(
              children: data.map((segment) {
                return Expanded(
                  flex: (segment.percentage * 100).toInt(),
                  child: Container(color: segment.color),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: data.map((segment) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: segment.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${(segment.percentage * 100).toInt()}% ${segment.label}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
