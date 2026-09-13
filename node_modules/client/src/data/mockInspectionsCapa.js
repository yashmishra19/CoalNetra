export const mockInspectionsCapaData = {
  header: {
    title: 'Inspections & Corrective Actions (CAPA)',
    subtitle: 'Statutory shift inspections under CMR Reg 37, hazard tracking, and closing audit verification.',
  },
  pipelineSteps: [
    { label: 'Reported', count: 38, description: 'Open hazards flagged' },
    { label: 'Assigned', count: 24, description: 'Assigned to section leads' },
    { label: 'Work done', count: 12, description: 'Awaiting site verification' },
    { label: 'Verified', count: 8, description: 'Audited & signed off' },
  ],
  capaFilters: [
    { key: 'all', label: 'All open', count: 24 },
    { key: 'overdue', label: 'Overdue', count: 5 },
    { key: 'escalated', label: 'Escalated to me', count: 2 },
    { key: 'contractor', label: 'Contractor areas', count: 7 },
  ],
  capaList: [
    { id: 'CAPA-231', title: 'Low berm along Haul Road North', location: 'Haul Road North chainage 1.2km', severity: 'Critical', ownerName: 'A. Kujur', ownerRole: 'Safety Officer', due: 'Today 18:20', dueLevel: 'Immediate (24h)', status: 'To verify', isContractor: true, isEscalated: false, isOverdue: false },
    { id: 'CAPA-198', title: 'Inadequate drainage channel at Dump-3 toe', location: 'Dump-3 Toe West', severity: 'Critical', ownerName: 'S. Tirkey', ownerRole: 'Geotech Incharge', due: 'Overdue 1 day', dueLevel: 'Escalated to Manager', status: 'Escalated to me', isContractor: false, isEscalated: true, isOverdue: true },
    { id: 'CAPA-240', title: 'Loose overhang material on Bench 3 edge', location: 'Pit-1 Bench 3 Coal', severity: 'High', ownerName: 'B. Oraon', ownerRole: 'Overman Shift B', due: '13 Sep 14:00', dueLevel: '24 hours remaining', status: 'In progress', isContractor: false, isEscalated: false, isOverdue: false },
    { id: 'CAPA-228', title: 'Dust extraction ducting disconnected at Crusher-2', location: 'CHP Crusher House', severity: 'Medium', ownerName: 'P. Munda', ownerRole: 'Mechanical Foreman', due: '14 Sep 20:00', dueLevel: '48 hours remaining', status: 'Assigned', isContractor: true, isEscalated: false, isOverdue: false },
    { id: 'CAPA-215', title: 'Fire extinguisher inspection expired on Shovel-4', location: 'Bench 2 Face', severity: 'High', ownerName: 'R. Gope', ownerRole: 'Shovel Operator', due: '13 Sep 10:00', dueLevel: 'High priority', status: 'In progress', isContractor: false, isEscalated: false, isOverdue: false },
    { id: 'CAPA-204', title: 'Broken ladder rung on Sump-1 pump pontoon', location: 'Sump-1 Main Pontoon', severity: 'Low', ownerName: 'S. Ekka', ownerRole: 'Electrical Supervisor', due: '16 Sep 18:00', dueLevel: 'Normal priority', status: 'Assigned', isContractor: true, isEscalated: false, isOverdue: false },
  ],
  selectedCapaDetail: {
    id: 'CAPA-231',
    title: 'CAPA-231: Low berm along Haul Road North',
    subtitle: 'Haul Road North chainage 1.2km · Created 9 Sep 22:15',
    severity: 'Critical',
    description: 'Berm height measured at 0.8m following heavy rainfall and dumper incident. Minimum statutory requirement under CMR Reg 76 is 1.5m (equal to tyre radius of largest vehicle).',
    beforeAfter: {
      before: { title: 'Before: Low berm', caption: 'Berm height 0.8m (min required 1.5m)', timestamp: '9 Sep 22:15' },
      after: { title: 'After: Berm built to 1.6m', caption: 'Verified with laser level & GPS hash', timestamp: '11 Sep 14:30' },
    },
    history: [
      { timestamp: '9 Sep 22:15', description: 'Hazard reported after dumper incident', author: 'Safety Officer A. Kujur', status: 'done' },
      { timestamp: '10 Sep 08:00', description: 'Assigned to contractor Bharat Earthworks', author: 'Planning Office', status: 'done' },
      { timestamp: '11 Sep 14:30', description: 'Work completed. After-photos & GPS hash uploaded', author: 'A. Kujur', status: 'done' },
      { timestamp: '12 Sep 16:00', description: 'On-site verification pending by Mine Manager', author: 'R. K. Mehato', status: 'current' },
    ],
    callout: {
      title: 'Verification Requirement',
      message: 'A. Kujur closed the repair work, so a different official (Mine Manager / Safety Incharge) must verify on-site before sign-off.',
    },
    footerNote: '6 events in the immutable audit trail.',
    footerBadge: 'Record intact',
  },
  todayInspectionPlan: [
    { time: '14:30', section: 'Haul Road North', type: 'Berm & Road Audit', inspector: 'A. Kujur', status: 'Done, GPS' },
    { time: '15:20', section: 'Sump-1 Electrical Panel', type: 'Switchgear Checklist', inspector: 'S. Ekka', status: 'Done, QR tag' },
    { time: '16:10', section: 'Pit-1 Bench 3 Coal Face', type: 'Face Inspection', inspector: 'B. Oraon', status: 'Done, GPS' },
    { time: '18:00', section: 'Bench 4 Coal Face', type: 'Face Inspection', inspector: 'M. Hansda', status: 'Pending' },
    { time: '19:00', section: 'Dump-2 Toe', type: 'Slope & Drainage Check', inspector: 'S. Tirkey', status: 'Pending' },
    { time: '20:00', section: 'Explosives Magazine #1', type: 'Magazine Security', inspector: 'D. Soren', status: 'Scheduled' },
  ],
  shiftsInspectedHeatmap: {
    days: ['6 Sep', '7 Sep', '8 Sep', '9 Sep', '10 Sep', '11 Sep', '12 Sep', 'Today'],
    rows: [
      { name: 'Haul Road North', counts: [3, 3, 3, 2, 3, 3, 3, 2] },
      { name: 'Pit-1 Bench 4 Face', counts: [3, 3, 2, 3, 3, 2, 3, 1] },
      { name: 'Dump-3 Slope', counts: [3, 3, 3, 3, 3, 3, 3, 2] },
      { name: 'Sump-1 Pump Station', counts: [3, 3, 3, 3, 3, 3, 3, 2] },
      { name: 'Explosives Magazine', counts: [3, 3, 3, 3, 3, 3, 3, 1] },
    ],
    note: 'All 5 critical risk sections achieved ≥ 95% inspection coverage over the last 7 days.',
  },
};
