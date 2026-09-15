import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';
import '../sync/sync_service.dart';
import '../theme/app_theme.dart';
import 'observation_form.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase?>(context);

    if (db == null) {
      return const Scaffold(
        body: Center(child: Text('Database unavailable')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mine Compliance', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              try {
                final result = await SyncService(db).sync();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${result.pushed} records synced')),
                  );
                }
              } catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sync unavailable: $error')),
                  );
                }
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sync status card
            Card(
              color: AppTheme.nearBlackCoal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_off, color: AppTheme.amberAccent, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Offline Mode Active',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<List<Observation>>(
                      stream: db.select(db.observations).watch(),
                      builder: (context, snapshot) {
                        final count = snapshot.data?.where((o) => o.syncStatus == 0).length ?? 0;
                        return Text(
                          '$count items pending sync',
                          style: TextStyle(color: Colors.white.withAlpha(178)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Log Safety Observation', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ObservationFormScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.record_voice_over),
              label: const Text('Report Grievance', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice Grievance reporting coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
