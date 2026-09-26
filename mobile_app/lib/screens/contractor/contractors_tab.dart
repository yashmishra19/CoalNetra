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
        ...mockContractors.map((c) => _buildCard(context, c)),
      ],
    );
  }

  void _showContractorDetails(BuildContext context, MockContractor c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, color: AppTheme.amberAccent, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('License: ${c.licenceNo}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile('Total Workers', '${c.workerCount} Active', Icons.group),
                _buildInfoTile('VTC Status', c.vtcExpired ? 'EXPIRED' : 'Valid until ${c.vtcExpiry}', c.vtcExpired ? Icons.warning : Icons.check_circle),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTile('PME Medicals', 'Valid (${c.pmeExpiry})', Icons.health_and_safety),
                _buildInfoTile('Licence Status', c.licenceExpired ? 'EXPIRED' : 'Active', c.licenceExpired ? Icons.error : Icons.verified),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.amberAccent,
                      side: const BorderSide(color: AppTheme.amberAccent),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✓ Digital Compliance Audit Notice sent to ${c.name}!'),
                          backgroundColor: AppTheme.greenVerified,
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_turned_in, size: 16),
                    label: const Text('Send Audit Notice'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.amberAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✓ Renewed VTC/PME safety certificates for ${c.name}!'),
                          backgroundColor: AppTheme.greenVerified,
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Renew VTC / PME'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String val, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppTheme.amberAccent),
                const SizedBox(width: 6),
                Text(title, style: const TextStyle(fontSize: 10, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 4),
            Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, MockContractor c) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _showContractorDetails(context, c),
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
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _expiryBadge('VTC', c.vtcExpiry, c.vtcExpired),
                          _expiryBadge('PME', c.pmeExpiry, false),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Audit', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _workerBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 11, color: Colors.grey),
          const SizedBox(width: 3),
          Text('$count',
              style: const TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _expiryBadge(String label, String date, bool expired) {
    final color = expired ? AppTheme.redDanger : AppTheme.greenVerified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(expired ? Icons.warning_amber : Icons.check_circle_outline,
              size: 11, color: color),
          const SizedBox(width: 4),
          Text('$label: $date',
              style: TextStyle(
                  fontSize: 10.5,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
