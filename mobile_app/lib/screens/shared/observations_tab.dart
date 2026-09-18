import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';

class ObservationsTab extends StatelessWidget {
  const ObservationsTab({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'Closed':
        return AppTheme.greenVerified;
      case 'CAPA Raised':
        return AppTheme.amberAccent;
      default:
        return AppTheme.redDanger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            'Observations',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('${mockObservations.length} total · Sardega OCP',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100), // Bottom padding for FAB
            itemCount: mockObservations.length,
            itemBuilder: (context, index) => _buildCard(context, mockObservations[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, MockObservation obs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.assignment_turned_in, color: AppTheme.amberAccent),
                    const SizedBox(width: 8),
                    Expanded(child: Text('${obs.id} · ${obs.category}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location: ${obs.location}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('Logged Date: ${obs.date}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text('Current Status: ${obs.status}', style: TextStyle(fontSize: 13, color: _statusColor(obs.status), fontWeight: FontWeight.bold)),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _statusColor(obs.status),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(obs.id,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.amberAccent)),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _statusColor(obs.status).withAlpha(30),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _statusColor(obs.status)),
                            ),
                            child: Text(
                              obs.status,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: _statusColor(obs.status),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(obs.category,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(obs.location,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          const Spacer(),
                          Text(obs.date,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
