import 'package:flutter/material.dart';
import '../../models/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/region_summary_card.dart';
import '../../widgets/provenance_bar.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    const metrics = nagpurRegionMetrics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metrics.regionName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.nearBlackCoal,
                    ),
                  ),
                  Text(
                    'September 2026',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cobaltBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Run Integrity check', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Summary Metrics Grid (Matches web app's top row)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              RegionSummaryCard(
                label: 'MINES IN JURISDICTION',
                value: metrics.totalMines.toString(),
                subValue: '${metrics.coalMines} coal, ${metrics.metalMines} metal',
                accentColor: AppTheme.absoluteBlack,
              ),
              RegionSummaryCard(
                label: 'INSPECTIONS THIS QUARTER',
                value: '${metrics.inspectionsDone} of ${metrics.inspectionsTarget}',
                footer: '68%, 19 mines past interval',
                accentColor: AppTheme.amberAccent,
              ),
              RegionSummaryCard(
                label: 'DIRECTIONS OPEN',
                value: metrics.directionsOpen.toString(),
                footer: '19 past their compliance date',
                accentColor: AppTheme.amberAccent,
              ),
              RegionSummaryCard(
                label: 'ACCIDENTS NOTIFIED, 2026',
                value: metrics.fatalAccidents.toString(),
                subValue: 'fatal',
                footer: '14 serious, 2 notices arrived late',
                accentColor: AppTheme.redDanger,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Assurance & Reporting Section
          const Text(
            'Assurance and reporting',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Provenance of everything this office sees',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ProvenanceBar(data: provenanceData),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),
                _buildProvenanceRow('Inspection findings', '187', 'Inspector on site'),
                _buildProvenanceRow('Ambient and gas readings', '1,244', 'Instrument feed'),
                _buildProvenanceRow('Accident notifications', '8', 'Operator, sealed'),
                _buildProvenanceRow('Monthly returns', '96', 'Operator, sealed'),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Where to send inspectors
          const Text(
            'Where to send inspectors',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...inspectionPriorities.map((p) => _buildInspectionPriorityTile(p)),
          
          const SizedBox(height: 24),
          
          // Discipline Coverage
          const Text(
            'Coverage by discipline',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.borderGrey),
            ),
            child: Column(
              children: disciplineCoverages.map((d) => _buildCoverageBar(d)).toList(),
            ),
          ),
          
          const SizedBox(height: 80), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildProvenanceRow(String label, String count, String source) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.offWhiteBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              source,
              style: const TextStyle(fontSize: 9, color: Colors.blueGrey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionPriorityTile(InspectionPriority p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.nearBlackCoal,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '${inspectionPriorities.indexOf(p) + 1}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.mineName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text('Score ${p.score}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                Text(p.subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(p.reason, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageBar(DisciplineCoverage d) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.label, style: const TextStyle(fontSize: 11)),
              Text('${d.current}/${d.total}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: d.current / d.total,
              backgroundColor: AppTheme.offWhiteBackground,
              valueColor: AlwaysStoppedAnimation<Color>(d.color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
