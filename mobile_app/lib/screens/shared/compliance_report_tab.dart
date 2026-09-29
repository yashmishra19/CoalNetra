import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Automated Compliance Report Generator
class ComplianceReportTab extends StatefulWidget {
  const ComplianceReportTab({super.key});

  @override
  State<ComplianceReportTab> createState() => _ComplianceReportTabState();
}

class _ComplianceReportTabState extends State<ComplianceReportTab> {
  String _reportType = 'Monthly Statutory';
  String _selectedMine = 'Sardega OCP';
  String _selectedMonth = 'September 2026';
  bool _generating = false;
  bool _generated = false;

  final List<String> _reportTypes = [
    'Monthly Statutory',
    'Quarterly DGMS',
    'Annual Environment',
    'Incident Summary',
    'Contractor Compliance',
    'Zone Risk Report',
  ];

  final List<_ReportSection> _sections = [
    _ReportSection('Executive Summary', 'Risk score, compliance rate, open violations', '2 pages', true),
    _ReportSection('Inspection Activity', 'Inspections done, zones covered, findings', '4 pages', true),
    _ReportSection('Violations & CAPAs', 'Detected, assigned, closed, overdue CAPAs', '3 pages', true),
    _ReportSection('Statutory Compliance', 'Rule-by-rule compliance status vs. regulation', '5 pages', true),
    _ReportSection('Labour & Contractor', 'Worker attendance, certification status', '3 pages', true),
    _ReportSection('Document Status', 'Certificate expiry, evidence uploaded/missing', '2 pages', true),
    _ReportSection('AI Risk Analysis', 'Recurring violations, predictive alerts summary', '2 pages', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E2129), Color(0xFF2D3748)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.summarize,
                        color: AppTheme.amberAccent, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'AUTO-GENERATE COMPLIANCE REPORT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'No manual compilation. System assembles from stored data.',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionLabel('REPORT TYPE'),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _reportTypes.length,
              separatorBuilder: (_, _s) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final r = _reportTypes[i];
                final sel = r == _reportType;
                return GestureDetector(
                  onTap: () => setState(() {
                    _reportType = r;
                    _generated = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.amberAccent
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? AppTheme.amberAccent
                              : Colors.grey[300]!),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      r,
                      style: TextStyle(
                          fontSize: 12,
                          color: sel ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('MINE'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMine,
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10)),
                      items: ['Sardega OCP', 'Basundhara OCP', 'Manikpur UG']
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMine = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('PERIOD'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10)),
                      items: [
                        'September 2026',
                        'August 2026',
                        'July 2026',
                        'Q3 2026',
                        'Q2 2026',
                      ]
                          .map((m) =>
                              DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMonth = v!),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionLabel('REPORT SECTIONS'),
          const SizedBox(height: 8),
          ..._sections.map((s) => _buildSectionToggle(s)),

          const SizedBox(height: 20),

          // Generate button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _generating ? null : _generateReport,
              icon: _generating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, size: 20),
              label: Text(
                _generating ? 'GENERATING REPORT...' : 'GENERATE REPORT',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cobaltBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.cobaltBlue.withAlpha(120),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          // Generated result
          if (_generated) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.greenVerified.withAlpha(15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.greenVerified.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: AppTheme.greenVerified, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'REPORT GENERATED',
                        style: TextStyle(
                            color: AppTheme.greenVerified,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _reportInfoRow('Report', '$_reportType – $_selectedMine'),
                  _reportInfoRow('Period', _selectedMonth),
                  _reportInfoRow('Pages',
                      '${_sections.where((s) => s.included).length * 3} (estimated)'),
                  _reportInfoRow('Format', 'PDF · XLSX'),
                  _reportInfoRow('Generated', '26 Sep 2026, 15:10 IST'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, size: 16),
                          label: const Text('Download PDF'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.greenVerified,
                              foregroundColor: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share, size: 16),
                          label: const Text('Share'),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.greenVerified,
                              side: const BorderSide(
                                  color: AppTheme.greenVerified)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionToggle(_ReportSection section) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                Text(section.description,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Text(section.pages,
              style: const TextStyle(fontSize: 10, color: Colors.grey)),
          const SizedBox(width: 8),
          Switch(
            value: section.included,
            onChanged: (v) => setState(() => section.included = v),
            activeColor: AppTheme.amberAccent,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _reportInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
              width: 70,
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey))),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _generateReport() async {
    setState(() {
      _generating = true;
      _generated = false;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _generating = false;
      _generated = true;
    });
  }
}

class _ReportSection {
  final String title;
  final String description;
  final String pages;
  bool included;

  _ReportSection(this.title, this.description, this.pages, this.included);
}
