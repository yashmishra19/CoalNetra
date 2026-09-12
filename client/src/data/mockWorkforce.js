export const mockWorkforceData = {
  header: {
    title: 'Workforce & Contractor Safety',
    subtitle: 'Statutory vocational training (VTC), Initial/Periodic Medical Exams (IME/PME), and contractor deployment.',
    syncStatus: 'Contract worker records synced from CIL ICIS at 16:05',
  },
  statCards: [
    { id: 'on-duty-shift', title: 'On duty, Shift B', value: '812', secondaryValue: 'of 860 planned', status: 'good', subtext: '94.4% deployment rate across sections' },
    { id: 'people-on-roll', title: 'People on roll', value: '2,610', status: 'neutral', subtext: '1,120 departmental, 1,490 contractor' },
    { id: 'stopped-at-gate', title: 'Stopped at gate today', value: '9', status: 'critical', subtext: 'Training or medical expired' },
    { id: 'expiring-soon', title: 'Expiring in 30 days', value: '41', status: 'warning', subtext: '28 PME medicals, 13 VTC refresher' },
    { id: 'open-grievances', title: 'Open grievances', value: '14', status: 'warning', subtext: '2 due today under Code on Wages' },
  ],
  stoppedAtGate: {
    subtitle: 'Gate pass blocked automatically',
    workers: [
      { id: 'w-1', name: 'S. Mahato', role: 'Dumper Operator', employer: 'Bharat Earthworks', reason: 'PME Medical Expired', since: '10 Sep 2026', actionType: 'book-exam', actionLabel: 'Book exam' },
      { id: 'w-2', name: 'R. Paswan', role: 'Blaster Helper', employer: 'Bharat Earthworks', reason: 'VTC Refresher Expired', since: '08 Sep 2026', actionType: 'appeal-filed', actionLabel: 'Appeal filed' },
      { id: 'w-3', name: 'K. Murmu', role: 'Drill Operator', employer: 'Maa Tarini Mining', reason: 'Form O Medical Missing', since: '12 Sep 2026', actionType: 'ask-contractor', actionLabel: 'Ask contractor' },
      { id: 'w-4', name: 'V. Oraon', role: 'Trip Man', employer: 'Bharat Earthworks', reason: 'Safety Induction Overdue', since: '11 Sep 2026', actionType: 'ask-contractor', actionLabel: 'Ask contractor' },
    ],
    footerNote: '3 more workers are blocked across Shift A and C.',
  },
  attendanceByShift: {
    shifts: [
      { name: 'Shift A (06:00 - 14:00)', count: 840, target: 860, percentage: 97.6, color: 'good' },
      { name: 'Shift B (14:00 - 22:00)', count: 812, target: 860, percentage: 94.4, color: 'good' },
      { name: 'Shift C (22:00 - 06:00)', count: 620, target: 680, percentage: 91.1, color: 'warning' },
    ],
    breakdownText: 'Face scan 71%, fingerprint 26%, manual with reason 3%',
    callout: 'Shift B face scanner at Gate 2 logged 37 punches in 4 minutes (13:58). Potential proxy check flagged.',
  },
  contractorScorecard: [
    { id: 'c-1', contractor: 'Bharat Earthworks Pvt Ltd', work: 'OB Removal & Haulage', workers: 620, score: '72', incidents: 1, capaClosedOnTime: 68, wageCheck: 'Under review', grievances: 4 },
    { id: 'c-2', contractor: 'Maa Tarini Mining Services', work: 'Coal Transportation', workers: 340, score: '88', incidents: 0, capaClosedOnTime: 92, wageCheck: 'Compliant', grievances: 1 },
    { id: 'c-3', contractor: 'Kalpana Logistics & Heavy Lift', work: 'Crusher & Feeder Breaker', workers: 280, score: '94', incidents: 0, capaClosedOnTime: 98, wageCheck: 'Compliant', grievances: 0 },
    { id: 'c-4', contractor: 'Eastern Drillers & Blasters', work: 'Drilling & Secondary Blasting', workers: 150, score: '84', incidents: 0, capaClosedOnTime: 82, wageCheck: 'Compliant', grievances: 2 },
    { id: 'c-5', contractor: 'Sonpur Security & Allied', work: 'Perimeter & Gate Security', workers: 100, score: '91', incidents: 0, capaClosedOnTime: 95, wageCheck: 'Compliant', grievances: 0 },
  ],
  wageChecks: [
    { id: 'wc-1', status: 'warning', title: 'Bharat Earthworks: 4 workers disputed overtime payment', description: 'Form B wage register submitted with deductions. Awaiting contractor clarification.', timeInfo: { primary: 'Due 15 Sep', secondary: 'by 18:00', variant: 'warning' }, actions: [{ label: 'Send notice', variant: 'dark-blue' }] },
    { id: 'wc-2', status: 'good', title: 'Maa Tarini: August bank credit advice uploaded', description: '100% electronic bank transfer confirmed for 340 workers. Match with muster roll OK.', timeInfo: { primary: 'Verified', secondary: '10 Sep', variant: 'neutral' }, actions: [] },
    { id: 'wc-3', status: 'good', title: 'Kalpana Logistics: PF / ESI challans verified', description: 'Statutory compliance score 98%. No shortfall reported.', timeInfo: { primary: 'Verified', secondary: '09 Sep', variant: 'neutral' }, actions: [] },
    { id: 'wc-4', status: 'warning', title: 'Eastern Drillers: Awaiting Form B wage register upload', description: 'Contractor overdue by 2 days for August wage submission.', timeInfo: { primary: 'Due 14 Sep', secondary: 'overdue 2d', variant: 'critical' }, actions: [{ label: 'Remind', variant: 'secondary' }] },
  ],
  workerGrievances: [
    { id: 'g-1', issue: 'Overtime deduction on 28 Aug shift', location: 'Haul Road Night Shift', language: 'Hindi (Voice note)', due: 'Today 17:00', status: 'With Safety Officer' },
    { id: 'g-2', issue: 'Drinking water dispenser non-functional at Bench 4', location: 'Bench 4 Coal Face', language: 'Hindi (Text)', due: '13 Sep 12:00', status: 'In progress' },
    { id: 'g-3', issue: 'Dust mask shortage in CHP area', location: 'Coal Handling Plant', language: 'Santhali (Voice note)', due: '14 Sep 18:00', status: 'Worker Informed' },
    { id: 'g-4', issue: 'Rest shelter roof leak near Sump-1', location: 'Sump-1 Pump Station', language: 'Hindi (Text)', due: '15 Sep 14:00', status: 'Assigned' },
  ],
};
