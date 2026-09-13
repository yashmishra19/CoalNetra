import { Router } from 'express';
import { supabase } from '../supabase.js';

const router = Router();

const DEMO_MINE_ID = '55555555-5555-5555-5555-555555555501';
const DEMO_REGION_ID = '11111111-1111-1111-1111-111111111101';

// ═══════════════════════════════════════════
//  GET /api/obligations
// ═══════════════════════════════════════════
router.get('/obligations', async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await supabase.rpc('get_obligations', { p_mine_id: mineId });
    if (error) throw error;

    const now = new Date();
    const obligations = (data || []).map(o => ({
      ...o,
      isOverdue: o.status === 'OVERDUE' || (o.status === 'PENDING' && new Date(o.due_date) < now),
      daysUntilDue: Math.ceil((new Date(o.due_date) - now) / (1000 * 60 * 60 * 24)),
    }));

    const statusFilter = req.query.status?.toUpperCase();
    const filtered = statusFilter ? obligations.filter(o => o.status === statusFilter) : obligations;

    const summary = {
      total: obligations.length,
      pending: obligations.filter(o => o.status === 'PENDING').length,
      overdue: obligations.filter(o => o.status === 'OVERDUE').length,
      completed: obligations.filter(o => o.status === 'COMPLETED').length,
      compliancePct: obligations.length > 0
        ? Math.round((obligations.filter(o => o.status === 'COMPLETED').length / obligations.length) * 100)
        : 0,
    };

    res.json({ obligations: filtered, summary, _source: 'supabase_live' });
  } catch (err) {
    console.error('Obligations route error:', err);
    res.status(500).json({ error: 'Failed to fetch obligations', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  GET /api/capas
// ═══════════════════════════════════════════
router.get('/capas', async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await supabase.rpc('get_capas', { p_mine_id: mineId });
    if (error) throw error;

    const now = new Date();
    let capas = (data || []).map(c => ({
      ...c,
      isOverdue: (c.status === 'OPEN' || c.status === 'ESCALATED') && new Date(c.due_date) < now,
      daysUntilDue: Math.ceil((new Date(c.due_date) - now) / (1000 * 60 * 60 * 24)),
      isMakerCheckerPending: c.status === 'PENDING_VERIFICATION',
    }));

    const statusFilter = req.query.status?.toUpperCase();
    if (statusFilter) capas = capas.filter(c => c.status === statusFilter);
    const severityFilter = req.query.severity?.toUpperCase();
    if (severityFilter) capas = capas.filter(c => c.severity === severityFilter);

    const allCapas = (data || []).map(c => ({
      ...c,
      isOverdue: (c.status === 'OPEN' || c.status === 'ESCALATED') && new Date(c.due_date) < now,
    }));

    const summary = {
      total: allCapas.length,
      open: allCapas.filter(c => c.status === 'OPEN').length,
      escalated: allCapas.filter(c => c.status === 'ESCALATED').length,
      pendingVerification: allCapas.filter(c => c.status === 'PENDING_VERIFICATION').length,
      verified: allCapas.filter(c => c.status === 'VERIFIED').length,
      overdue: allCapas.filter(c => c.isOverdue).length,
      highSeverity: allCapas.filter(c => c.severity === 'HIGH' || c.severity === 'CRITICAL').length,
    };

    res.json({ capas, summary, _source: 'supabase_live' });
  } catch (err) {
    console.error('CAPAs route error:', err);
    res.status(500).json({ error: 'Failed to fetch CAPAs', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  GET /api/incidents
// ═══════════════════════════════════════════
router.get('/incidents', async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await supabase.rpc('get_incidents', { p_mine_id: mineId });
    if (error) throw error;
    res.json({ incidents: data || [], count: (data || []).length, _source: 'supabase_live' });
  } catch (err) {
    console.error('Incidents route error:', err);
    res.status(500).json({ error: 'Failed to fetch incidents', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  GET /api/directions
// ═══════════════════════════════════════════
router.get('/directions', async (req, res) => {
  try {
    const regionId = req.query.regionId || DEMO_REGION_ID;
    const { data, error } = await supabase.rpc('get_directions', { p_region_id: regionId });
    if (error) throw error;

    const now = new Date();
    const directions = (data || []).map(d => ({
      ...d,
      isOverdue: d.status === 'OPEN' && new Date(d.compliance_date) < now,
      daysOverdue: d.status === 'OPEN' && new Date(d.compliance_date) < now
        ? Math.floor((now - new Date(d.compliance_date)) / (1000 * 60 * 60 * 24))
        : null,
    }));

    res.json({ directions, count: directions.length, _source: 'supabase_live' });
  } catch (err) {
    console.error('Directions route error:', err);
    res.status(500).json({ error: 'Failed to fetch directions', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  GET /api/observations
// ═══════════════════════════════════════════
router.get('/observations', async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await supabase.rpc('get_observations', { p_mine_id: mineId });
    if (error) throw error;
    const limit = parseInt(req.query.limit) || 50;
    res.json({ observations: (data || []).slice(0, limit), count: (data || []).length, _source: 'supabase_live' });
  } catch (err) {
    console.error('Observations route error:', err);
    res.status(500).json({ error: 'Failed to fetch observations', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  GET /api/mine
// ═══════════════════════════════════════════
router.get('/mine', async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;

    const [mineResult, sectionsResult, riskResult] = await Promise.all([
      supabase
        .from('mines')
        .select('id, name, code, mine_type')
        .eq('id', mineId)
        .single(),
      supabase.rpc('get_sections', { p_mine_id: mineId }),
      supabase.rpc('get_risk_score', { p_mine_id: mineId }),
    ]);

    // mines table is accessible via RLS (any authenticated user sees their mine)
    // but anon key may not be authenticated — try direct query first, fall back gracefully
    const mine = mineResult.data || { id: mineId, name: 'Demo OCP-1', code: 'WCL-WANI-DOCP1', mine_type: 'OPENCAST' };

    res.json({
      mine,
      sections: sectionsResult.data || [],
      riskScore: Array.isArray(riskResult.data) ? riskResult.data[0] : riskResult.data,
      _source: 'supabase_live',
    });
  } catch (err) {
    console.error('Mine route error:', err);
    res.status(500).json({ error: 'Failed to fetch mine data', details: err.message });
  }
});

export default router;
