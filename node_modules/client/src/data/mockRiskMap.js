/**
 * Mock data for Risk Map page
 */

export const mockRiskMapData = {
  header: {
    title: 'Mine Risk Map & Spatial Telemetry',
    subtitle: 'Real-time composite hazard weighting, slope radar, gas sensors, and high-risk section ranking.',
  },

  mapViewTabs: [
    { key: 'risk', label: 'Risk zones', count: 8 },
    { key: 'observations', label: 'Open observations', count: 14 },
    { key: 'satellite', label: 'Satellite change', count: 2 },
  ],

  rankedSections: [
    {
      id: 'sec-dump3',
      score: 81,
      title: 'Dump-3 (Overburden)',
      description: 'Slope moving 4.2 mm/day after 118 mm rain',
    },
    {
      id: 'sec-hrn',
      score: 74,
      title: 'Haul Road North',
      description: 'Accident yesterday, berm CAPA-231 open',
    },
    {
      id: 'sec-bench4',
      score: 66,
      title: 'Bench 4, coal face',
      description: 'Not inspected yet this shift',
    },
    {
      id: 'sec-sonari',
      score: 58,
      title: 'Sonari village boundary',
      description: 'AD-2 PM10 particulate reading at 112 µg/m³',
    },
    {
      id: 'sec-chp',
      score: 52,
      title: 'CHP and railway siding',
      description: 'Rail dispatch 81%, water mist cannons active',
    },
    {
      id: 'sec-hrs',
      score: 43,
      title: 'Haul Road South',
      description: '3 water tankers deployed, dust controlled',
    },
    {
      id: 'sec-mag',
      score: 31,
      title: 'Explosives magazine',
      description: 'Daily log verified, PESO compliant',
    },
    {
      id: 'sec-ws',
      score: 24,
      title: 'Workshop & Substation',
      description: 'HEMM fitness certificates 100% up to date',
    },
  ],

  dumpScoreBreakdown: {
    sectionName: 'Dump-3',
    score: 81,
    baseline: 48,
    subtitle: 'Starting baseline score for active overburden dumps is 48',
    factors: [
      { label: 'Radar slope displacement rate (+4.2 mm/day)', delta: 14 },
      { label: 'Cumulative rainfall in last 72h (118 mm)', delta: 11 },
      { label: 'Overdue drainage maintenance CAPA-198', delta: 9 },
      { label: 'Heavy vehicle dumping traffic (34 dumpers/hr)', delta: 4 },
      { label: 'Piezometer pore pressure normal (Level 12m)', delta: -3 },
      { label: 'Active water pumping at toe (2 pumps on)', delta: -2 },
    ],
  },

  hazardTypeBreakdown: {
    subtitle: 'Whole mine composite weighting, today',
    items: [
      { label: 'Vehicles and haul roads', score: 78, color: 'critical' },
      { label: 'Slope and dump stability', score: 74, color: 'critical' },
      { label: 'Dust and air quality', score: 58, color: 'warning' },
      { label: 'Inundation / monsoon', score: 44, color: 'warning' },
      { label: 'Fire and heating of coal', score: 39, color: 'good' },
      { label: 'Blasting and fly rock', score: 35, color: 'good' },
      { label: 'Electrical switchgear', score: 22, color: 'good' },
    ],
    note: 'Monsoon weighting is currently active (+15% to slope and inundation models until 15 Oct).',
  },

  riskInsights: [
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
};
