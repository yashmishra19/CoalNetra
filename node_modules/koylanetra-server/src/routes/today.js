import { Router } from 'express';
import { supabase } from '../supabase.js';

const router = Router();

const DEMO_MINE_ID = '55555555-5555-5555-5555-555555555501';

router.get('/', async (req, res) => {
  try {
    // Use SECURITY DEFINER RPC functions to bypass RLS for server-to-server calls
    const [
      dashboardResult,
      obligationsResult,
      capasResult,
      incidentsResult,
      observationsResult,
      sectionsResult,
      riskResult,
    ] = await Promise.all([
      supabase.rpc('get_mine_dashboard', { p_mine_id: DEMO_MINE_ID }),
      supabase.rpc('get_obligations', { p_mine_id: DEMO_MINE_ID }),
      supabase.rpc('get_capas', { p_mine_id: DEMO_MINE_ID }),
      supabase.rpc('get_incidents', { p_mine_id: DEMO_MINE_ID }),
      supabase.rpc('get_observations', { p_mine_id: DEMO_MINE_ID }),
      supabase.rpc('get_sections', { p_mine_id: DEMO_MINE_ID }),
      supabase.rpc('get_risk_score', { p_mine_id: DEMO_MINE_ID }),
    ]);

    const dashboard = dashboardResult.data;
    const obligations = obligationsResult.data || [];
    const capas = capasResult.data || [];
    const incidents = incidentsResult.data || [];
    const observations = observationsResult.data || [];
    const sections = sectionsResult.data || [];
    const riskScoreRow = Array.isArray(riskResult.data) ? riskResult.data[0] : riskResult.data;

    const now = new Date();
    const sevenDaysOut = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);

    // ── Risk Score ──
    const breakdown = riskScoreRow?.component_breakdown || {};
    const riskValue = riskScoreRow ? Math.round(parseFloat(riskScoreRow.score)) : 68;
    const componentLabels = {
      slope_displacement: 'Dump-3 slope',
      haul_road_berms: 'Haul Road berms',
      bench_inspection_gaps: 'Bench inspections',
      sump_pumping: 'Sump dewatering',
    };
    const worstComponent = Object.entries(breakdown).sort(([, a], [, b]) => b - a)[0];

    // ── Obligations ──
    const overdueObligations = obligations.filter(o => o.status === 'OVERDUE');
    const pendingObligations = obligations.filter(o => o.status === 'PENDING');
    const completedObligations = obligations.filter(o => o.status === 'COMPLETED');
    const compliancePct = obligations.length > 0
      ? Math.round((completedObligations.length / obligations.length) * 100)
      : 0;
    const oblDue7Days = pendingObligations.filter(o => new Date(o.due_date) <= sevenDaysOut);

    // ── CAPAs ──
    const openCapas = capas.filter(c => c.status === 'OPEN' || c.status === 'ESCALATED');
    const overdueCapas = capas.filter(c =>
      (c.status === 'OPEN' || c.status === 'ESCALATED') && new Date(c.due_date) < now
    );
    const escalatedCapas = capas.filter(c => c.status === 'ESCALATED');
    const highSeverityCapas = capas.filter(c =>
      (c.severity === 'HIGH' || c.severity === 'CRITICAL') &&
      (c.status === 'OPEN' || c.status === 'ESCALATED')
    );
    const pendingVerification = capas.filter(c => c.status === 'PENDING_VERIFICATION');

    // ── Incidents ──
    const seriousIncident = incidents.find(i =>
      (i.incident_type === 'SERIOUS' || i.incident_type === 'FATAL') && i.within_24h_window
    );

    // ── Decisions list ──
    const decisions = [];
    pendingVerification.forEach(c => {
      decisions.push({
        id: `verify-${c.id}`,
        status: 'critical',
        title: `Verify closure: ${c.title}`,
        description: 'Closed by field officer with after-photos. Requires your on-site verification (Maker-Checker Rule C).',
        timeInfo: { primary: 'Pending', secondary: 'verification', variant: 'warning' },
        actions: [{ label: 'Verify', variant: 'dark-blue' }, { label: 'Reopen', variant: 'secondary' }],
        _capaId: c.id,
      });
    });
    escalatedCapas.forEach(c => {
      const daysOverdue = Math.floor((now - new Date(c.due_date)) / (1000 * 60 * 60 * 24));
      decisions.push({
        id: `escalated-${c.id}`,
        status: 'critical',
        title: `Escalated to you: ${c.title}`,
        description: `Owner missed the deadline. Severity: ${c.severity}.`,
        timeInfo: {
          primary: daysOverdue > 0 ? `${daysOverdue}d` : 'Due today',
          secondary: daysOverdue > 0 ? 'overdue' : '',
          variant: 'critical',
        },
        actions: [{ label: 'Reassign', variant: 'dark-blue' }, { label: 'View', variant: 'secondary' }],
        _capaId: c.id,
      });
    });
    overdueObligations.slice(0, 2).forEach(o => {
      decisions.push({
        id: `overdue-obl-${o.id}`,
        status: 'warning',
        title: `Overdue obligation: ${o.title}`,
        description: `${o.frequency} obligation. Ref: ${[o.cmr_2017_ref, o.oshwc_2020_ref].filter(Boolean).join(' / ')} · ${o.law_status}.`,
        timeInfo: { primary: 'Overdue', secondary: '', variant: 'critical' },
        actions: [{ label: 'Mark Done', variant: 'dark-blue' }, { label: 'View', variant: 'secondary' }],
        _obligationId: o.id,
      });
    });
    if (decisions.length < 5) {
      decisions.push({
        id: 'dec-sign-return',
        status: 'neutral',
        title: 'Sign monthly production return for August',
        description: 'Generated from weighbridge and survey data. No gaps found.',
        timeInfo: { primary: '2 days', secondary: 'by 15 Sep', variant: 'neutral' },
        actions: [{ label: 'Review', variant: 'secondary' }],
      });
    }

    // ── Risk Zones ──
    const rankedRiskZones = Object.entries(breakdown)
      .sort(([, a], [, b]) => b - a)
      .map(([key, score], i) => ({
        rank: i + 1,
        score,
        badgeVariant: score >= 75 ? 'critical' : score >= 60 ? 'warning' : 'neutral',
        name: componentLabels[key] || key,
        detail: score >= 75 ? 'Above alert threshold' : score >= 60 ? 'Elevated risk' : 'Within normal range',
      }));

    // ── Deadlines ──
    const upcomingObligations24h = obligations
      .filter(o => o.status === 'PENDING' && new Date(o.due_date) <= new Date(now.getTime() + 24 * 60 * 60 * 1000))
      .map(o => ({
        title: o.title,
        due: new Date(o.due_date).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' }) + ' today',
        isCritical: false,
      }));
    if (seriousIncident) {
      upcomingObligations24h.unshift({
        title: `DGMS accident notice: ${seriousIncident.description?.substring(0, 60)}...`,
        due: '24h window',
        isCritical: true,
      });
    }
    const upcoming7d = pendingObligations
      .filter(o => new Date(o.due_date) > new Date(now.getTime() + 24 * 60 * 60 * 1000) && new Date(o.due_date) <= sevenDaysOut)
      .slice(0, 4)
      .map(o => ({
        title: o.title,
        due: new Date(o.due_date).toLocaleDateString('en-IN', { day: 'numeric', month: 'short' }),
      }));

    // ── Field Feed from real observations ──
    const fieldFeed = observations.slice(0, 5).map(obs => ({
      id: `feed-obs-${obs.id}`,
      time: new Date(obs.created_at).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' }),
      author: 'Field Officer',
      action: `logged a safety observation: ${obs.title}`,
      detail: `Classification: ${obs.classification}, Severity: ${obs.severity}. Status: ${obs.status}.`,
      tag: obs.provenance === 'INSPECTOR' ? 'Inspector verified' : 'QR tag',
      tagVariant: obs.provenance === 'INSPECTOR' ? 'gps-verified' : 'qr-tag',
    }));
    fieldFeed.push({
      id: 'feed-static-1',
      time: '14:43',
      author: 'R. Singh',
      action: 'tried to submit an inspection from outside the lease.',
      detail: 'Location 1.3 km from boundary. Held for review.',
      tag: 'Location flagged',
      tagVariant: 'location-flagged',
    });

    res.json({
      _source: 'supabase_live',
      header: {
        title: 'Today at Demo OCP-1',
        subtitle: 'Everything that needs your decision this shift, soonest deadline first.',
      },
      alertBanner: seriousIncident ? {
        id: `alert-incident-${seriousIncident.id}`,
        title: `${seriousIncident.incident_type === 'SERIOUS' ? 'Serious' : 'Fatal'} accident notice is due to DGMS`,
        description: seriousIncident.description,
        location: seriousIncident.location_description,
        occurredAt: seriousIncident.occurred_at,
        within24hWindow: seriousIncident.within_24h_window,
        totalWindow: '24 hours',
        ctaText: 'Review and sign notice',
      } : null,
      kpiStats: [
        {
          id: 'mine-risk-score',
          title: 'Mine risk score',
          value: String(riskValue),
          trend: { direction: 'up', value: '5', color: 'critical' },
          subtext: worstComponent ? `Rising. Main driver: ${componentLabels[worstComponent[0]] || worstComponent[0]}` : 'Risk score current',
          accentColor: riskValue >= 70 ? 'critical' : riskValue >= 50 ? 'warning' : 'good',
        },
        {
          id: 'compliance',
          title: 'Compliance',
          value: `${compliancePct}%`,
          trend: { direction: compliancePct < 90 ? 'down' : 'up', value: '2', color: compliancePct < 90 ? 'warning' : 'good' },
          subtext: `Target 95%. ${oblDue7Days.length} items due this week`,
          accentColor: compliancePct >= 90 ? 'good' : compliancePct >= 75 ? 'warning' : 'critical',
        },
        {
          id: 'overdue-items',
          title: 'Overdue items',
          value: String(overdueObligations.length + overdueCapas.length),
          subtext: `${overdueObligations.length} compliance, ${overdueCapas.length} CAPA`,
          accentColor: (overdueObligations.length + overdueCapas.length) > 10 ? 'critical' : (overdueObligations.length + overdueCapas.length) > 3 ? 'warning' : 'neutral',
        },
        {
          id: 'critical-high-capas',
          title: 'Critical and high CAPAs',
          value: String(highSeverityCapas.length),
          subtext: `${escalatedCapas.length} escalated to you`,
          accentColor: highSeverityCapas.length > 0 ? 'warning' : 'good',
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
        count: decisions.length,
        items: decisions,
        footerNote: `${Math.max(0, openCapas.length + overdueObligations.length - decisions.length)} more items in Reports & approvals`,
      },
      riskHighest: {
        lastUpdated: riskScoreRow ? new Date(riskScoreRow.assessed_at).toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' }) : '16:00',
        rankedItems: rankedRiskZones,
      },
      deadlines: {
        hours24: {
          title: 'Next 24 hours',
          count: upcomingObligations24h.length,
          items: upcomingObligations24h.slice(0, 4),
        },
        days7: {
          title: 'Next 7 days',
          count: upcoming7d.length,
          items: upcoming7d,
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
        totalCount: sections.length > 0 ? sections.length + 14 : 18,
        remainingItems: sections.slice(0, 4).map(s => ({
          name: s.name,
          due: '--:--',
          status: 'neutral',
          tagCode: s.tag_code,
          tagType: s.tag_type,
        })),
        footerNote: `${sections.length} tagged sections in mine. ${sections.filter(s => s.tag_type === 'QR').length} QR, ${sections.filter(s => s.tag_type === 'NFC').length} NFC.`,
      },
      insights: [
        {
          id: 'insight-1',
          category: 'Repeating problem',
          status: overdueObligations.length > 2 ? 'critical' : 'warning',
          title: `${overdueObligations.length} statutory obligation(s) overdue right now`,
          description: 'Haul road berm compliance and monthly returns are the main overdue items.',
        },
        {
          id: 'insight-2',
          category: 'CAPA escalation',
          status: escalatedCapas.length > 0 ? 'warning' : 'neutral',
          title: `${escalatedCapas.length} CAPA(s) escalated — require your direct action`,
          description: 'Escalated CAPAs need reassignment or extended deadline by the Mine Manager.',
        },
        {
          id: 'insight-3',
          category: 'Compliance trend',
          status: compliancePct < 90 ? 'warning' : 'neutral',
          title: `Overall compliance at ${compliancePct}% against 95% target`,
          description: `${obligations.length} total obligations: ${completedObligations.length} completed, ${overdueObligations.length} overdue, ${pendingObligations.length} pending.`,
        },
      ],
      liveReadings: [
        { id: 'dust-aq2', label: 'Dust, AQ-2 Sonari', value: '112 µg/m³ PM10', note: 'limit 100', status: 'critical' },
        { id: 'dust-suppression', label: 'Dust suppression', value: '6 of 8', note: 'sprinklers running', status: 'warning' },
        { id: 'dump3-radar', label: 'Dump-3 slope radar (score)', value: `${breakdown.slope_displacement || 81} / 100`, note: 'alert at 80', status: (breakdown.slope_displacement || 81) >= 80 ? 'critical' : 'warning' },
        { id: 'sump-water', label: 'Sump-1 water level', value: '62%', note: '2 of 3 pumps on', status: 'good' },
        { id: 'haul-traffic', label: 'Haul road traffic', value: '34 dumpers', note: '2 over speed in last hour', status: 'warning' },
      ],
      fieldFeed,
      rawData: {
        dashboard,
        obligationCounts: {
          total: obligations.length,
          pending: pendingObligations.length,
          overdue: overdueObligations.length,
          completed: completedObligations.length,
        },
        capaCounts: {
          total: capas.length,
          open: openCapas.length,
          escalated: escalatedCapas.length,
          pendingVerification: pendingVerification.length,
          highSeverity: highSeverityCapas.length,
        },
        incidents: incidents.map(i => ({
          id: i.id, type: i.incident_type, occurred_at: i.occurred_at,
          within_24h_window: i.within_24h_window, description: i.description,
        })),
      },
      footerDisclaimer: 'Live data from Demo OCP-1 · Supabase Postgres 17 · KoylaNetra v1.0',
    });
  } catch (err) {
    console.error('Today route error:', err);
    res.status(500).json({ error: 'Failed to fetch today dashboard data', details: err.message });
  }
});

export default router;
