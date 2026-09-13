import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';

class ContractorsTab extends StatelessWidget {
  const ContractorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Contractors',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${mockContractors.length} active · Sardega OCP',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ...mockContractors.map((c) => _buildCard(c)),
      ],
    );
  }

  Widget _buildCard(MockContractor c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: c.licenceExpired || c.vtcExpired
                ? AppTheme.redDanger
                : Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.amberAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.construction,
                      color: AppTheme.amberAccent, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(c.licenceNo,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                _workerBadge(c.workerCount),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                _expiryBadge('VTC', c.vtcExpiry, c.vtcExpired),
                const SizedBox(width: 12),
                _expiryBadge('PME', c.pmeExpiry, false),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _workerBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.person, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text('$count workers',
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _expiryBadge(String label, String date, bool expired) {
    final color = expired ? AppTheme.redDanger : AppTheme.greenVerified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        children: [
          Icon(expired ? Icons.warning_amber : Icons.check_circle_outline,
              size: 12, color: color),
          const SizedBox(width: 4),
          Text('$label: $date',
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
