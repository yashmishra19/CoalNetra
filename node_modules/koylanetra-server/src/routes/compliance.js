import { Router } from 'express';
import { requireAuth } from '../middleware/auth.js';

const router = Router();

const DEMO_MINE_ID = '55555555-5555-5555-5555-555555555501';
const DEMO_REGION_ID = '11111111-1111-1111-1111-111111111101';

// ═══════════════════════════════════════════
//  GET /api/obligations
// ═══════════════════════════════════════════
router.get('/obligations', requireAuth, async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await req.userClient.rpc('get_obligations', { p_mine_id: mineId });
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
router.get('/capas', requireAuth, async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await req.userClient.rpc('get_capas', { p_mine_id: mineId });
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
router.get('/incidents', requireAuth, async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await req.userClient.rpc('get_incidents', { p_mine_id: mineId });
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
router.get('/directions', requireAuth, async (req, res) => {
  try {
    const regionId = req.query.regionId || DEMO_REGION_ID;
    const { data, error } = await req.userClient.rpc('get_directions', { p_region_id: regionId });
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
//  GET /api/observations  (field officer inserts via POST)
// ═══════════════════════════════════════════
router.get('/observations', requireAuth, async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;
    const { data, error } = await req.userClient.rpc('get_observations', { p_mine_id: mineId });
    if (error) throw error;
    const limit = parseInt(req.query.limit) || 50;
    res.json({ observations: (data || []).slice(0, limit), count: (data || []).length, _source: 'supabase_live' });
  } catch (err) {
    console.error('Observations route error:', err);
    res.status(500).json({ error: 'Failed to fetch observations', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  POST /api/observations  (field officer only)
// ═══════════════════════════════════════════
router.post('/observations', requireAuth, async (req, res) => {
  try {
    const body = req.body || {};
    const userId = req.authUser.id;

    const DEMO_MINE_ID_CONST = '55555555-5555-5555-5555-555555555501';
    const DEMO_AREA_ID = '44444444-4444-4444-4444-444444444401';
    const DEMO_SUBSIDIARY_ID = '33333333-3333-3333-3333-333333333301';
    const DEMO_DISTRICT_ID = '22222222-2222-2222-2222-222222222201';
    const DEMO_REGION_ID_CONST = '11111111-1111-1111-1111-111111111101';
    const DEMO_SECTION_ID = '66666666-6666-6666-6666-666666666601';

    const row = {
      client_uuid: body.clientUuid || crypto.randomUUID(),
      mine_id: body.mineId || DEMO_MINE_ID_CONST,
      mine_name: body.mineName || 'Demo OCP-1',
      area_id: DEMO_AREA_ID,
      subsidiary_id: DEMO_SUBSIDIARY_ID,
      district_id: DEMO_DISTRICT_ID,
      dgms_region_id: DEMO_REGION_ID_CONST,
      section_id: DEMO_SECTION_ID,
      reported_by: userId,   // always use the logged-in user's UUID
      category: body.category || 'Safety Hazard',
      severity: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].includes(String(body.severity || '').toUpperCase())
        ? String(body.severity).toUpperCase() : 'MEDIUM',
      description: body.description || body.category || 'Field observation',
      checkin_method: body.checkinMethod === 'QR' ? 'QR' : 'GPS',
      device_id: body.deviceId || 'web-client',
      client_created_at: body.clientCreatedAt || new Date().toISOString(),
    };

    const { data, error } = await req.userClient
      .from('observations')
      .insert(row)
      .select('id, client_uuid')
      .single();

    if (error) throw error;
    res.status(201).json({ observation: data, _source: 'supabase_live' });
  } catch (err) {
    console.error('POST observations error:', err);
    res.status(500).json({ error: 'Failed to create observation', details: err.message });
  }
});

// ═══════════════════════════════════════════
//  GET /api/mine
// ═══════════════════════════════════════════
router.get('/mine', requireAuth, async (req, res) => {
  try {
    const mineId = req.query.mineId || DEMO_MINE_ID;

    const [mineResult, sectionsResult, riskResult] = await Promise.all([
      req.userClient
        .from('mines')
        .select('id, name, code, mine_type')
        .eq('id', mineId)
        .single(),
      req.userClient.rpc('get_sections', { p_mine_id: mineId }),
      req.userClient.rpc('get_risk_score', { p_mine_id: mineId }),
    ]);

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
