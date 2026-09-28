import { Router } from 'express';

const router = Router();

const mockObligations = [
  { id: 'ob-1', mine_id: 'demo', description: 'Weekly haul road inspection, all roads', frequency: 'WEEKLY', owner_role: 'MINE_MANAGER', due_date: '2026-09-13', status: 'OVERDUE', cmr_2017_ref: 'Reg 108', oshwc_2020_ref: null },
  { id: 'ob-2', mine_id: 'demo', description: 'Monthly production return', frequency: 'MONTHLY', owner_role: 'MINE_MANAGER', due_date: '2026-09-13', status: 'PENDING', cmr_2017_ref: 'Reg 45', oshwc_2020_ref: 'Sec 22' },
  { id: 'ob-3', mine_id: 'demo', description: 'Ventilation survey, underground districts', frequency: 'QUARTERLY', owner_role: 'FIELD_OFFICER', due_date: '2026-10-01', status: 'PENDING', cmr_2017_ref: 'Reg 130', oshwc_2020_ref: null },
  { id: 'ob-4', mine_id: 'demo', description: 'Explosives magazine stock reconciliation', frequency: 'WEEKLY', owner_role: 'FIELD_OFFICER', due_date: '2026-09-14', status: 'PENDING', cmr_2017_ref: 'Reg 176', oshwc_2020_ref: null },
  { id: 'ob-5', mine_id: 'demo', description: 'Contract labour licence renewal, Kalpana Logistics', frequency: 'ANNUAL', owner_role: 'MINE_MANAGER', due_date: '2026-10-20', status: 'PENDING', cmr_2017_ref: null, oshwc_2020_ref: 'Sec 8' },
  { id: 'ob-6', mine_id: 'demo', description: 'Consent to Operate renewal, Pollution Control Board', frequency: 'ANNUAL', owner_role: 'MINE_MANAGER', due_date: '2026-11-10', status: 'PENDING', cmr_2017_ref: null, oshwc_2020_ref: null },
  { id: 'ob-7', mine_id: 'demo', description: 'Dust suppression system check, Haul Road South', frequency: 'DAILY', owner_role: 'FIELD_OFFICER', due_date: '2026-09-12', status: 'COMPLETED', cmr_2017_ref: 'Reg 109', oshwc_2020_ref: null },
  { id: 'ob-8', mine_id: 'demo', description: 'Fire fighting equipment check, surface installations', frequency: 'MONTHLY', owner_role: 'FIELD_OFFICER', due_date: '2026-09-10', status: 'COMPLETED', cmr_2017_ref: 'Reg 176', oshwc_2020_ref: null },
];

const mockCapas = [
  { id: 'capa-231', mine_id: 'demo', description: 'Low berm on Haul Road North', owner_id: 'A. Kujur', severity: 'CRITICAL', due_date: '2026-09-13T18:20:00Z', status: 'PENDING_VERIFICATION', escalation_level: 0, closed_by: 'A. Kujur', closed_at: '2026-09-13T15:41:00Z', verified_by: null, verified_at: null },
  { id: 'capa-198', mine_id: 'demo', description: 'Drainage at Dump-3 toe', owner_id: 'S. Tirkey', severity: 'HIGH', due_date: '2026-09-12T18:00:00Z', status: 'ESCALATED', escalation_level: 1, closed_by: null, closed_at: null, verified_by: null, verified_at: null },
  { id: 'capa-240', mine_id: 'demo', description: 'Loose material on Bench 3 edge', owner_id: 'B. Oraon', severity: 'MEDIUM', due_date: '2026-09-19T00:00:00Z', status: 'OPEN', escalation_level: 0, closed_by: null, closed_at: null, verified_by: null, verified_at: null },
  { id: 'capa-201', mine_id: 'demo', description: 'Guard missing on crusher conveyor drive', owner_id: 'P. Munda', severity: 'HIGH', due_date: '2026-09-15T00:00:00Z', status: 'OPEN', escalation_level: 0, closed_by: null, closed_at: null, verified_by: null, verified_at: null },
  { id: 'capa-188', mine_id: 'demo', description: 'Fire extinguisher expired, Shovel-7', owner_id: 'S. Ekka', severity: 'LOW', due_date: '2026-09-24T00:00:00Z', status: 'OPEN', escalation_level: 0, closed_by: null, closed_at: null, verified_by: null, verified_at: null },
  { id: 'capa-176', mine_id: 'demo', description: 'Signage missing at blast zone boundary', owner_id: 'M. Hansda', severity: 'MEDIUM', due_date: '2026-09-08T00:00:00Z', status: 'VERIFIED', escalation_level: 0, closed_by: 'M. Hansda', closed_at: '2026-09-07T12:00:00Z', verified_by: 'R. K. Mahato', verified_at: '2026-09-08T09:00:00Z' },
];

const mockIncidents = [
  { id: 'inc-1', mine_id: 'demo', incident_type: 'SERIOUS', occurred_at: '2026-09-09T22:02:00Z', notified_phone_at: '2026-09-09T23:31:00Z', written_notice_at: '2026-09-10T08:40:00Z', within_24h_window: true, description: 'Dumper operator injured on Haul Road North' },
  { id: 'inc-2', mine_id: 'demo', incident_type: 'DANGEROUS_OCCURRENCE', occurred_at: '2026-08-02T06:40:00Z', notified_phone_at: '2026-08-03T11:20:00Z', written_notice_at: '2026-08-04T00:10:00Z', within_24h_window: false, description: 'Winding rope slip, shaft inspection' },
];

const mockDirections = [
  { id: 'dir-1', dgms_region_id: 'demo-region', defect_category: 'Inadequate benching and sloping', enforcement_step: 'WRITTEN_DIRECTION', compliance_date: '2026-08-15', evidence_received: false, status: 'OPEN' },
  { id: 'dir-2', dgms_region_id: 'demo-region', defect_category: 'Dump slope stability study incomplete', enforcement_step: 'IMPROVEMENT_NOTICE', compliance_date: '2026-08-30', evidence_received: true, status: 'OPEN' },
  { id: 'dir-3', dgms_region_id: 'demo-region', defect_category: 'Ventilation plan amendment', enforcement_step: 'OBSERVATION', compliance_date: '2026-09-20', evidence_received: true, status: 'OPEN' },
  { id: 'dir-4', dgms_region_id: 'demo-region', defect_category: 'Berm height on contractor roads', enforcement_step: 'IMPROVEMENT_NOTICE', compliance_date: '2026-08-05', evidence_received: false, status: 'OVERDUE' },
];

const mockObservations = [
  { id: 'obs-1', mine_id: 'demo', reported_by: 'B. Oraon', description: 'Loose material on Bench 3 edge', category: 'SAFETY', severity: 'MEDIUM', checkin_method: 'GPS', location_valid: true, client_created_at: '2026-09-13T16:12:00Z' },
  { id: 'obs-2', mine_id: 'demo', reported_by: 'M. Hansda', description: 'PM10 reading at AQ-2 by voice note', category: 'ENVIRONMENT', severity: 'LOW', checkin_method: 'GPS', location_valid: true, client_created_at: '2026-09-13T15:58:00Z' },
  { id: 'obs-3', mine_id: 'demo', reported_by: 'S. Ekka', description: 'Sump-1 electrical panel inspection, all clear', category: 'PROCEDURAL', severity: 'LOW', checkin_method: 'QR', location_valid: true, client_created_at: '2026-09-13T15:20:00Z' },
  { id: 'obs-4', mine_id: 'demo', reported_by: 'R. Singh', description: 'Inspection attempted outside lease boundary', category: 'PROCEDURAL', severity: 'MEDIUM', checkin_method: 'GPS', location_valid: false, client_created_at: '2026-09-13T14:43:00Z' },
];

const mockMine = {
  mine: { id: 'demo', name: 'Demo OCP-1', code: 'WCL-WANI-DOCP1', mine_type: 'OPENCAST' },
  sections: [
    { id: 'sec-1', name: 'Bench 4', tag_code: 'QR-BENCH4' },
    { id: 'sec-2', name: 'Dump-3', tag_code: 'QR-DUMP3' },
    { id: 'sec-3', name: 'Haul Road North', tag_code: 'QR-HRN' },
    { id: 'sec-4', name: 'Explosives magazine', tag_code: 'QR-MAGAZINE' },
  ],
  riskScore: { score: 68, trend: 'up' },
};

function withObligationFlags(o) {
  const now = new Date();
  return {
    ...o,
    isOverdue: o.status === 'OVERDUE' || (o.status === 'PENDING' && new Date(o.due_date) < now),
    daysUntilDue: Math.ceil((new Date(o.due_date) - now) / (1000 * 60 * 60 * 24)),
  };
}

function withCapaFlags(c) {
  const now = new Date();
  return {
    ...c,
    isOverdue: (c.status === 'OPEN' || c.status === 'ESCALATED') && new Date(c.due_date) < now,
    daysUntilDue: Math.ceil((new Date(c.due_date) - now) / (1000 * 60 * 60 * 24)),
    isMakerCheckerPending: c.status === 'PENDING_VERIFICATION',
  };
}

router.get('/obligations', (req, res) => {
  const obligations = mockObligations.map(withObligationFlags);
  const statusFilter = req.query.status?.toUpperCase();
  const filtered = statusFilter ? obligations.filter(o => o.status === statusFilter) : obligations;

  const summary = {
    total: obligations.length,
    pending: obligations.filter(o => o.status === 'PENDING').length,
    overdue: obligations.filter(o => o.status === 'OVERDUE').length,
    completed: obligations.filter(o => o.status === 'COMPLETED').length,
    compliancePct: Math.round((obligations.filter(o => o.status === 'COMPLETED').length / obligations.length) * 100),
  };

  res.json({ obligations: filtered, summary, _source: 'mock' });
});

router.get('/capas', (req, res) => {
  let capas = mockCapas.map(withCapaFlags);

  const statusFilter = req.query.status?.toUpperCase();
  if (statusFilter) capas = capas.filter(c => c.status === statusFilter);
  const severityFilter = req.query.severity?.toUpperCase();
  if (severityFilter) capas = capas.filter(c => c.severity === severityFilter);

  const allCapas = mockCapas.map(withCapaFlags);
  const summary = {
    total: allCapas.length,
    open: allCapas.filter(c => c.status === 'OPEN').length,
    escalated: allCapas.filter(c => c.status === 'ESCALATED').length,
    pendingVerification: allCapas.filter(c => c.status === 'PENDING_VERIFICATION').length,
    verified: allCapas.filter(c => c.status === 'VERIFIED').length,
    overdue: allCapas.filter(c => c.isOverdue).length,
    highSeverity: allCapas.filter(c => c.severity === 'HIGH' || c.severity === 'CRITICAL').length,
  };

  res.json({ capas, summary, _source: 'mock' });
});

router.get('/incidents', (req, res) => {
  res.json({ incidents: mockIncidents, count: mockIncidents.length, _source: 'mock' });
});

router.get('/directions', (req, res) => {
  const now = new Date();
  const directions = mockDirections.map(d => ({
    ...d,
    isOverdue: d.status === 'OPEN' && new Date(d.compliance_date) < now,
    daysOverdue: d.status === 'OPEN' && new Date(d.compliance_date) < now
      ? Math.floor((now - new Date(d.compliance_date)) / (1000 * 60 * 60 * 24))
      : null,
  }));
  res.json({ directions, count: directions.length, _source: 'mock' });
});

router.get('/observations', (req, res) => {
  const limit = parseInt(req.query.limit) || 50;
  res.json({ observations: mockObservations.slice(0, limit), count: mockObservations.length, _source: 'mock' });
});

router.get('/mine', (req, res) => {
  res.json({ ...mockMine, _source: 'mock' });
});

export default router;