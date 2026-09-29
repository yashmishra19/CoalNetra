import { Router } from 'express';

const router = Router();

const regulatorData = {
  user: {
    name: 'P.B. Kulkarni',
    role: 'Director of Mines Safety',
    initials: 'PK'
  },

  jurisdiction: {
    region: 'Nagpur Region-2',
    month: 'September 2026',
    description: 'All mines in six districts, whoever operates them. This office sees statutory submissions, its own inspection findings and aggregate trends. It does not receive an operational feed.',
    districts: 'Chandrapur, Yavatmal, Nanded, Latur, Beed and Osmanabad districts. All mines, all operators.',
    feedStatus: 'Statutory feed current to 10 Sep 16:00'
  },

  alert: {
    title: 'Fatal accident notified by WCL, Demo OCP-1, Yavatmal district',
    body: "Reported by telephone 9 Sep 22:31. Written notice received 10 Sep 08:40, inside the 24 hour window. Stated cause is a haul road berm, which is the subject of this office's direction of 22 August to four mines in the same district.",
    responseTime: '10 h 22',
    responseLabel: 'inside window',
    cta: 'Fix the inquiry'
  },

  kpis: [
    { id: 'mines', label: 'Mines in jurisdiction', value: '118', detail: '31 coal, 87 metal and minor minerals' },
    { id: 'inspections', label: 'Inspections this quarter', value: '41', suffix: 'of 60', detail: '68%. 19 mines are past their interval.' },
    { id: 'directions', label: 'Directions open', value: '63', detail: '19 past their compliance date' },
    { id: 'accidents', label: 'Accidents notified, 2026', value: '4', suffix: 'fatal', detail: '14 serious, 2 notices arrived late.', tone: 'critical' },
    { id: 'returns', label: 'Returns late or missing', value: '22', suffix: 'mines', detail: '8 have defaulted more than once' },
    { id: 'applications', label: 'Applications pending', value: '34', detail: '9 beyond the service standard. Oldest 71 days.' }
  ],

  operators: [
    { id: 'op1', name: 'Western Coalfields', subtitle: '5 areas', type: 'Coal, PSU', mines: 24, inspected: '71%', fatal: 3, serious: 9, dirOpen: 24, overdue: 8, returns: 'All filed', returnsTone: 'good' },
    { id: 'op2', name: 'Vidarbha Coal Resources', subtitle: 'Chandrapur', type: 'Coal, private', mines: 5, inspected: '44%', fatal: 1, serious: 3, dirOpen: 11, overdue: 6, returns: '2 missing', returnsTone: 'critical' },
    { id: 'op3', name: 'Wardha Power Captive', subtitle: 'Yavatmal', type: 'Coal, captive', mines: 2, inspected: '50%', fatal: 0, serious: 1, dirOpen: 6, overdue: 2, returns: '1 late', returnsTone: 'warning' },
    { id: 'op4', name: 'Manganese Ore India', subtitle: 'Nanded, Beed', type: 'Metal', mines: 6, inspected: '67%', fatal: 0, serious: 1, dirOpen: 5, overdue: 1, returns: 'All filed', returnsTone: 'good' },
    { id: 'op5', name: 'Godavari Limestone', subtitle: 'Latur, Osmanabad', type: 'Minor mineral', mines: 9, inspected: '33%', fatal: 0, serious: 0, dirOpen: 7, overdue: 1, returns: '3 late', returnsTone: 'warning' },
    { id: 'op6', name: '72 small quarry operators', subtitle: 'All six districts', type: 'Minor mineral', mines: 72, inspected: '18%', fatal: 0, serious: 0, dirOpen: 10, overdue: 1, returns: '16 missing', returnsTone: 'critical' }
  ],

  inspectorPriorities: [
    { rank: 1, name: 'Chandrapur UG-1', subtitle: 'Vidarbha Coal Resources - degree II gassy', score: 88, note: 'Not inspected for 214 days. Ventilation plan amendment pending with this office.' },
    { rank: 2, name: 'Demo OCP-1', subtitle: 'Western Coalfields - Yavatmal', score: 86, note: 'Fatal accident 9 Sep. Direction of 22 Aug not complied with.' },
    { rank: 3, name: 'Quarry cluster, Nanded', subtitle: '14 operators - stone', score: 79, note: 'Never inspected since registration. One travel day covers all 14.' },
    { rank: 4, name: 'Ballarpur OCP-4', subtitle: 'Western Coalfields - Chandrapur', score: 74, note: 'Serious accident 22 Aug. Benching and sloping noted at last visit.' },
    { rank: 5, name: 'Godavari Limestone, Latur 3', subtitle: 'Minor mineral', score: 71, note: "Two returns late. No manager's certificate recorded against the mine." }
  ],

  dataReliability: {
    segments: [
      { label: 'Seen by an inspector', value: 31, color: '#1e293b' },
      { label: 'Instrument reading', value: 24, color: '#6b7280' },
      { label: 'Operator, hash sealed', value: 38, color: '#d97706' },
      { label: 'Operator, unsealed', value: 7, color: '#dc2626' }
    ],
    explanation: "Sealed means the record's fingerprint was written to the ledger when it was created, so any later change is detectable. Unsealed records come from operators still filling outside the platform, and carry no such guarantee. They are marked wherever they appear.",
    cta: 'Open assurance'
  },

  directions: [
    { id: 'da1', direction: 'Provide berms of the required height on all contractor haul roads', subtitle: 'Inadequate benching and sloping in opencast workings', mineOperator: '4 mines, WCL', mineLocation: 'Yavatmal and Chandrapur', issued: '22 Aug', overdue: '26 d', evidence: 'Photographs, unsealed', evidenceTone: 'warning', nextStep: 'Consider prohibition' },
    { id: 'da2', direction: 'Complete dump slope stability study before further dumping', subtitle: null, mineOperator: 'Chandrapur OCP-2, WCL', mineLocation: null, issued: '14 Jun', overdue: '38 d', evidence: 'Study, draft only', evidenceTone: 'warning', nextStep: 'Consider prohibition' },
    { id: 'da3', direction: 'Appoint a qualified manager and second class supervisory official', subtitle: 'Non-appointment of qualified manager', mineOperator: 'Latur 3, Godavari Limestone', mineLocation: null, issued: '2 Jul', overdue: '31 d', evidence: 'Nothing received', evidenceTone: 'critical', nextStep: 'Consider prohibition' },
    { id: 'da4', direction: 'Submit revised ventilation plan after district extension', subtitle: null, mineOperator: 'Chandrapur UG-1, Vidarbha Coal', mineLocation: null, issued: '3 Jul', overdue: '14 d', evidence: 'Plan filed 8 Sep', evidenceTone: 'good', nextStep: 'Verify on site' },
    { id: 'da5', direction: 'Fence and signpost the abandoned incline', subtitle: null, mineOperator: 'Nanded quarry 7, private', mineLocation: null, issued: '18 Jul', overdue: '9 d', evidence: 'Nothing received', evidenceTone: 'critical', nextStep: 'Issue reminder' },
    { id: 'da6', direction: 'Reduce blasting near the village boundary to two rounds per day', subtitle: null, mineOperator: 'Wani OCP-2, WCL', mineLocation: null, issued: '11 Aug', overdue: 'Due 30 Sep', overdueTone: 'warning', evidence: 'Vibration records', evidenceTone: 'good', nextStep: 'Open' }
  ],

  notices: [
    { id: 'nr1', title: 'Fatal accident, Demo OCP-1', source: 'WCL · 9 Sep 22:02', responseTime: '10 h 22', responseOf: 'of 24 h', status: 'inTime' },
    { id: 'nr2', title: 'Serious injury, Ballarpur OCP-4', source: 'WCL · 22 Aug 14:10', responseTime: '19 h 05', responseOf: 'of 24 h', status: 'inTime' },
    { id: 'nr3', title: 'Dangerous occurrence, rope', source: 'Chandrapur UG-1 · 2 Aug 06:40', responseTime: '41 h 30', responseOf: 'of 24 h', status: 'late' },
    { id: 'nr4', title: 'Fatal accident, quarry', source: 'Nanded quarry 4 · 19 May', responseTime: '6 days', responseOf: 'of 24 h', status: 'late' }
  ],

  districts: [
    { name: 'Chandrapur', mines: 18, coverage: '71%' },
    { name: 'Yavatmal', mines: 21, coverage: '62%' },
    { name: 'Nanded', mines: 29, coverage: '24%' },
    { name: 'Beed', mines: 16, coverage: '31%' },
    { name: 'Latur', mines: 19, coverage: '21%' },
    { name: 'Osmanabad', mines: 15, coverage: '27%' }
  ],

  footnote: 'Demo data. The zone, region, district jurisdiction and the statutory framework are real. Mine names, operators other than WCL, officers and all readings are illustrative.'
};

router.get('/', (req, res) => {
  res.json(regulatorData);
});

const minesRegisterData = {
  header: {
    title: 'Mines register',
    description: 'Every mine in the six districts of this region, whoever operates it and whatever it produces. Registration, certificates and interval status in one list.'
  },

  kpis: [
    { id: 'registered', label: 'Mines registered', value: 118 },
    { id: 'coal', label: 'Coal, of which 9 underground', value: 31 },
    { id: 'pastInterval', label: 'Past inspection interval', value: 19, dot: 'critical' },
    { id: 'noCert', label: "No manager's certificate on record", value: 7, dot: 'critical' },
    { id: 'prohibition', label: 'Under a prohibition order', value: 3, dot: 'critical' }
  ],

  filterTabs: [
    { id: 'attention', label: 'Needs attention', active: true },
    { id: 'coal', label: 'Coal (31)' },
    { id: 'underground', label: 'Underground (9)' },
    { id: 'minor', label: 'Minor mineral (87)' },
    { id: 'neverInspected', label: 'Never inspected (23)' }
  ],

  registerMeta: 'Showing 12 of 118, sorted by interval overdue',

  mines: [
    { id: 'm1', name: 'Nanded quarry cluster', subtitle: '14 mines, one lease block', operator: '14 small operators', district: 'Nanded', type: 'Stone', gassiness: '—', manager: null, managerNote: 'None recorded', managerTone: 'critical', persons: '~310', lastSeen: 'Never', lastSeenTone: 'critical', standing: 'Unverified', standingTone: 'warning' },
    { id: 'm2', name: 'Chandrapur UG-1', subtitle: null, operator: 'Vidarbha Coal Resources', district: 'Chandrapur', type: 'Coal, UG', gassiness: 'Degree II', manager: 'S. Deshpande, 1st class', managerTone: null, persons: '412', lastSeen: '214 d', lastSeenTone: 'critical', standing: 'Interval passed', standingTone: 'warning' },
    { id: 'm3', name: 'Latur 3', subtitle: null, operator: 'Godavari Limestone', district: 'Latur', type: 'Limestone', gassiness: '—', manager: null, managerNote: 'None recorded', managerTone: 'critical', persons: '86', lastSeen: '181 d', lastSeenTone: 'critical', standing: 'Direction open', standingTone: 'critical' },
    { id: 'm4', name: 'Osmanabad quarry 9', subtitle: null, operator: 'Private, single lease', district: 'Osmanabad', type: 'Murram', gassiness: '—', manager: 'Not required, under 50', managerTone: null, persons: '31', lastSeen: 'Never', lastSeenTone: 'critical', standing: 'Unverified', standingTone: 'warning' },
    { id: 'm5', name: 'Demo OCP-1', subtitle: null, operator: 'Western Coalfields', district: 'Yavatmal', type: 'Coal, OC', gassiness: '—', manager: 'R. K. Mahato, 1st class', managerTone: null, persons: '1,840', lastSeen: '1 d', lastSeenTone: null, standing: 'Fatal accident 9 Sep', standingTone: 'critical' },
    { id: 'm6', name: 'Ballarpur OCP-4', subtitle: null, operator: 'Western Coalfields', district: 'Chandrapur', type: 'Coal, OC', gassiness: '—', manager: 'V. Ingle, 1st class', managerTone: null, persons: '1,210', lastSeen: '19 d', lastSeenTone: 'warning', standing: 'Direction open', standingTone: 'critical' },
    { id: 'm7', name: 'Ballarpur UG-1', subtitle: null, operator: 'Western Coalfields', district: 'Chandrapur', type: 'Coal, UG', gassiness: 'Degree II', manager: 'A. Gaikwad, 1st class', managerTone: null, persons: '690', lastSeen: '64 d', lastSeenTone: null, standing: 'In order', standingTone: 'good' },
    { id: 'm8', name: 'Wardha captive block', subtitle: null, operator: 'Wardha Power Captive', district: 'Yavatmal', type: 'Coal, OC', gassiness: '—', manager: 'P. Sharma, 1st class', managerTone: null, persons: '540', lastSeen: '78 d', lastSeenTone: 'warning', standing: 'In order', standingTone: 'good' },
    { id: 'm9', name: 'Beed manganese 2', subtitle: null, operator: 'Manganese Ore India', district: 'Beed', type: 'Manganese, UG', gassiness: '—', manager: 'K. Rathod, 2nd class', managerTone: null, persons: '204', lastSeen: '52 d', lastSeenTone: null, standing: 'In order', standingTone: 'good' },
    { id: 'm10', name: 'Chandrapur OCP-2', subtitle: null, operator: 'Western Coalfields', district: 'Chandrapur', type: 'Coal, OC', gassiness: '—', manager: 'S. Kale, 1st class', managerTone: null, persons: '870', lastSeen: '37 d', lastSeenTone: null, standing: 'Direction open', standingTone: 'critical' },
    { id: 'm11', name: 'Wani OCP-2', subtitle: null, operator: 'Western Coalfields', district: 'Yavatmal', type: 'Coal, OC', gassiness: '—', manager: 'D. Meshram, 1st class', managerTone: null, persons: '1,050', lastSeen: '26 d', lastSeenTone: null, standing: 'In order', standingTone: 'good' },
    { id: 'm12', name: 'Nanded limestone 1', subtitle: null, operator: 'Godavari Limestone', district: 'Nanded', type: 'Limestone', gassiness: '—', manager: 'M. Jadhav, 2nd class', managerTone: null, persons: '112', lastSeen: '88 d', lastSeenTone: 'warning', standing: 'In order', standingTone: 'good' }
  ],

  registerFootnote: "23 mines in this region have never been inspected since registration, and 21 of them are small quarries. Seven mines have no manager's certificate recorded, which is itself a contravention and the most common ground for action in this region.",

  composition: [
    { type: 'Stone and murram', count: 72, maxCount: 72 },
    { type: 'Coal, opencast', count: 22, maxCount: 72 },
    { type: 'Limestone', count: 15, maxCount: 72 },
    { type: 'Coal, underground', count: 9, maxCount: 72 },
    { type: 'Manganese', count: 6, maxCount: 72 }
  ],

  compositionFootnote: '61% of the mines are small quarries employing about 9% of the persons. 31 coal mines employ 78%. Inspection effort has to be split between where the people are and where oversight is weakest.',

  certificates: [
    { id: 'c1', post: 'Manager, first class', required: 31, recorded: 29, gap: 2, standing: 'Action open', standingTone: 'critical' },
    { id: 'c2', post: 'Manager, second class', required: 24, recorded: 19, gap: 5, standing: 'Action open', standingTone: 'critical' },
    { id: 'c3', post: 'Safety officer', required: 18, recorded: 18, gap: 0, standing: 'In order', standingTone: 'good' },
    { id: 'c4', post: 'Surveyor', required: 31, recorded: 30, gap: 1, standing: 'Following up', standingTone: 'warning' },
    { id: 'c5', post: 'Ventilation officer, UG', required: 9, recorded: 9, gap: 0, standing: 'In order', standingTone: 'good' },
    { id: 'c6', post: 'Engineer, electrical', required: 31, recorded: 28, gap: 3, standing: 'Following up', standingTone: 'warning' }
  ],

  certificatesFootnote: 'Every gap here is a standing contravention. Five of the seven are at minor mineral mines.',

  pageFootnote: 'Demo data. Jurisdiction and statutory framework are real; mines, operators and figures are illustrative.'
};

router.get('/mines-register', (req, res) => {
  res.json(minesRegisterData);
});

const inspectionsData = {
  header: {
    title: 'Inspections',
    description: "Inspector time is the constraint in this office. This page allocates it and records what was found, by discipline."
  },

  kpis: [
    { id: 'thisQuarter', label: 'Inspections this quarter', value: '41', suffix: 'of 60', detail: '68% of the planned programme', barColor: 'info', barPercent: 68 },
    { id: 'pastInterval', label: 'Past interval', value: '19', suffix: 'mines', detail: 'Longest gap 214 days', barColor: 'critical', barPercent: 100 },
    { id: 'neverInspected', label: 'Never inspected', value: '23', suffix: 'mines', detail: '21 are small quarries', barColor: 'critical', barPercent: 100 },
    { id: 'officers', label: 'Inspecting officers', value: '4', suffix: null, detail: '2 mining, 1 electrical, 1 mechanical', barColor: 'info', barPercent: 40 },
    { id: 'findings', label: 'Findings this quarter', value: '187', suffix: null, detail: '61 still to be complied with', barColor: 'warning', barPercent: 85 },
    { id: 'avgDays', label: 'Average days on tour', value: '11', suffix: 'of 20', detail: 'Travel takes about 3 days a month', barColor: 'info', barPercent: 55 }
  ],

  proposedPlan: {
    title: 'Proposed plan, October 2026',
    subtitle: 'Generated from risk, interval and travel clustering. Edit before issuing.',
    items: [
      { id: 'pp1', days: '1-2 Oct', mine: 'Chandrapur UG-1', district: 'Chandrapur', officer: 'Dy. Director (Mining)', discipline: 'Mining, electrical', why: '214 days since last visit, degree II' },
      { id: 'pp2', days: '6 Oct', mine: 'Demo OCP-1', district: 'Yavatmal', officer: 'Director', discipline: 'Mining', why: 'Fatal accident follow-up, direction not complied' },
      { id: 'pp3', days: '7-8 Oct', mine: 'Wani OCP-2 and OCP-3', district: 'Yavatmal', officer: 'Director', discipline: 'Mining', why: 'Same tour, blasting direction due 30 Sep' },
      { id: 'pp4', days: '13-14 Oct', mine: 'Nanded quarry cluster, 14 mines', district: 'Nanded', officer: 'Dy. Director (Mining)', discipline: 'Mining', why: 'Never inspected, one travel day covers all' },
      { id: 'pp5', days: '15 Oct', mine: 'Nanded limestone 1', district: 'Nanded', officer: 'Dy. Director (Mining)', discipline: 'Mining', why: 'Same tour, 88 days' },
      { id: 'pp6', days: '20 Oct', mine: 'Ballarpur OCP-4', district: 'Chandrapur', officer: 'Dy. Director (Mech)', discipline: 'Mechanical', why: 'Serious accident, dumper braking' },
      { id: 'pp7', days: '21 Oct', mine: 'Ballarpur UG-1', district: 'Chandrapur', officer: 'Dy. Director (Elec)', discipline: 'Electrical', why: 'Same tour, cable joints reported' },
      { id: 'pp8', days: '27-28 Oct', mine: 'Latur 3 and Osmanabad 9', district: 'Latur, Osmanabad', officer: 'Dy. Director (Mining)', discipline: 'Mining', why: 'No manager recorded at both' }
    ],
    footnote: 'This plan visits 23 mines in 11 field days and clears 17 of the 19 that are past interval. The two it does not reach are in Beed and would need a separate tour in November.'
  },

  coverageByDiscipline: [
    { discipline: 'Mining', done: 28, total: 36, color: 'warning' },
    { discipline: 'Electrical', done: 7, total: 12, color: 'critical' },
    { discipline: 'Mechanical', done: 4, total: 6, color: 'warning' },
    { discipline: 'Occupational health', done: 2, total: 6, color: 'critical' }
  ],
  coverageFootnote: 'Occupational health is the weakest discipline and has no dedicated officer posted to this region. Dust and noise findings are therefore under-detected, not absent.',

  findingsByDefect: [
    { defect: 'Benching and sloping', count: 42, color: 'critical' },
    { defect: 'Haul road and transport', count: 35, color: 'critical' },
    { defect: 'Support and strata', count: 24, color: 'warning' },
    { defect: 'Electrical installations', count: 21, color: 'warning' },
    { defect: 'Qualified appointments', count: 18, color: 'warning' },
    { defect: 'Dust and ventilation', count: 15, color: 'info' },
    { defect: 'Machinery guarding', count: 13, color: 'info' },
    { defect: 'Miscellaneous', count: 19, color: 'info' }
  ],
  findingsFootnote: "Categories follow the headings used in the Directorate's annual returns, so quarterly figures can be sent up to Zone without re-coding.",

  recentInspections: [
    { id: 'ri1', date: '5 Sep', mine: 'Wani OCP-3, WCL', officer: 'Dy. Director (Mining)', discipline: 'Mining', findings: 9, open: 6, actionTaken: 'Improvement notice', actionTone: null, report: 'Open' },
    { id: 'ri2', date: '2 Sep', mine: 'Beed manganese 2', officer: 'Dy. Director (Mining)', discipline: 'Mining', findings: 4, open: 1, actionTaken: 'Verbal, recorded', actionTone: null, report: 'Open' },
    { id: 'ri3', date: '28 Aug', mine: 'Osmanabad quarry 4', officer: 'Director', discipline: 'Mining', findings: 11, open: 11, actionTaken: 'Prohibition order', actionTone: 'critical', report: 'Open' },
    { id: 'ri4', date: '24 Aug', mine: 'Ballarpur OCP-4, WCL', officer: 'Dy. Director (Mech)', discipline: 'Mechanical', findings: 7, open: 3, actionTaken: 'Direction issued', actionTone: null, report: 'Open' },
    { id: 'ri5', date: '19 Aug', mine: 'Chandrapur OCP-2, WCL', officer: 'Dy. Director (Elec)', discipline: 'Electrical', findings: 6, open: 2, actionTaken: 'Improvement notice', actionTone: null, report: 'Open' },
    { id: 'ri6', date: '12 Aug', mine: 'Wardha captive block', officer: 'Dy. Director (Mining)', discipline: 'Mining', findings: 5, open: 0, actionTaken: 'Complied on site', actionTone: null, report: 'Open' }
  ],

  pageFootnote: 'Demo data. Jurisdiction and statutory framework are real; mines, operators and figures are illustrative.'
};

router.get('/inspections', (req, res) => {
  res.json(inspectionsData);
});

const directionsData = {
  header: {
    title: 'Directions and prohibitions',
    description: "What this office has ordered, what evidence came back, and where the enforcement ladder has been climbed. Every step is recorded with its date and author."
  },

  kpis: [
    { id: 'open', label: 'Directions open', value: 63 },
    { id: 'pastDate', label: 'Past compliance date', value: 19, dot: 'critical' },
    { id: 'prohibitions', label: 'Prohibition orders in force', value: 3, dot: 'critical' },
    { id: 'complied', label: 'Complied and closed, 2026', value: 41 },
    { id: 'median', label: 'Median time to compliance', value: '38', suffix: 'd' }
  ],

  focusedDirection: {
    title: 'Direction: haul road berms, four mines',
    badge: '26 days overdue',
    description: 'Issued 22 August to four Western Coalfields mines in Yavatmal and Chandrapur, following inspections at two of them. The defect falls under inadequate benching and sloping in opencast workings.',
    steps: [
      { number: 1, label: 'Observation recorded', active: false },
      { number: 2, label: 'Improvement notice', active: false },
      { number: 3, label: 'Written direction', active: false },
      { number: 4, label: 'Prohibition order', active: true }
    ],
    stepsNote: 'This office normally moves to step 4 when a direction has been open 21 days past its date with no acceptable evidence. That point passed five days ago.',
    complianceTable: [
      { id: 'fc1', mine: 'Demo OCP-1', due: '15 Aug', evidence: 'Photos, no location data', evidenceTone: 'warning', evidenceIcon: true, status: 'Not complied', statusTone: 'critical' },
      { id: 'fc2', mine: 'Wani OCP-3', due: '15 Aug', evidence: 'Nothing received', evidenceTone: 'critical', evidenceIcon: false, status: 'Not complied', statusTone: 'critical' },
      { id: 'fc3', mine: 'Ballarpur OCP-4', due: '15 Aug', evidence: 'Photos, geo-tagged, sealed', evidenceTone: 'good', evidenceIcon: true, status: 'Partly complied', statusTone: 'warning' },
      { id: 'fc4', mine: 'Ballarpur OCP-2', due: '15 Aug', evidence: 'Verified on site 24 Aug', evidenceTone: 'good', evidenceIcon: true, status: 'Complied', statusTone: 'good' }
    ],
    footnote: 'One mine complied and was verified. Two produced nothing acceptable, and a fatal accident then occurred at one of them citing the same defect. That sequence is the record if this proceeds further.'
  },

  prohibitionOrders: {
    title: 'Prohibition orders in force',
    subtitle: 'Work stopped in whole or part',
    items: [
      { id: 'po1', mine: 'Osmanabad quarry 4', scope: 'Whole mine', from: '28 Aug', days: 13, ground: 'Overhanging face, no benching' },
      { id: 'po2', mine: 'Nanded quarry 11', scope: 'Whole mine', from: '2 Jul', days: 70, ground: 'No qualified manager appointed' },
      { id: 'po3', mine: 'Chandrapur UG-1', scope: 'District 4 only', from: '19 May', days: 114, ground: 'Ventilation below standard' }
    ],
    footnote: 'Each order names the officer, the ground and the condition for revocation.'
  },

  complianceOutcomes: {
    title: 'What happens after a direction',
    subtitle: 'Last 24 months, this region',
    items: [
      { label: 'Complied by date', value: 46, color: 'info' },
      { label: 'Complied late', value: 31, color: 'warning' },
      { label: 'Still open', value: 18, color: 'critical' },
      { label: 'Escalated to prohibition', value: 5, color: 'critical' }
    ],
    footnote: 'Compliance by date is better where evidence was verified on site than where it was accepted on paper. That difference is the argument for geo-tagged, sealed evidence.'
  },

  allOpenDirections: {
    title: 'All open directions',
    meta: '63 open, 19 past date',
    filterTabs: [
      { id: 'pastDate', label: 'Past date (19)', active: true },
      { id: 'allOpen', label: 'All open (63)' },
      { id: 'noEvidence', label: 'No evidence at all (11)' },
      { id: 'repeatDefect', label: 'Repeat defect (7)' }
    ],
    items: [
      { id: 'ad1', direction: 'Complete dump slope stability study', mine: 'Chandrapur OCP-2', operator: 'WCL', issued: '14 Jun', pastDate: '38 d', pastDateTone: 'critical', evidence: 'Draft only', evidenceTone: 'warning', evidenceIcon: true, repeat: '3rd time', repeatTone: 'critical', action: 'Escalate', actionTone: 'critical' },
      { id: 'ad2', direction: 'Appoint a qualified manager', mine: 'Latur 3', operator: 'Godavari Limestone', issued: '2 Jul', pastDate: '31 d', pastDateTone: 'critical', evidence: 'None', evidenceTone: 'critical', evidenceIcon: false, repeat: '2nd time', repeatTone: 'critical', action: 'Escalate', actionTone: 'critical' },
      { id: 'ad3', direction: 'Provide berms of required height', mine: '4 mines', operator: 'WCL', issued: '22 Aug', pastDate: '26 d', pastDateTone: 'critical', evidence: 'Photos only', evidenceTone: 'warning', evidenceIcon: true, repeat: '2nd time', repeatTone: 'critical', action: 'Escalate', actionTone: 'critical' },
      { id: 'ad4', direction: 'Submit revised ventilation plan', mine: 'Chandrapur UG-1', operator: 'Vidarbha Coal', issued: '3 Jul', pastDate: '14 d', pastDateTone: 'warning', evidence: 'Filed 8 Sep', evidenceTone: 'good', evidenceIcon: true, repeat: 'First', repeatTone: null, action: 'Verify', actionTone: 'good' },
      { id: 'ad5', direction: 'Fence and signpost the abandoned incline', mine: 'Nanded quarry 7', operator: 'Private', issued: '18 Jul', pastDate: '9 d', pastDateTone: 'critical', evidence: 'None', evidenceTone: 'critical', evidenceIcon: false, repeat: 'First', repeatTone: null, action: 'Remind', actionTone: 'neutral' },
      { id: 'ad6', direction: 'Guard the crusher drive and install emergency stop', mine: 'Nanded limestone 1', operator: 'Godavari Limestone', issued: '26 Jul', pastDate: '7 d', pastDateTone: 'warning', evidence: 'Photos, sealed', evidenceTone: 'good', evidenceIcon: true, repeat: 'First', repeatTone: null, action: 'Verify', actionTone: 'good' },
      { id: 'ad7', direction: 'Stop dumping on the upper bench until study is complete', mine: 'Ballarpur OCP-4', operator: 'WCL', issued: '24 Aug', pastDate: '4 d', pastDateTone: 'warning', evidence: 'Slope radar feed', evidenceTone: 'good', evidenceIcon: true, repeat: 'First', repeatTone: null, action: 'Verify', actionTone: 'good' }
    ],
    footnote: 'Seven of the nineteen are repeats of a defect previously directed at the same mine. Repetition is the strongest ground for moving up the ladder and is flagged automatically.'
  },

  pageFootnote: 'Demo data. Jurisdiction and statutory framework are real; mines, operators and figures are illustrative.'
};

router.get('/directions', (req, res) => {
  res.json(directionsData);
});

const accidentsData = {
  header: {
    title: 'Accidents and inquiries',
    description: "Whether each event was notified within the statutory window, what the inquiry found, and whether its recommendations were carried out."
  },

  kpis: [
    { id: 'fatal', label: 'Fatal accidents, 2026', value: 4, barColor: 'critical' },
    { id: 'serious', label: 'Serious bodily injuries', value: 14, detail: '3 coal, 1 minor mineral', barColor: 'critical' },
    { id: 'dangerous', label: 'Dangerous occurrences', value: 9, detail: '11 coal, 3 other', barColor: 'warning' },
    { id: 'lateNotices', label: 'Notices received late', value: '2', suffix: 'of 27', detail: 'Reportable, no injury', barColor: 'warning' },
    { id: 'inquiriesOpen', label: 'Inquiries open', value: 2, detail: 'Both from minor mineral mines', barColor: 'info' },
    { id: 'recsOpen', label: 'Recommendations open', value: '17', suffix: 'of 44', detail: '1 report due in 6 days', barColor: 'info' }
  ],

  notifications: {
    title: 'Notifications and the statutory window',
    subtitle: '2026, all mines. Late notification is recorded as a contravention.',
    items: [
      { id: 'n1', event: 'Fatal, dumper struck operator', mineOperator: 'Demo OCP-1, WCL', occurred: '9 Sep 22:02', phoned: '9 Sep 22:31', writtenNotice: '10 Sep 08:40', window: 'In time', windowTone: 'good', inquiry: 'Report due 16 Sep', inquiryTone: 'warning' },
      { id: 'n2', event: 'Serious, fall from height', mineOperator: 'Ballarpur OCP-4, WCL', occurred: '22 Aug 14:10', phoned: '22 Aug 14:50', writtenNotice: '23 Aug 09:15', window: 'In time', windowTone: 'good', inquiry: 'Not required', inquiryTone: null },
      { id: 'n3', event: 'Dangerous occurrence, winding rope', mineOperator: 'Chandrapur UG-1, Vidarbha Coal', occurred: '2 Aug 06:40', phoned: '3 Aug 11:20', writtenNotice: '4 Aug 00:10', window: 'Late by 17 h', windowTone: 'critical', inquiry: 'Open', inquiryTone: 'info' },
      { id: 'n4', event: 'Fatal, roof fall', mineOperator: 'Ballarpur UG-1, WCL', occurred: '14 Jun 03:20', phoned: '14 Jun 03:55', writtenNotice: '14 Jun 16:30', window: 'In time', windowTone: 'good', inquiry: 'Closed 2 Aug', inquiryTone: null },
      { id: 'n5', event: 'Fatal, face collapse', mineOperator: 'Nanded quarry 4, private', occurred: '19 May', phoned: null, phonedNote: 'Not phoned', phonedTone: 'critical', writtenNotice: '25 May', window: 'Late by 6 d', windowTone: 'critical', inquiry: 'Closed 30 Jul', inquiryTone: null },
      { id: 'n6', event: 'Fatal, electrocution', mineOperator: 'Wani OCP-3, WCL', occurred: '8 Apr 11:05', phoned: '8 Apr 11:30', writtenNotice: '8 Apr 19:45', window: 'In time', windowTone: 'good', inquiry: 'Closed 12 Jun', inquiryTone: null }
    ],
    footnote: 'Both late notifications came from mines with no safety officer on record. Neither operator files through the platform, so their submissions arrive unsealed and cannot be time-verified independently.'
  },

  causes: [
    { label: 'Transport machinery', count: 7, color: 'critical', maxCount: 7 },
    { label: 'Fall of roof or side', count: 5, color: 'critical', maxCount: 7 },
    { label: 'Fall of person', count: 3, color: 'warning', maxCount: 7 },
    { label: 'Electricity', count: 2, color: 'warning', maxCount: 7 },
    { label: 'Machinery, non-transport', count: 1, color: 'info', maxCount: 7 }
  ],
  causesFootnote: 'Transport machinery leads here as it does nationally. Six of the seven were at opencast mines and four involved contractor-operated haul roads.',

  inquiryRecommendations: {
    title: 'Inquiry recommendations',
    subtitle: 'Tracked to closure',
    items: [
      { id: 'ir1', from: 'Fatal, haul road, Aug 2025', made: 9, open: 4, oldest: '386 d', oldestTone: 'critical' },
      { id: 'ir2', from: 'Fatal, roof fall, Jun 2026', made: 11, open: 5, oldest: '88 d', oldestTone: 'warning' },
      { id: 'ir3', from: 'Fatal, quarry face, May 2026', made: 7, open: 3, oldest: '104 d', oldestTone: 'critical' },
      { id: 'ir4', from: 'Fatal, electrocution, Apr 2026', made: 8, open: 2, oldest: '155 d', oldestTone: 'critical' },
      { id: 'ir5', from: 'Dangerous occurrence, 2025', made: 9, open: 3, oldest: '241 d', oldestTone: 'critical' }
    ],
    footnote: 'The haul road inquiry of August 2025 still has four recommendations open, and a fatal accident on 9 September cited the same defect. That link is put in front of the officer automatically.'
  },

  pageFootnote: 'Demo data. Jurisdiction and statutory framework are real; mines, operators and figures are illustrative.'
};

router.get('/accidents', (req, res) => {
  res.json(accidentsData);
});

const permissionsData = {
  header: {
    title: 'Permissions, approvals and exemptions',
    description: "Applications waiting on this office, with the age of each against its own service standard. Status is mirrored from the Directorate's permission and approval modules."
  },

  kpis: [
    { id: 'pending', label: 'Pending with this office', value: 34 },
    { id: 'beyondStandard', label: 'Beyond the service standard', value: 9, dot: 'critical' },
    { id: 'oldest', label: 'Oldest pending', value: '71', suffix: 'd', dot: 'critical' },
    { id: 'median', label: 'Median time to dispose', value: '26', suffix: 'd' },
    { id: 'awaitingPapers', label: 'Awaiting papers from the applicant', value: 12, dot: 'warning' }
  ],

  filterTabs: [
    { id: 'beyondStandard', label: 'Beyond standard (9)', active: true },
    { id: 'allPending', label: 'All pending (34)' },
    { id: 'withOffice', label: 'With this office (22)' },
    { id: 'withApplicant', label: 'With applicant (12)' }
  ],

  applicationsMeta: 'Oldest first',

  applications: [
    { id: 'ap1', application: 'Working below a water body, district 6', mineOperator: 'Ballarpur UG-1, WCL', kind: 'Permission', age: '71 d', ageTone: 'critical', standard: '45 d', heldBy: 'This office', action: 'Dispose', actionTone: 'critical' },
    { id: 'ap2', application: 'Relaxation, dimensions of galleries', mineOperator: 'Chandrapur UG-1, Vidarbha Coal', kind: 'Relaxation', age: '64 d', ageTone: 'critical', standard: '45 d', heldBy: 'This office', action: 'Dispose', actionTone: 'critical' },
    { id: 'ap3', application: 'Use of a diesel vehicle below ground', mineOperator: 'Ballarpur UG-1, WCL', kind: 'Permission', age: '58 d', ageTone: 'critical', standard: '30 d', heldBy: 'Zone, referred', action: 'Follow up', actionTone: 'neutral' },
    { id: 'ap4', application: 'Exemption, weekly rest day roster', mineOperator: 'Beed manganese 2', kind: 'Exemption', age: '52 d', ageTone: 'critical', standard: '30 d', heldBy: 'This office', action: 'Dispose', actionTone: 'critical' },
    { id: 'ap5', application: 'Approval of a flameproof starter', mineOperator: 'Chandrapur UG-1, Vidarbha Coal', kind: 'Approval', age: '41 d', ageTone: 'warning', standard: '60 d', heldBy: 'Applicant, papers awaited', action: 'Remind', actionTone: 'neutral' },
    { id: 'ap6', application: 'Depillaring in district 3', mineOperator: 'Ballarpur UG-1, WCL', kind: 'Permission', age: '34 d', ageTone: 'warning', standard: '45 d', heldBy: 'This office', action: 'Open', actionTone: 'neutral' },
    { id: 'ap7', application: 'Extension of the haulage roadway', mineOperator: 'Chandrapur UG-1, Vidarbha Coal', kind: 'Permission', age: '28 d', ageTone: 'warning', standard: '45 d', heldBy: 'This office', action: 'Open', actionTone: 'neutral' },
    { id: 'ap8', application: 'Relaxation, distance from the village boundary', mineOperator: 'Wani OCP-2, WCL', kind: 'Relaxation', age: '19 d', ageTone: null, standard: '45 d', heldBy: 'Applicant, papers awaited', action: 'Remind', actionTone: 'neutral' }
  ],

  applicationsFootnote: "Four of the nine beyond standard concern one underground mine. Clearing that mine's file would halve the overdue count and remove a standing complaint from the operator.",

  byKind: [
    { kind: 'Permission', count: 14, color: 'critical', maxCount: 14 },
    { kind: 'Approval', count: 9, color: 'info', maxCount: 14 },
    { kind: 'Relaxation', count: 7, color: 'critical', maxCount: 14 },
    { kind: 'Exemption', count: 4, color: 'info', maxCount: 14 }
  ],
  byKindFootnote: 'Permissions for underground working take longest because they usually need a site visit. Pairing them with the inspection plan would cut the median by about two weeks.',
  byKindCta: 'Pair with October plan',

  applicantView: {
    title: "Applicant's view",
    subtitle: 'What the operator sees',
    description: "Each applicant sees the stage their own file has reached and who holds it, and nothing about any other applicant. Publishing the queue position is what removes the follow-up telephone calls.",
    items: [
      { id: 'av1', title: 'Working below a water body', filed: 'Filed 1 Jul', stage: 'Stage 3 of 4', stageLabel: 'With the Director', stageTone: 'warning' },
      { id: 'av2', title: 'Depillaring, district 3', filed: 'Filed 7 Aug', stage: 'Stage 2 of 4', stageLabel: 'Under scrutiny', stageTone: null },
      { id: 'av3', title: 'Flameproof starter', filed: 'Filed 31 Jul', stage: 'Stage 1 of 4', stageLabel: 'Papers awaited', stageTone: 'critical' }
    ]
  },

  pageFootnote: 'Demo data. Jurisdiction and statutory framework are real; mines, operators and figures are illustrative.'
};

router.get('/permissions', (req, res) => {
  res.json(permissionsData);
});

const assuranceData = {
  header: {
    title: 'Assurance and reporting',
    description: "Where each figure came from, which mines are not reporting, whether any sealed record has been altered, and what this office sends up to Zone and headquarters."
  },

  provenance: {
    title: 'Provenance of everything this office sees',
    subtitle: 'September 2026',
    segments: [
      { label: 'Seen by an inspector', value: 31, color: '#1e293b' },
      { label: 'Instrument reading', value: 24, color: '#6b7280' },
      { label: 'Operator, hash sealed', value: 38, color: '#d97706' },
      { label: 'Operator, unsealed', value: 7, color: '#dc2626' }
    ],
    records: [
      { id: 'pr1', kind: 'Inspection findings', thisMonth: '187', establishedBy: 'Inspector on site', establishedTone: 'info', canBeChecked: "Yes, officer's own entry" },
      { id: 'pr2', kind: 'Ambient and gas readings', thisMonth: '1,244', establishedBy: 'Instrument feed', establishedTone: 'info', canBeChecked: 'Yes, device signed' },
      { id: 'pr3', kind: 'Accident notifications', thisMonth: '6', establishedBy: 'Operator, sealed', establishedTone: 'warning', canBeChecked: 'Yes, hash on ledger' },
      { id: 'pr4', kind: 'Monthly returns, platform operators', thisMonth: '96', establishedBy: 'Operator, sealed', establishedTone: 'warning', canBeChecked: 'Yes, hash on ledger' },
      { id: 'pr5', kind: 'Returns filed on paper or by email', thisMonth: '22', establishedBy: 'Operator, unsealed', establishedTone: 'critical', canBeChecked: 'No', canBeCheckedTone: 'critical' },
      { id: 'pr6', kind: 'Compliance photographs, no location', thisMonth: '14', establishedBy: 'Operator, unsealed', establishedTone: 'critical', canBeChecked: 'No', canBeCheckedTone: 'critical' }
    ],
    footnote: "The 7% that cannot be checked is not spread evenly. It is concentrated in minor mineral mines, which are also the least inspected. Weak evidence and weak coverage sit on the same mines."
  },

  notReporting: {
    title: 'Not reporting',
    subtitle: 'Silence is a finding',
    items: [
      { id: 'nr1', mine: 'Nanded quarry 7', operator: 'Private', missing: 'Monthly return', times: 5 },
      { id: 'nr2', mine: 'Osmanabad quarry 9', operator: 'Private', missing: 'Monthly return, employment', times: 4 },
      { id: 'nr3', mine: 'Latur 3', operator: 'Godavari Limestone', missing: 'Employment return', times: 3 },
      { id: 'nr4', mine: 'Chandrapur UG-1', operator: 'Vidarbha Coal', missing: 'Gas analysis record', times: 2 },
      { id: 'nr5', mine: 'Beed quarry 2', operator: 'Private', missing: 'Monthly return', times: 1 }
    ],
    footnote: 'Three of these five have never been inspected. Non-reporting raises the targeting score directly.'
  },

  integrityCheck: {
    title: 'Integrity check',
    subtitle: 'Sealed records compared with the ledger',
    items: [
      { id: 'ic1', record: 'Accident notice, 9 Sep', operator: 'WCL', sealed: '10 Sep 08:40', result: 'Intact', resultTone: 'good' },
      { id: 'ic2', record: 'Monthly return, August', operator: 'WCL', sealed: '3 Sep 11:20', result: 'Intact', resultTone: 'good' },
      { id: 'ic3', record: 'Compliance evidence, berms', operator: 'WCL', sealed: '18 Aug 16:02', result: 'Intact', resultTone: 'good' },
      { id: 'ic4', record: 'Contract labour return, Q1', operator: 'WCL', sealed: '28 Jul 10:31', result: 'Changed after sealing', resultTone: 'critical' },
      { id: 'ic5', record: 'Gas analysis record, Aug', operator: 'Vidarbha Coal', sealed: '2 Sep 09:14', result: 'Intact', resultTone: 'good' }
    ],
    footnote: "A mismatch does not prove wrongdoing. It shows the file differs from what was submitted, and gives this office a precise question to ask rather than a suspicion."
  },

  whatOfficeReceives: {
    title: 'What this office receives, and what it does not',
    subtitle: 'Published to every connected operator',
    description: "The duty to provide for and ensure safety rests with mine management. This office oversees the statute. The feed is therefore limited to what the law already requires to be submitted, plus this office's own records. No live operational data is received.",
    categories: [
      { id: 'wr1', category: 'Accident and dangerous occurrence notices', received: 'In full', receivedTone: null, when: 'As reported, immediately' },
      { id: 'wr2', category: 'Statutory returns and registers', received: 'In full', receivedTone: null, when: 'On the due date' },
      { id: 'wr3', category: 'Compliance evidence against directions', received: 'In full', receivedTone: null, when: 'When submitted' },
      { id: 'wr4', category: 'Permission and approval applications', received: 'In full', receivedTone: null, when: 'When filed' },
      { id: 'wr5', category: 'Environmental instrument readings', received: 'In full', receivedTone: null, when: 'Daily summary' },
      { id: 'wr6', category: 'Internal safety observations and CAPAs', received: 'Counts only, by category', receivedTone: 'warning', when: 'Monthly, aggregated' },
      { id: 'wr7', category: 'Internal risk scores', received: 'Not received', receivedTone: 'critical', when: '—' },
      { id: 'wr8', category: 'Live production, dispatch and attendance', received: 'Not received', receivedTone: 'critical', when: '—' },
      { id: 'wr9', category: 'Draft inquiry material and internal correspondence', received: 'Not received', receivedTone: 'critical', when: '—' },
      { id: 'wr10', category: 'Named worker records', received: 'Not received', receivedTone: 'critical', when: 'Aggregate counts only' }
    ],
    footnote: "Every operator can see this table and its own outbound feed. Publishing the boundary is what makes connection acceptable to the party being regulated."
  },

  returnsFromOffice: {
    title: 'Returns from this office',
    subtitle: 'Upward reporting, built from the same records',
    items: [
      { id: 'ro1', title: 'Monthly statistical return to Western Zone', description: 'Inspections by discipline, findings by nature of defect, accidents.', dueIn: '3 days', dueBy: 'by 13 Sep', action: 'Build', actionTone: 'primary', dot: 'critical' },
      { id: 'ro2', title: 'Accident data to the national portal', description: 'Accident module. Pre-filled from the six notices received this year.', dueIn: '5 days', dueBy: 'by 15 Sep', action: 'Build', actionTone: 'primary', dot: 'critical' },
      { id: 'ro3', title: 'Reply to a Parliament question on mine safety', description: 'Fatal accidents in the region, last three years, by operator.', dueIn: '9 days', dueBy: 'by 19 Sep', action: 'Draft', actionTone: 'neutral', dot: null },
      { id: 'ro4', title: 'Information under the Right to Information Act', description: 'Prohibition orders issued in the region since 2024.', dueIn: '14 days', dueBy: 'by 24 Sep', action: 'Draft', actionTone: 'neutral', dot: null }
    ],
    footnote: 'Each return is assembled from records already held, so the figures sent upward match the figures on these screens by construction.'
  },

  pageFootnote: 'Demo data. The zone, region, district jurisdiction and the statutory framework are real. Mine names, operators other than WCL, officers and all readings are illustrative.'
};

router.get('/assurance', (req, res) => {
  res.json(assuranceData);
});

export default router;
