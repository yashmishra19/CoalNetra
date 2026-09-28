import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Contractor & Labour Compliance tab
class ContractorLabourTab extends StatefulWidget {
  const ContractorLabourTab({super.key});

  @override
  State<ContractorLabourTab> createState() => _ContractorLabourTabState();
}

class _ContractorLabourTabState extends State<ContractorLabourTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  final List<_ContractorEntry> _contractors = [
    _ContractorEntry(
      name: 'A. Constructions Pvt Ltd',
      contact: 'A. Gupta · +91-99301-22345',
      workers: 42,
      certifiedWorkers: 38,
      attendanceRate: 0.91,
      complianceScore: 87,
      openViolations: 1,
      trainingDue: 4,
      docs: [
        _DocStatus('BOCW Registration', true, '31 Mar 2027'),
        _DocStatus('Labour License', true, '15 Dec 2026'),
        _DocStatus('ESI Registration', false, 'EXPIRED'),
      ],
      workers_: [
        _WorkerEntry('R. Kumar', 'Shotfirer', true, true, 'Present'),
        _WorkerEntry('M. Singh', 'Helper', true, false, 'Present'),
        _WorkerEntry('J. Yadav', 'Loader', false, true, 'Absent'),
        _WorkerEntry('S. Das', 'Drill Operator', true, true, 'Present'),
      ],
    ),
    _ContractorEntry(
      name: 'B. Mining Services Ltd',
      contact: 'B. Sharma · +91-88012-55678',
      workers: 28,
      certifiedWorkers: 28,
      attendanceRate: 0.96,
      complianceScore: 95,
      openViolations: 0,
      trainingDue: 0,
      docs: [
        _DocStatus('BOCW Registration', true, '28 Feb 2027'),
        _DocStatus('Labour License', true, '01 Apr 2027'),
        _DocStatus('ESI Registration', true, '31 Dec 2026'),
      ],
      workers_: [
        _WorkerEntry('P. Verma', 'Electrician', true, true, 'Present'),
        _WorkerEntry('D. Patel', 'Mechanic', true, true, 'Present'),
      ],
    ),
    _ContractorEntry(
      name: 'C. Civil Works',
      contact: 'C. Jain · +91-70500-99988',
      workers: 15,
      certifiedWorkers: 10,
      attendanceRate: 0.74,
      complianceScore: 58,
      openViolations: 3,
      trainingDue: 5,
      docs: [
        _DocStatus('BOCW Registration', false, 'EXPIRED'),
        _DocStatus('Labour License', true, '10 Nov 2026'),
        _DocStatus('ESI Registration', false, 'Not submitted'),
      ],
      workers_: [
        _WorkerEntry('T. Rawat', 'Mason', false, false, 'Present'),
        _WorkerEntry('B. Nayak', 'Helper', false, false, 'Absent'),
      ],
    ),
  ];

  List<_ContractorEntry> get _filtered {
    if (_search.isEmpty) return _contractors;
    final q = _search.toLowerCase();
    return _contractors
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _search = _searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalWorkers =
        _contractors.fold<int>(0, (s, c) => s + c.workers);
    final certified =
        _contractors.fold<int>(0, (s, c) => s + c.certifiedWorkers);
    final violations =
        _contractors.fold<int>(0, (s, c) => s + c.openViolations);

    return Column(
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.nearBlackCoal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CONTRACTOR & LABOUR COMPLIANCE',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stat('${_contractors.length}', 'Contractors', Colors.white),
                  _vLine(),
                  _stat('$totalWorkers', 'Workers', Colors.white),
                  _vLine(),
                  _stat('$certified', 'Certified', AppTheme.greenVerified),
                  _vLine(),
                  _stat('$violations', 'Violations', AppTheme.redDanger),
                ],
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.amberAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.amberAccent,
            tabs: const [
              Tab(text: 'Contractors'),
              Tab(text: 'Workers'),
            ],
          ),
        ),

        // Search
        Container(
          color: AppTheme.offWhiteBackground,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search contractor or worker...',
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppTheme.amberAccent, width: 1.5),
              ),
            ),
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Contractors tab
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filtered.length,
                itemBuilder: (context, i) =>
                    _buildContractorCard(_filtered[i]),
              ),

              // Workers tab
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _contractors
                    .expand((c) => c.workers_)
                    .length,
                itemBuilder: (context, i) {
                  final all = _contractors
                      .expand((c) => c.workers_.map((w) =>
                          _WorkerWithContractor(w, c.name)))
                      .toList();
                  return _buildWorkerCard(all[i]);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContractorCard(_ContractorEntry c) {
    final scoreColor = c.complianceScore >= 80
        ? AppTheme.greenVerified
        : c.complianceScore >= 60
            ? AppTheme.amberAccent
            : AppTheme.redDanger;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          title: Row(
            children: [
              Expanded(
                child: Text(c.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${c.complianceScore}',
                  style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(Icons.groups, size: 13, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${c.workers} workers',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.grey)),
                const SizedBox(width: 10),
                if (c.openViolations > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.redDanger.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${c.openViolations} violation${c.openViolations > 1 ? 's' : ''}',
                      style: const TextStyle(
                          color: AppTheme.redDanger,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  Text(c.contact,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),

                  // Key stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _miniStat('${(c.attendanceRate * 100).round()}%',
                          'Attendance', AppTheme.cobaltBlue),
                      _miniStat(
                          '${c.certifiedWorkers}/${c.workers}',
                          'Certified',
                          AppTheme.greenVerified),
                      _miniStat('${c.trainingDue}',
                          'Training Due', AppTheme.amberAccent),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Document status
                  const Text('DOCUMENTS',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.grey)),
                  const SizedBox(height: 6),
                  ...c.docs.map((d) => _buildDocStatus(d)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('View Workers',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.amberAccent,
                              foregroundColor: Colors.white),
                          child: const Text('Issue Notice',
                              style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocStatus(_DocStatus doc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            doc.valid ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: doc.valid ? AppTheme.greenVerified : AppTheme.redDanger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(doc.name,
                style: const TextStyle(fontSize: 11)),
          ),
          Text(doc.expiry,
              style: TextStyle(
                  fontSize: 10,
                  color: doc.valid ? Colors.grey : AppTheme.redDanger,
                  fontWeight: doc.valid
                      ? FontWeight.normal
                      : FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWorkerCard(_WorkerWithContractor wc) {
    final w = wc.worker;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.cobaltBlue.withAlpha(30),
            child: Text(
              w.name.substring(0, 1),
              style: const TextStyle(
                  color: AppTheme.cobaltBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(w.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${w.role} · ${wc.contractorName}',
                    style:
                        const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _workerBadge(w.attendance, 'Present', 'Absent'),
              const SizedBox(height: 4),
              _workerBadge(w.certified, 'Certified', 'Uncertified'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _workerBadge(bool ok, String trueLabel, String falseLabel) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: ok
            ? AppTheme.greenVerified.withAlpha(20)
            : AppTheme.redDanger.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        ok ? trueLabel : falseLabel,
        style: TextStyle(
            color: ok ? AppTheme.greenVerified : AppTheme.redDanger,
            fontSize: 9,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _miniStat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _stat(String val, String label, Color color) {
    return Column(
      children: [
        Text(val,
            style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _vLine() {
    return Container(width: 1, height: 36, color: Colors.white12);
  }
}

class _ContractorEntry {
  final String name;
  final String contact;
  final int workers;
  final int certifiedWorkers;
  final double attendanceRate;
  final int complianceScore;
  final int openViolations;
  final int trainingDue;
  final List<_DocStatus> docs;
  // ignore: non_constant_identifier_names
  final List<_WorkerEntry> workers_;

  _ContractorEntry({
    required this.name,
    required this.contact,
    required this.workers,
    required this.certifiedWorkers,
    required this.attendanceRate,
    required this.complianceScore,
    required this.openViolations,
    required this.trainingDue,
    required this.docs,
    // ignore: non_constant_identifier_names
    required this.workers_,
  });
}

class _DocStatus {
  final String name;
  final bool valid;
  final String expiry;
  _DocStatus(this.name, this.valid, this.expiry);
}

class _WorkerEntry {
  final String name;
  final String role;
  final bool certified;
  final bool attendance;
  final String status;
  _WorkerEntry(this.name, this.role, this.certified, this.attendance, this.status);
}

class _WorkerWithContractor {
  final _WorkerEntry worker;
  final String contractorName;
  _WorkerWithContractor(this.worker, this.contractorName);
}
