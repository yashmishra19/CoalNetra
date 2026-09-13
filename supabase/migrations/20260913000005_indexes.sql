-- Migration: 20260913000005_indexes.sql
-- Description: Indexes supporting per-role query patterns, spatial queries, hash chains, and partial sweeps.
-- Includes architectural notes on 10x scale bottlenecks and mitigation paths.

/*
========================================================================================
SCALE TARGET & ARCHITECTURAL 10X FLAGS:
- Current Target: ~50 mines, 500 field users, 5,000 records/day.
- 10x Scale Target: 500 mines, 5,000 field users, 50,000 records/day.

10X SCALE BREAKDOWN POINTS & MITIGATION:
1. CAPA Escalation Sweep:
   - Current: pg_cron scans `capas` where status='OPEN' every 15 mins.
   - At 10x: 50,000 open/in-progress items across 500 mines will lock rows during bulk update.
   - Mitigation: Use keyset pagination in batch sizes of 500, or a distributed task queue (e.g. PgBouncer + worker jobs).
2. Materialized View Refresh Cadence:
   - Current: `REFRESH MATERIALIZED VIEW CONCURRENTLY` every 5 mins.
   - At 10x: Concurrently refreshing full aggregate views causes sustained disk I/O and CPU spikes.
   - Mitigation: Transition to trigger-based incremental summary tables or timescale rollups.
3. Audit Log Growth:
   - Current: Single append-only `audit_logs` table.
   - At 10x: ~150,000 audit entries/day (4.5M rows/month).
   - Mitigation: Declarative range partitioning on `audit_logs` by `ts` (monthly partitions) with cold storage archiving.
========================================================================================
*/

-- 1. Partial Index for CAPA Escalation Sweep
CREATE INDEX IF NOT EXISTS idx_capas_open_due_date 
ON capas (due_date) 
WHERE status = 'OPEN';

-- 2. Audit Log Hash-Chain Fast Lookup Index
CREATE INDEX IF NOT EXISTS idx_audit_logs_chain 
ON audit_logs (record_id, ts DESC);

-- 3. PostGIS Spatial Indexes (GIST)
CREATE INDEX IF NOT EXISTS idx_mines_lease_boundary 
ON mines USING GIST (lease_boundary);

CREATE INDEX IF NOT EXISTS idx_observations_location 
ON observations USING GIST (location);

CREATE INDEX IF NOT EXISTS idx_sections_location 
ON sections USING GIST (location) 
WHERE location IS NOT NULL;

-- 4. Scope-Column Indexes (Rule A Denormalized Queries)
-- Obligations
CREATE INDEX IF NOT EXISTS idx_obligations_mine_status_due ON obligations (mine_id, status, due_date);
CREATE INDEX IF NOT EXISTS idx_obligations_dgms_region ON obligations (dgms_region_id);
CREATE INDEX IF NOT EXISTS idx_obligations_district ON obligations (district_id);

-- Observations
CREATE INDEX IF NOT EXISTS idx_observations_mine_severity_created ON observations (mine_id, severity, server_created_at DESC);
CREATE INDEX IF NOT EXISTS idx_observations_dgms_region ON observations (dgms_region_id);
CREATE INDEX IF NOT EXISTS idx_observations_device_reconnect ON observations (device_id, server_created_at);
CREATE INDEX IF NOT EXISTS idx_observations_reported_by ON observations (reported_by);

-- CAPAs
CREATE INDEX IF NOT EXISTS idx_capas_owner_status_due ON capas (owner_id, status, due_date);
CREATE INDEX IF NOT EXISTS idx_capas_mine_status_escalation ON capas (mine_id, status, escalation_level DESC);
CREATE INDEX IF NOT EXISTS idx_capas_dgms_region ON capas (dgms_region_id);

-- Inspections
CREATE INDEX IF NOT EXISTS idx_inspections_inspector ON inspections (inspector_id, planned_date DESC);
CREATE INDEX IF NOT EXISTS idx_inspections_mine ON inspections (mine_id, status);
CREATE INDEX IF NOT EXISTS idx_inspections_dgms_region ON inspections (dgms_region_id);

-- Incidents
CREATE INDEX IF NOT EXISTS idx_incidents_region_type_occurred ON incidents (dgms_region_id, incident_type, occurred_at DESC);
CREATE INDEX IF NOT EXISTS idx_incidents_mine ON incidents (mine_id, occurred_at DESC);

-- Directions & Targets
CREATE INDEX IF NOT EXISTS idx_directions_issued_by_status ON directions (issued_by, status);
CREATE INDEX IF NOT EXISTS idx_directions_region ON directions (dgms_region_id, status);
CREATE INDEX IF NOT EXISTS idx_direction_targets_mine ON direction_targets (mine_id);

-- Prohibition Orders
CREATE INDEX IF NOT EXISTS idx_prohibition_orders_mine ON prohibition_orders (mine_id, issued_at DESC);
CREATE INDEX IF NOT EXISTS idx_prohibition_orders_region ON prohibition_orders (dgms_region_id, issued_at DESC);

-- Sections & Hierarchy
CREATE INDEX IF NOT EXISTS idx_sections_mine ON sections (mine_id);
CREATE INDEX IF NOT EXISTS idx_mines_region ON mines (dgms_region_id);
CREATE INDEX IF NOT EXISTS idx_mines_area ON mines (area_id);
CREATE INDEX IF NOT EXISTS idx_mines_subsidiary ON mines (subsidiary_id);
CREATE INDEX IF NOT EXISTS idx_districts_region ON districts (dgms_region_id);
CREATE INDEX IF NOT EXISTS idx_areas_subsidiary ON areas (subsidiary_id);

-- Denial Tables Indexes (Internal fast queries)
CREATE INDEX IF NOT EXISTS idx_mine_risk_scores_mine ON mine_risk_scores (mine_id, assessed_at DESC);
CREATE INDEX IF NOT EXISTS idx_production_logs_mine_shift ON production_logs (mine_id, shift_date DESC, shift);
CREATE INDEX IF NOT EXISTS idx_attendance_logs_mine_shift ON attendance_logs (mine_id, shift_date DESC, shift);
CREATE INDEX IF NOT EXISTS idx_incident_inquiries_incident_status ON incident_inquiries (incident_id, status);
