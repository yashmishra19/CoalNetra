import 'package:flutter/material.dart';

// Mock data strictly matching the KoylaNetra Regulator Web UI

class RegionMetrics {
  final String regionName;
  final int totalMines;
  final int coalMines;
  final int metalMines;
  final int inspectionsDone;
  final int inspectionsTarget;
  final int directionsOpen;
  final int fatalAccidents;
  final int seriousAccidents;
  final int returnsLate;
  final int pendingApps;

  const RegionMetrics({
    required this.regionName,
    required this.totalMines,
    required this.coalMines,
    required this.metalMines,
    required this.inspectionsDone,
    required this.inspectionsTarget,
    required this.directionsOpen,
    required this.fatalAccidents,
    required this.seriousAccidents,
    required this.returnsLate,
    required this.pendingApps,
  });
}

const nagpurRegionMetrics = RegionMetrics(
  regionName: 'Nagpur Region-2',
  totalMines: 118,
  coalMines: 31,
  metalMines: 87,
  inspectionsDone: 41,
  inspectionsTarget: 60,
  directionsOpen: 63,
  fatalAccidents: 4,
  seriousAccidents: 2,
  returnsLate: 22,
  pendingApps: 34,
);

class ProvenanceSegment {
  final String label;
  final double percentage;
  final Color color;
  final String establishedBy;
  final int count;

  const ProvenanceSegment({
    required this.label,
    required this.percentage,
    required this.color,
    required this.establishedBy,
    required this.count,
  });
}

const provenanceData = [
  ProvenanceSegment(
    label: 'Seen by an inspector',
    percentage: 0.31,
    color: Color(0xFF1E2129),
    establishedBy: 'Inspector on site',
    count: 187,
  ),
  ProvenanceSegment(
    label: 'Instrument reading',
    percentage: 0.24,
    color: Color(0xFF2C9C77),
    establishedBy: 'Instrument feed',
    count: 1244,
  ),
  ProvenanceSegment(
    label: 'Operator, hash sealed',
    percentage: 0.38,
    color: Color(0xFFB4A188),
    establishedBy: 'Operator, sealed',
    count: 8,
  ),
  ProvenanceSegment(
    label: 'Operator, unsealed',
    percentage: 0.07,
    color: Color(0xFFDC2626),
    establishedBy: 'Operator, unsealed',
    count: 22,
  ),
];

class InspectionPriority {
  final String mineName;
  final String subtitle;
  final int score;
  final String reason;

  const InspectionPriority({
    required this.mineName,
    required this.subtitle,
    required this.score,
    required this.reason,
  });
}

const inspectionPriorities = [
  InspectionPriority(
    mineName: 'Chandrapur UG-1',
    subtitle: 'Vidarbha Coal Resources - degree II gassy',
    score: 88,
    reason: 'Not inspected for 214 days. Ventilation plan amendment pending.',
  ),
  InspectionPriority(
    mineName: 'Demo OCP-1',
    subtitle: 'Western Coalfields - Yavatmal',
    score: 86,
    reason: 'Fatal accident 9 Sep. Direction of 22 Aug not complied with.',
  ),
  InspectionPriority(
    mineName: 'Quarry cluster, Nanded',
    subtitle: '14 operators - stone',
    score: 79,
    reason: 'Never inspected since registration. One travel day covers all 14.',
  ),
  InspectionPriority(
    mineName: 'Ballarpur OCP-4',
    subtitle: 'Western Coalfields - Chandrapur',
    score: 74,
    reason: 'Serious accident 22 Aug. Benching and sloping noted at last visit.',
  ),
];

class DisciplineCoverage {
  final String label;
  final int current;
  final int total;
  final Color color;

  const DisciplineCoverage({
    required this.label,
    required this.current,
    required this.total,
    required this.color,
  });
}

const disciplineCoverages = [
  DisciplineCoverage(label: 'Mining', current: 28, total: 36, color: Color(0xFFD97706)),
  DisciplineCoverage(label: 'Electrical', current: 7, total: 12, color: Color(0xFFDC2626)),
  DisciplineCoverage(label: 'Mechanical', current: 4, total: 8, color: Color(0xFFD97706)),
  DisciplineCoverage(label: 'Occupational health', current: 2, total: 6, color: Color(0xFFDC2626)),
];

class DefectFinding {
  final String label;
  final int count;
  final Color color;

  const DefectFinding({
    required this.label,
    required this.count,
    required this.color,
  });
}

const defectFindings = [
  DefectFinding(label: 'Benching and sloping', count: 42, color: Color(0xFFDC2626)),
  DefectFinding(label: 'Haul road and transport', count: 35, color: Color(0xFFDC2626)),
  DefectFinding(label: 'Support and strata', count: 24, color: Color(0xFFD97706)),
  DefectFinding(label: 'Electrical installations', count: 21, color: Color(0xFFD97706)),
];

class MockObservation {
  final String id;
  final String status;
  final String category;
  final String location;
  final String date;

  const MockObservation({
    required this.id,
    required this.status,
    required this.category,
    required this.location,
    required this.date,
  });
}

const mockObservations = [
  MockObservation(
    id: 'OBS-2026-042',
    status: 'Open',
    category: 'Haul Road Safety',
    location: 'Section 4, Upper Seam',
    date: '14 Sep 2026',
  ),
  MockObservation(
    id: 'OBS-2026-039',
    status: 'CAPA Raised',
    category: 'Dust Suppression',
    location: 'Loading Point C',
    date: '12 Sep 2026',
  ),
  MockObservation(
    id: 'OBS-2026-038',
    status: 'Closed',
    category: 'Electrical Panel',
    location: 'Substation B',
    date: '10 Sep 2026',
  ),
];

class MockContractor {
  final String name;
  final String licenceNo;
  final int workerCount;
  final String vtcExpiry;
  final bool vtcExpired;
  final String pmeExpiry;
  final bool licenceExpired;

  const MockContractor({
    required this.name,
    required this.licenceNo,
    required this.workerCount,
    required this.vtcExpiry,
    required this.vtcExpired,
    required this.pmeExpiry,
    this.licenceExpired = false,
  });
}

const mockContractors = [
  MockContractor(
    name: 'Bharat Mining Works',
    licenceNo: 'LIC/2024/0089',
    workerCount: 124,
    vtcExpiry: '12 Oct 2026',
    vtcExpired: false,
    pmeExpiry: '15 Nov 2026',
  ),
  MockContractor(
    name: 'Dynamic Earthmovers',
    licenceNo: 'LIC/2023/0412',
    workerCount: 45,
    vtcExpiry: '02 Sep 2026',
    vtcExpired: true,
    pmeExpiry: '10 Jan 2027',
  ),
];

const complianceTrendData = [88.0, 90.5, 87.2, 92.4, 91.0, 94.5];

class RiskVector {
  final String label;
  final double value;
  final bool isCritical;
  final bool isWarning;

  const RiskVector({
    required this.label,
    required this.value,
    this.isCritical = false,
    this.isWarning = false,
  });
}
