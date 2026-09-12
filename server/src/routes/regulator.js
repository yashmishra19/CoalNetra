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

export default router;
