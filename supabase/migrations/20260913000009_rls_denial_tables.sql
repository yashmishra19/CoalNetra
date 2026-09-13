-- Migration: 20260913000009_rls_denial_tables.sql
-- Description: Row Level Security for Rule-D Denial Tables (Zero Policy verification for Regulators)

/*
========================================================================================
RULE D VERIFICATION & ARCHITECTURAL COMMENTARY:
1. Under PostgreSQL Row Level Security (RLS), when RLS is enabled on a table, all access
   is DENIED by default unless an explicit policy permits it.
2. For the following tables:
   - mine_risk_scores
   - production_logs
   - attendance_logs
   - incident_worker_details (defined in 20260913000008_rls_operational_and_statutory.sql)
   REGULATORS RECEIVE ZERO POLICIES. Any query by a user with role 'REGULATOR' will
   return 0 rows or permission denied, enforcing a cryptographic and database-level boundary.
3. For incident_inquiries:
   - REGULATORS receive a policy strictly bounded by status = 'FINAL' and their dgms_region_id.
   - Internal 'DRAFT' inquiries have NO policy for regulators.
========================================================================================
*/

-- ========================================================================================
-- 1. Mine Risk Scores RLS (Internal Algorithm / Indices - ZERO REGULATOR POLICY)
-- ========================================================================================
ALTER TABLE mine_risk_scores ENABLE ROW LEVEL SECURITY;

-- Comment: Mine Managers and authorized mine internal personnel may read and manage internal risk scores.
-- Regulators are granted ZERO policies on this table.
CREATE POLICY "Mine Manager manage mine risk scores"
ON mine_risk_scores FOR ALL
TO authenticated
USING (is_mine_manager() AND in_mine_scope(mine_id))
WITH CHECK (is_mine_manager() AND in_mine_scope(mine_id));

-- ========================================================================================
-- 2. Production Logs RLS (Live Shift Commercial Extraction - ZERO REGULATOR POLICY)
-- ========================================================================================
ALTER TABLE production_logs ENABLE ROW LEVEL SECURITY;

-- Comment: Mine Managers and dispatchers record and monitor commercial extraction volumes.
-- Regulators have statutory safety authority, not commercial oversight; ZERO policies granted.
CREATE POLICY "Mine Manager manage production logs"
ON production_logs FOR ALL
TO authenticated
USING (is_mine_manager() AND in_mine_scope(mine_id))
WITH CHECK (is_mine_manager() AND in_mine_scope(mine_id));

-- ========================================================================================
-- 3. Attendance Logs RLS (Worker Gate Biometric Roll Call - ZERO REGULATOR POLICY)
-- ========================================================================================
ALTER TABLE attendance_logs ENABLE ROW LEVEL SECURITY;

-- Comment: Mine Managers and gate controllers monitor worker entry and medical/training validity.
-- Individual worker gate roll calls are internal operational data; ZERO policies granted to regulators.
CREATE POLICY "Mine Manager manage attendance logs"
ON attendance_logs FOR ALL
TO authenticated
USING (is_mine_manager() AND in_mine_scope(mine_id))
WITH CHECK (is_mine_manager() AND in_mine_scope(mine_id));

-- ========================================================================================
-- 4. Incident Inquiries RLS (Drafts are Internal; Regulators read FINAL only)
-- ========================================================================================
ALTER TABLE incident_inquiries ENABLE ROW LEVEL SECURITY;

-- 4a. Mine Manager access to all inquiries (DRAFT and FINAL) within their mine
CREATE POLICY "Mine Manager manage incident inquiries"
ON incident_inquiries FOR ALL
TO authenticated
USING (is_mine_manager() AND in_mine_scope(mine_id))
WITH CHECK (is_mine_manager() AND in_mine_scope(mine_id));

-- 4b. Regulator access strictly limited to FINALIZED inquiries within their region
-- Comment: Regulators have zero access to DRAFT inquiries; only finalized statutory inquiries are visible.
CREATE POLICY "Regulator read finalized incident inquiries"
ON incident_inquiries FOR SELECT
TO authenticated
USING (
    is_regulator() AND 
    status = 'FINAL' AND 
    in_region_scope(dgms_region_id)
);
