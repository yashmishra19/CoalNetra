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
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          if (_submitted)
            _buildSuccessBanner()
          else ...[
            _buildForm(),
          ],
          const SizedBox(height: 24),
          _buildPastTicket(),
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
          const Text('Grievance Filed',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text('Ticket #GRV-${DateTime.now().millisecondsSinceEpoch % 10000} created. SLA: 48 hrs.',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _submitted = false),
            child: const Text('File Another'),
          ),
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
          // Anonymous toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.visibility_off_outlined,
                    size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Submit Anonymously',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text('Your identity will not be recorded',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
                Switch(
                  value: _isAnonymous,
                  onChanged: (v) => setState(() => _isAnonymous = v),
                  activeThumbColor: AppTheme.amberAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _lang,
            decoration: const InputDecoration(labelText: 'Language'),
            items: _langs
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) => setState(() => _lang = v!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Describe your concern',
              alignLabelWithHint: true,
            ),
            onSaved: (v) => _grievanceText = v ?? '',
            validator: (v) =>
                (v == null || v.length < 10) ? 'Please describe your concern' : null,
          ),
          const SizedBox(height: 16),
          // Voice note button
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.mic, color: AppTheme.amberAccent),
            label: const Text('Record Voice Note (Bhashini)',
                style: TextStyle(color: AppTheme.nearBlackCoal)),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text('SUBMIT GRIEVANCE',
                style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }

  Widget _buildPastTicket() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Tickets',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 10),
        Container(
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
                child: const Icon(Icons.comment_outlined,
                    color: AppTheme.amberAccent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('GRV-8291',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Drinking water not available at Face 3A',
                        style: TextStyle(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
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
        ),
      ],
    );
  }
}
