import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../database/database.dart';
import '../../theme/app_theme.dart';

class GrievancesTab extends StatefulWidget {
  const GrievancesTab({super.key});

  @override
  State<GrievancesTab> createState() => _GrievancesTabState();
}

class _GrievancesTabState extends State<GrievancesTab> {
  final _formKey = GlobalKey<FormState>();
  bool _isAnonymous = false;
  String _lang = 'English';
  String _grievanceText = '';
  bool _submitted = false;

  final _langs = ['English', 'Hindi', 'Odia', 'Bengali'];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    final db = Provider.of<AppDatabase?>(context, listen: false);
    if (db == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database not available')),
      );
      return;
    }

    try {
      await db.addGrievance(GrievancesCompanion(
        clientUuid: drift.Value(const Uuid().v4()),
        orgId: const drift.Value('CIL-SECL-001'),
        raisedBy: _isAnonymous
            ? const drift.Value(null)
            : const drift.Value('worker_demo'),
        isAnonymous: drift.Value(_isAnonymous),
        lang: drift.Value(_lang),
        rawText: drift.Value(_grievanceText),
        syncStatus: const drift.Value(0),
      ));
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Grievance save failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Grievances',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('File a concern — safely and securely.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          if (_submitted)
            _buildSuccessBanner()
          else ...[
            _buildForm(),
          ],
          const SizedBox(height: 24),
          _buildPastTicketsList(),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.greenVerified.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.greenVerified),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline,
              color: AppTheme.greenVerified, size: 40),
          const SizedBox(height: 8),
          const Text('Grievance Recorded to Secure Ledger!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Your concern has been saved and will sync automatically when online.',
              style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() => _submitted = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amberAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('File Another Concern'),
          )
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SwitchListTile(
            title: const Text('Submit Anonymously',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Identity hidden from contractors',
                style: TextStyle(fontSize: 11)),
            value: _isAnonymous,
            onChanged: (v) => setState(() => _isAnonymous = v),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _lang,
            decoration: const InputDecoration(
              labelText: 'Language',
              border: OutlineInputBorder(),
            ),
            items: _langs
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _lang = v ?? 'English'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            maxLines: 4,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Describe your concern',
              alignLabelWithHint: true,
            ),
            onSaved: (v) => _grievanceText = v ?? '',
            validator: (v) =>
                (v == null || v.length < 10) ? 'Please describe your concern (min 10 chars)' : null,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Bhashini AI voice input simulation activated')),
              );
            },
            icon: const Icon(Icons.mic, color: AppTheme.amberAccent),
            label: const Text('Record Voice Note (Bhashini)',
                style: TextStyle(color: AppTheme.nearBlackCoal)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.amberAccent,
                foregroundColor: Colors.white),
            child: const Text('SUBMIT GRIEVANCE',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPastTicketsList() {
    final db = Provider.of<AppDatabase?>(context);
    if (db == null) {
      return _buildStaticFallbackTicket();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Submitted Tickets',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        StreamBuilder<List<Grievance>>(
          stream: db.watchAllGrievances(),
          builder: (context, snapshot) {
            final grievances = snapshot.data ?? [];
            if (grievances.isEmpty) {
              return _buildStaticFallbackTicket();
            }

            return Column(
              children: grievances.map((g) {
                final statusText = g.syncStatus == 1 ? 'Synced' : 'Local Pending';
                final statusColor = g.syncStatus == 1 ? AppTheme.greenVerified : AppTheme.amberAccent;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(Icons.comment_outlined, color: statusColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GRV-${g.clientUuid.substring(0, 6).toUpperCase()}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(g.rawText,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(statusText,
                            style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStaticFallbackTicket() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.amberAccent.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.comment_outlined, color: AppTheme.amberAccent),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GRV-8291',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Drinking water not available at Face 3A',
                    style: TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.amberAccent.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('In Review',
                style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.amberAccent,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
