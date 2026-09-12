import { Router } from 'express';

const router = Router();

const mockTodayData = {
  header: {
    title: 'Today at Demo OCP-1',
    subtitle: 'Everything that needs your decision this shift, soonest deadline first.',
  },
  alertBanner: {
    id: 'alert-dgms-notice',
    title: 'Serious accident notice is due to DGMS',
    description: 'Dumper operator injured on Haul Road North, 9 Sep at 22:02. Regional Inspector informed by phone at 23:31. The written notice draft is ready for your signature.',
    deadlineRemaining: '05:17:17',
    totalWindow: '24 hours',
    ctaText: 'Review and sign notice',
  },
  kpiStats: [
    {
      id: 'mine-risk-score',
      title: 'Mine risk score',
      value: '68',
      trend: { direction: 'up', value: '5', color: 'critical' },
      subtext: 'Rising. Main driver: Dump-3 slope movement',
      accentColor: 'critical',
    },
    {
      id: 'compliance',
      title: 'Compliance',
      value: '86%',
      trend: { direction: 'down', value: '2', color: 'warning' },
      subtext: 'Target 95%. 8 items due this week',
      accentColor: 'warning',
    },
    {
      id: 'overdue-items',
      title: 'Overdue items',
      value: '14',
      subtext: '9 compliance, 5 CAPA. 3 are over 7 days late',
      accentColor: 'critical',
    },
    {
      id: 'critical-high-capas',
      title: 'Critical and high CAPAs',
      value: '3',
      subtext: '1 escalated to you today',
      accentColor: 'warning',
    },
    {
      id: 'on-duty',
      title: 'On duty, Shift B',
      value: '812',
      secondaryValue: '/ 880',
      subtext: '9 stopped at gate: training or medical expired',
      accentColor: 'neutral',
    },
    {
      id: 'coal-today',
      title: 'Coal today',
      value: '19.1',
      secondaryValue: 'kt',
      subtext: '91% of pace for 45,000 t. Dispatch matched',
      accentColor: 'good',
    },
  ],
  decisions: {
    count: 6,
    items: [
      {
        id: 'dec-1',
        status: 'critical',
        title: 'Verify closure of CAPA-231: low berm on Haul Road North',
        description: 'Closed by A. Kujur with after-photos. You or another official must verify on-site.',
        timeInfo: { primary: '3 h', secondary: 'in 18:20', variant: 'warning' },
        actions: [{ label: 'Verify', variant: 'dark-blue' }, { label: 'Reopen', variant: 'secondary' }],
      },
      {
        id: 'dec-2',
        status: 'critical',
        title: 'Escalated to you: CAPA-198: drainage at Dump-3 toe',
        description: 'Owner S. Tirkey missed the deadline. Dump-3 slope radar is on alert.',
        timeInfo: { primary: '1 day', secondary: 'overdue', variant: 'critical' },
        actions: [{ label: 'Reassign', variant: 'dark-blue' }, { label: 'Open', variant: 'secondary' }],
      },
      {
        id: 'dec-3',
        status: 'warning',
        title: 'Approve hot-work permit: boom welding on Shovel-7, Bench 4',
        description: 'Requested by P. Munda, Mechanical Foreman. Fire watch and extinguisher listed.',
        timeInfo: { primary: '4 h', secondary: 'work starts 20:30', variant: 'warning' },
        actions: [{ label: 'Approve', variant: 'dark-blue' }, { label: 'Return', variant: 'secondary' }],
      },
      {
        id: 'dec-4',
        status: 'warning',
        title: 'Approve action plan for dust exceedance at AD-2: Sonari village',
        description: 'Plan adds 3 water tankers on Haul Road South and moves blasting to 13:00.',
        timeInfo: { primary: '1 day', secondary: 'by 17:00', variant: 'neutral' },
        actions: [{ label: 'Approve', variant: 'dark-blue' }, { label: 'Open', variant: 'secondary' }],
      },
      {
        id: 'dec-5',
        status: 'neutral',
        title: 'Sign monthly production return for August',
        description: 'Generated from weighbridge and survey data. No gaps found.',
        timeInfo: { primary: '2 days', secondary: 'by 15 Sep', variant: 'neutral' },
        actions: [{ label: 'Review', variant: 'secondary' }],
      },
      {
        id: 'dec-6',
        status: 'neutral',
        title: 'Review contractor appeal: 4 blocked workers, Bharat Earthworks',
        description: 'Contractor says refresher training was done on 8 Sep. Certificates uploaded.',
        timeInfo: { primary: 'Today', secondary: 'by 22:00', variant: 'neutral' },
        actions: [{ label: 'Review', variant: 'secondary' }],
      },
    ],
    footerNote: '5 more items are in Reports & approvals',
  },
  riskHighest: {
    lastUpdated: '16:00',
    rankedItems: [
      { rank: 1, score: 81, badgeVariant: 'critical', name: 'Dump-3', detail: 'Slope moving 4.2 mm/day after 118 mm rain' },
      { rank: 2, score: 74, badgeVariant: 'critical', name: 'Haul Road North', detail: 'Accident yesterday, berm CAPA open' },
      { rank: 3, score: 66, badgeVariant: 'warning', name: 'Bench 4, coal face', detail: 'Not inspected yet this shift' },
    ],
  },
  deadlines: {
    hours24: {
      title: 'Next 24 hours',
      count: 3,
      items: [
        { title: 'Serious accident notice to DGMS', due: '22:02 today', isCritical: true },
        { title: 'Verify CAPA-231', due: '18:20 today', isCritical: false },
        { title: 'Hot-work permit decision', due: '20:30 today', isCritical: false },
      ],
    },
    days7: {
      title: 'Next 7 days',
      count: 8,
      items: [
        { title: 'August production return', due: '13 Sep' },
        { title: 'DGMS direction: berms on Haul Road North', due: '13 Sep' },
        { title: 'Haul road audit, all roads', due: '14 Sep' },
        { title: 'Wage records from 3 contractors', due: '15 Sep' },
      ],
    },
    days90: {
      title: 'Next 90 days',
      count: 11,
      items: [
        { title: 'Post-monsoon dump and slope inspection', due: 'from 1 Oct' },
        { title: 'Contract labour licence, Kalpana Logistics', due: '20 Oct' },
        { title: 'Consent to Operate renewal', due: '10 Nov' },
        { title: 'EC half-yearly compliance report', due: '1 Dec' },
      ],
    },
  },
  inspections: {
    shift: 'Shift B',
    doneCount: 14,
    totalCount: 18,
    remainingItems: [
      { name: 'Bench 4, coal face', due: '18:00', status: 'warning' },
      { name: 'Dump-2 toe', due: '19:00', status: 'warning' },
      { name: 'Explosives magazine', due: '20:00', status: 'neutral' },
      { name: 'Sump-1 pump house', due: '21:00', status: 'neutral' },
    ],
    footerNote: '12 check-ins verified by GPS inside the lease; 2 by QR tag.',
  },
  insights: [
    {
      id: 'insight-1',
      category: 'Repeating problem',
      status: 'critical',
      title: 'Low berms reported 11 times across 4 mines in 45 days',
      description: 'Same root cause in Sonpur Area. Suggests a common haul road standard is not being followed.',
    },
    {
      id: 'insight-2',
      category: 'Likely to be late',
      status: 'warning',
      title: 'CAPA-198 has an 82% chance of missing its new deadline',
      description: 'Owner has 6 other open CAPAs. Similar drainage jobs took 9 days on average.',
    },
    {
      id: 'insight-3',
      category: 'Unusual pattern',
      status: 'warning',
      title: '37 attendance punches at Gate 2 within 4 minutes',
      description: 'Recorded at 13:58 by one face scanner. Possible proxy attendance; needs a check.',
    },
  ],
  liveReadings: [
    { id: 'dust-aq2', label: 'Dust, AQ-2 Sonari', value: '112 µg/m³ PM10', note: 'limit 100', status: 'critical' },
    { id: 'dust-suppression', label: 'Dust suppression', value: '6 of 8', note: 'sprinklers running', status: 'warning' },
    { id: 'dump3-radar', label: 'Dump-3 slope radar', value: '4.2 mm/day', note: 'alert at 5', status: 'warning' },
    { id: 'sump-water', label: 'Sump-1 water level', value: '62%', note: '2 of 3 pumps on', status: 'good' },
    { id: 'haul-traffic', label: 'Haul road traffic', value: '34 dumpers', note: '2 over speed in last hour', status: 'warning' },
  ],
  fieldFeed: [
    { id: 'feed-1', time: '16:12', author: 'B. Oraon', action: 'logged a safety observation: loose material on Bench 3 edge.', detail: 'Classified as ground control, medium. CAPA-240 created.', tag: 'GPS verified', tagVariant: 'gps-verified' },
    { id: 'feed-2', time: '15:58', author: 'M. Hansda', action: 'recorded PM10 reading at AQ-2 by voice note in Hindi.', detail: 'Transcribed and matched to sensor value.', tag: 'GPS verified', tagVariant: 'gps-verified' },
    { id: 'feed-3', time: '15:41', author: 'A. Kujur', action: 'uploaded after-photos for CAPA-231.', detail: 'Photo hash recorded at capture.', tag: 'GPS verified', tagVariant: 'gps-verified' },
    { id: 'feed-4', time: '15:20', author: 'S. Ekka', action: 'inspected Sump-1 electrical panel.', detail: 'All 14 checklist items OK.', tag: 'QR tag', tagVariant: 'qr-tag' },
    { id: 'feed-5', time: '14:43', author: 'R. Singh', action: 'tried to submit an inspection from outside the lease.', detail: 'Location 1.3 km from boundary. Held for review.', tag: 'Location flagged', tagVariant: 'location-flagged' },
  ],
  footerDisclaimer: 'Demo data for Demo OCP-1, a fictitious mine. Names, readings and dates are illustrative.',
};

router.get('/', (req, res) => {
  res.json(mockTodayData);
});

export default router;
