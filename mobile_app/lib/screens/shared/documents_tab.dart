import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// OCR Document Digitization + Document Expiry & Evidence Management
class DocumentsTab extends StatefulWidget {
  const DocumentsTab({super.key});

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  static const _demoDocuments = [
    _DemoDocument(
      title: 'DGMS Blasting Certificate · S. Oram',
      category: 'Safety',
      detail: 'Certificate DGMS/BLC/2026/014 · Expires 30 Sep 2026',
      state: 'EXPIRING SOON',
    ),
    _DemoDocument(
      title: 'Boiler Operator Fitness Certificate',
      category: 'Equipment',
      detail: 'Certificate BOIL/OPR/2025/456 · Expires 03 Oct 2026',
      state: 'EXPIRING SOON',
    ),
    _DemoDocument(
      title: 'Contractor BOCW Registration',
      category: 'Labour',
      detail: 'A. Constructions · 42 workers · Expires 31 Mar 2027',
      state: 'VALID',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expiring = _demoDocuments
        .where((doc) => doc.state == 'EXPIRING SOON')
        .length;
    final expired = _demoDocuments
        .where((doc) => doc.state == 'EXPIRED')
        .length;
    return Column(
      children: [
        Container(
          color: AppTheme.nearBlackCoal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DocumentStat(
                value: _demoDocuments.length.toString(),
                label: 'Total Docs',
                color: Colors.white70,
              ),
              _DocumentDivider(),
              _DocumentStat(
                value: '$expiring',
                label: 'Expiring Soon',
                color: Colors.orange,
              ),
              _DocumentDivider(),
              _DocumentStat(
                value: '$expired',
                label: 'Expired',
                color: AppTheme.redDanger,
              ),
            ],
          ),
        ),
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.amberAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.amberAccent,
            tabs: const [
              Tab(icon: Icon(Icons.folder_open, size: 16), text: 'Documents'),
              Tab(
                icon: Icon(Icons.document_scanner, size: 16),
                text: 'OCR Upload',
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.amber.shade50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: const Text(
                      'LOCAL DEMO RECORDS · NOT VERIFIED OR STORED IN THE DATABASE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _demoDocuments.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) =>
                          _buildDemoDocument(_demoDocuments[index]),
                    ),
                  ),
                ],
              ),
              _buildUnavailableState(
                icon: Icons.cloud_off,
                title: 'Document upload and OCR are not connected.',
                detail:
                    'No file is selected, uploaded, or submitted from this screen.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDemoDocument(_DemoDocument document) {
    final isValid = document.state == 'VALID';
    final color = isValid ? AppTheme.greenVerified : Colors.orange;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.timelapse,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  document.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                document.state,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${document.category} · DEMO',
            style: TextStyle(color: Colors.grey[700], fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            document.detail,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoDocument {
  final String title;
  final String category;
  final String detail;
  final String state;

  const _DemoDocument({
    required this.title,
    required this.category,
    required this.detail,
    required this.state,
  });
}

class _DocumentStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _DocumentStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}

class _DocumentDivider extends StatelessWidget {
  const _DocumentDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: Colors.white12);
  }
}
