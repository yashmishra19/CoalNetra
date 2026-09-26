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
  final _textController = TextEditingController();
  bool _isAnonymous = false;
  String _lang = 'English';
  String _grievanceText = '';
  bool _submitted = false;

  final _langs = ['English', 'Hindi', 'Odia', 'Bengali'];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _recordVoiceBhashini() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _BhashiniVoiceRecorderModal(
        lang: _lang,
        onTranscription: (text) {
          setState(() {
            _textController.text = (_textController.text + ' ' + text).trim();
          });
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    _grievanceText = _textController.text;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grievance Redressal Portal',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Safe, confidential, and tracked on regional ledger',
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          _submitted ? _buildSubmittedSuccess() : _buildForm(),
          const SizedBox(height: 24),
          const Text('Your past submissions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildPastTicket(),
        ],
      ),
    );
  }

  Widget _buildSubmittedSuccess() {
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
            controller: _textController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Describe your concern',
              alignLabelWithHint: true,
            ),
            validator: (v) =>
                (v == null || v.trim().length < 5) ? 'Please describe your concern' : null,
          ),
          const SizedBox(height: 16),
          // Voice note button
          OutlinedButton.icon(
            onPressed: _recordVoiceBhashini,
            icon: const Icon(Icons.mic, color: AppTheme.amberAccent),
            label: const Text('Record Voice Note (Bhashini AI)',
                style: TextStyle(color: AppTheme.nearBlackCoal, fontWeight: FontWeight.bold)),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

class _BhashiniVoiceRecorderModal extends StatefulWidget {
  final String lang;
  final Function(String) onTranscription;

  const _BhashiniVoiceRecorderModal({
    required this.lang,
    required this.onTranscription,
  });

  @override
  State<_BhashiniVoiceRecorderModal> createState() => _BhashiniVoiceRecorderModalState();
}

class _BhashiniVoiceRecorderModalState extends State<_BhashiniVoiceRecorderModal> {
  bool _isRecording = true;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  Future<void> _startTimer() async {
    for (int i = 1; i <= 3; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _seconds = i);
    }
  }

  void _finishRecording() {
    final sampleTranscriptions = {
      'Hindi': 'सुरक्षा उपकरण और पानी की आपूर्ति फेस 3A पर उपलब्ध कराई जाए।',
      'English': 'Safety equipment and water supply should be provided at Face 3A.',
      'Odia': 'ସୁରକ୍ଷା ଉପକରଣ ଏବଂ ଜଳ ଯୋଗାଣ ମିଳୁନାହିଁ।',
      'Bengali': 'ফেস ৩এ তে পানীয় জল এবং সুরক্ষা সরঞ্জাম নিশ্চিত করুন।',
    };

    final transcribedText = sampleTranscriptions[widget.lang] ?? sampleTranscriptions['English']!;
    widget.onTranscription(transcribedText);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Voice transcribed via Bhashini AI (${widget.lang})'),
        backgroundColor: AppTheme.greenVerified,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over, color: AppTheme.amberAccent),
              const SizedBox(width: 8),
              Text('Bhashini AI Speech-to-Text (${widget.lang})',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.amberAccent.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.amberAccent, width: 2),
            ),
            child: const Icon(Icons.mic, color: AppTheme.amberAccent, size: 40),
          ),
          const SizedBox(height: 14),
          Text('00:0${_seconds.clamp(0, 9)}', style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Listening... Speak your concern clearly', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberAccent, foregroundColor: Colors.black),
              onPressed: _finishRecording,
              icon: const Icon(Icons.stop, size: 18),
              label: const Text('STOP & TRANSCRIBE TO TEXT', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

