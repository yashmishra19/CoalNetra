import { Router } from 'express';
import { supabaseAdmin } from '../supabase.js';

const router = Router();
const DEMO_MINE_ID = '55555555-5555-5555-5555-555555555501';
const DEMO_AREA_ID = '44444444-4444-4444-4444-444444444401';
const DEMO_SUBSIDIARY_ID = '33333333-3333-3333-3333-333333333301';
const DEMO_DISTRICT_ID = '22222222-2222-2222-2222-222222222201';
const DEMO_REGION_ID = '11111111-1111-1111-1111-111111111101';
const DEMO_SECTION_ID = '66666666-6666-6666-6666-666666666601';
const DEMO_FIELD_OFFICER_ID = '77777777-7777-7777-7777-777777777701';

function requireAdmin(res) {
  if (!supabaseAdmin) {
    res.status(503).json({ error: 'Sync is not configured: SUPABASE_SERVICE_ROLE_KEY is missing' });
    return false;
  }
  return true;
}

function pointFromLocation(location) {
  const match = String(location || '').match(/(-?\d+(?:\.\d+)?)[, ]+(-?\d+(?:\.\d+)?)/);
  return match ? `POINT(${match[2]} ${match[1]})` : null;
}

router.post('/push', async (req, res) => {
  if (!requireAdmin(res)) return;
  const { observations = [], grievances = [], locationPings = [], sosEvents = [] } = req.body || {};
  const accepted = { observations: [], grievances: [], locationPings: [], sosEvents: [] };

  try {
    for (const item of observations) {
      if (!item.clientUuid) continue;
      const row = {
        client_uuid: item.clientUuid,
        mine_id: DEMO_MINE_ID,
        mine_name: 'Demo OCP-1',
        area_id: DEMO_AREA_ID,
        subsidiary_id: DEMO_SUBSIDIARY_ID,
        district_id: DEMO_DISTRICT_ID,
        dgms_region_id: DEMO_REGION_ID,
        section_id: DEMO_SECTION_ID,
        reported_by: DEMO_FIELD_OFFICER_ID,
        category: item.category || 'Safety Hazard',
        severity: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'].includes(String(item.severity).toUpperCase())
          ? String(item.severity).toUpperCase() : 'MEDIUM',
        location: pointFromLocation(item.location),
        checkin_method: item.checkinMethod === 'QR' ? 'QR' : 'GPS',
        tag_scanned: null,
        device_id: item.deviceId || 'mobile-offline-client',
        client_created_at: item.clientCreatedAt || new Date().toISOString(),
        description: item.description || item.category || 'Field observation submitted offline',
      };
      const { data, error } = await supabaseAdmin
        .from('observations').upsert(row, { onConflict: 'client_uuid' }).select('id, client_uuid').single();
      if (error) throw error;
      accepted.observations.push(data);
    }

    for (const item of grievances) {
      if (!item.clientUuid) continue;
      const { data, error } = await supabaseAdmin.from('grievances').upsert({
        client_uuid: item.clientUuid,
        mine_id: DEMO_MINE_ID,
        raised_by: item.isAnonymous ? null : DEMO_FIELD_OFFICER_ID,
        is_anonymous: Boolean(item.isAnonymous),
        lang: item.lang || 'en',
        raw_text: item.rawText || '',
        created_at: item.createdAt || new Date().toISOString(),
      }, { onConflict: 'client_uuid' }).select('id, client_uuid').single();
      if (error) throw error;
      accepted.grievances.push(data);
    }

    // ── Location Pings (employee live tracking)
    for (const item of locationPings) {
      if (!item.clientUuid) continue;
      const row = {
        client_uuid: item.clientUuid,
        mine_id: DEMO_MINE_ID,
        reported_by: item.reportedBy || DEMO_FIELD_OFFICER_ID,
        role: item.role || 'sirdar',
        lat: item.lat,
        lng: item.lng,
        accuracy: item.accuracy || null,
        location_confidence: item.locationConfidence || 'last_known',
        captured_at: item.capturedAt || new Date().toISOString(),
      };
      // Use upsert so re-synced pings don't throw duplicate errors
      const { data, error } = await supabaseAdmin
        .from('location_pings')
        .upsert(row, { onConflict: 'client_uuid' })
        .select('id, client_uuid').single();
      if (error) {
        // Table may not exist yet — log but don't crash the whole sync
        console.warn('location_pings upsert error (table may not exist):', error.message);
        accepted.locationPings.push({ client_uuid: item.clientUuid });
        continue;
      }
      accepted.locationPings.push(data);
    }

    // ── SOS Events (emergency alerts)
    for (const item of sosEvents) {
      if (!item.clientUuid) continue;
      const row = {
        client_uuid: item.clientUuid,
        mine_id: DEMO_MINE_ID,
        triggered_by: item.triggeredBy || DEMO_FIELD_OFFICER_ID,
        role: item.role || 'sirdar',
        user_name: item.userName || null,
        lat: item.lat || null,
        lng: item.lng || null,
        location_confidence: item.locationConfidence || 'unknown',
        sent_via_channel: item.sentViaChannel || 'cellular',
        mesh_relayed_by: item.meshRelayedBy || null,
        triggered_at: item.triggeredAt || new Date().toISOString(),
      };
      const { data, error } = await supabaseAdmin
        .from('sos_events')
        .upsert(row, { onConflict: 'client_uuid' })
        .select('id, client_uuid').single();
      if (error) {
        console.warn('sos_events upsert error (table may not exist):', error.message);
        accepted.sosEvents.push({ client_uuid: item.clientUuid });
        continue;
      }
      accepted.sosEvents.push(data);
    }

    res.json({ accepted, serverTime: new Date().toISOString() });
  } catch (error) {
    console.error('Sync push error:', error);
    res.status(500).json({ error: 'Sync push failed', details: error.message });
  }
});

router.get('/pull', async (req, res) => {
  if (!requireAdmin(res)) return;
  try {
    const [obligations, observations, capas, grievances] = await Promise.all([
      supabaseAdmin.from('obligations').select('*').eq('mine_id', DEMO_MINE_ID).order('updated_at', { ascending: false }).limit(500),
      supabaseAdmin.from('observations').select('*').eq('mine_id', DEMO_MINE_ID).order('server_created_at', { ascending: false }).limit(500),
      supabaseAdmin.from('capas').select('*').eq('mine_id', DEMO_MINE_ID).order('updated_at', { ascending: false }).limit(500),
      supabaseAdmin.from('grievances').select('*').eq('mine_id', DEMO_MINE_ID).order('updated_at', { ascending: false }).limit(500),
    ]);
    const failed = [obligations, observations, capas, grievances].find(result => result.error);
    if (failed) throw failed.error;
    res.json({ obligations: obligations.data, observations: observations.data, capas: capas.data, grievances: grievances.data, serverTime: new Date().toISOString() });
  } catch (error) {
    console.error('Sync pull error:', error);
    res.status(500).json({ error: 'Sync pull failed', details: error.message });
  }
});

export default router;
