/**
 * Mock data for Production & Environment page
 */

export const mockProductionEnvironmentData = {
  header: {
    title: 'Production & Environment',
    subtitle: 'Coal extraction, overburden removal, dispatch reconciliation, and statutory environmental monitoring.',
  },

  kpiStats: [
    {
      id: 'coal-today',
      title: 'Coal today',
      value: '19.1',
      secondaryValue: 'kt',
      subtext: '97% of pace for 45,000 t target',
      status: 'good',
      accentColor: 'good',
    },
    {
      id: 'coal-month',
      title: 'Coal this month',
      value: '437',
      secondaryValue: 'kt',
      subtext: '97% of 450k target. 18 days left in cycle',
      status: 'good',
      accentColor: 'good',
    },
    {
      id: 'ob-month',
      title: 'Overburden this month',
      value: '2.31M',
      secondaryValue: 'm³',
      subtext: 'Stripping ratio 5.3 vs plan 5.6',
      status: 'critical',
      accentColor: 'critical',
    },
    {
      id: 'dispatched-month',
      title: 'Dispatched this month',
      value: '429',
      secondaryValue: 'kt',
      subtext: 'Rail dispatch 81%, road haulage 19%',
      status: 'info',
      accentColor: 'info',
    },
    {
      id: 'coal-stock',
      title: 'Coal stock',
      value: '163',
      secondaryValue: 'kt',
      subtext: 'Oldest heap 38 days. Spontaneous heating watch',
      status: 'warning',
      accentColor: 'warning',
    },
    {
      id: 'aq-stations',
      title: 'Air quality stations over limit',
      value: '1 of 4',
      subtext: 'AQ-2 Sonari village PM10 at 112 µg/m³',
      status: 'critical',
      accentColor: 'critical',
    },
  ],

  dailyProduction: {
    target: 45,
    threshold: 42,
    chartData: [
      { date: '30 Aug', tonnes: 46 },
      { date: '31 Aug', tonnes: 48 },
      { date: '1 Sep', tonnes: 44 },
      { date: '2 Sep', tonnes: 47 },
      { date: '3 Sep', tonnes: 45 },
      { date: '4 Sep', tonnes: 49 },
      { date: '5 Sep', tonnes: 46 },
      { date: '6 Sep', tonnes: 43 },
      { date: '7 Sep', tonnes: 47 },
      { date: '8 Sep', tonnes: 38 },
      { date: '9 Sep', tonnes: 29 },
      { date: '10 Sep', tonnes: 44 },
      { date: '11 Sep', tonnes: 46 },
      { date: 'Today', tonnes: 19.1, isToday: true },
    ],
    note: '8–9 Sep dip was caused by 118 mm rainfall and a 6-hour power outage at Substation 3.',
  },

  dispatchReconciliation: {
    subtitle: '1 Aug 2026 – 12 Sep 2026 (Stock reconciliation)',
    items: [
      { label: 'Opening stock (1 Aug)', value: '154,300 t', type: 'base' },
      { label: 'Coal produced', value: '417,900 t', type: 'add' },
      { label: 'Coal dispatched', value: '408,600 t', type: 'subtract' },
      { isDivider: true },
      { label: 'Stock as per books', value: '163,600 t', type: 'subtotal', isSubtotal: true },
      { label: 'Stock measured by drone survey (10 Sep)', value: '162,300 t', type: 'measured' },
    ],
    differenceBadge: 'Difference 0.8%',
    toleranceNote: 'Within the 2% tolerance',
    callout: 'Drone survey shows 1,300 t less than book stock. Within statutory error margin under CMR 2017 Reg 112.',
  },

  airQuality: {
    subtitle: 'PM10 particulate matter (24h rolling average, statutory limit: 100 µg/m³)',
    stations: [
      { label: 'AQ-1 Mine North Entry', value: 78, limit: 100, unit: 'µg/m³' },
      { label: 'AQ-2 Sonari Village', value: 112, limit: 100, unit: 'µg/m³', subtext: 'Village boundary' },
      { label: 'AQ-3 Pit-1 Boundary', value: 88, limit: 100, unit: 'µg/m³' },
      { label: 'AQ-4 Railway Siding', value: 94, limit: 100, unit: 'µg/m³' },
    ],
    note: 'AQ-2 exceedance triggered action plan: 3 additional water tankers deployed on Haul Road South.',
  },

  waterNoiseDust: {
    subtitle: 'Environmental telemetry & statutory limits',
    thresholds: [
      { label: 'Mine water discharge (TDS)', value: 420, limit: 600, unit: 'mg/L', max: 800 },
      { label: 'Noise at CHP boundary (Leq)', value: 71, limit: 75, unit: 'dB(A)', max: 100 },
    ],
    metrics: [
      { label: 'Mine water pH', value: '7.2 (limit 6.5 - 8.5)', status: 'good' },
      { label: 'Road sprinklers', value: '6 of 8 running', status: 'warning' },
      { label: 'Fog cannons', value: '4 of 4 active at CHP', status: 'good' },
      { label: 'Water tanker rounds', value: '14 completed this shift', status: 'good' },
    ],
  },

  ecConditionsAndReclamation: {
    cards: [
      {
        title: 'EC conditions complied',
        value: '43 of 48',
        progress: 90,
        color: 'good',
        subtext: '5 compliance submissions pending with SPCB',
      },
      {
        title: 'Afforestation completed',
        value: '38.5 ha',
        progress: 77,
        color: 'good',
        subtext: 'Target 50 ha afforestation for FY26',
      },
      {
        title: 'Land backfilled & reclaimed',
        value: '12.4 ha',
        progress: 83,
        color: 'good',
        subtext: 'Biological reclamation underway at Dump-1',
      },
    ],
  },
};
