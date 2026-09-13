-- Migration: 20260913000004_denial_and_subtables.sql
-- Description: Create Rule-D internal denial tables with explicit architectural comments

/*
========================================================================================
RULE D ARCHITECTURAL BOUNDARY:
The following tables store internal operational, risk, attendance, and draft data.
Under Rule D:
- Regulators must receive ZERO RLS policy on internal risk scores, live production, attendance,
  named worker records, and draft inquiry records.
- In PostgreSQL RLS, absence of a policy defaults to DEFAULT DENY (access forbidden / 0 rows).
- Regulators only receive a SELECT policy on incident_inquiries when status = 'FINAL'.
========================================================================================
*/

-- 1. Mine Risk Scores (Internal proprietary algorithmic scoring - ZERO REGULATOR POLICY)
-- Comment: Contains internal operational risk indices and proprietary algorithmic breakdowns.
-- Access is restricted solely to Mine Managers and authorized internal safety engineers.
CREATE TABLE IF NOT EXISTS mine_risk_scores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Operational Risk Data
    score NUMERIC(5,2) NOT NULL,
    component_breakdown JSONB NOT NULL DEFAULT '{}'::jsonb,
    assessed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Production Logs (Live shift production metrics - ZERO REGULATOR POLICY)
-- Comment: Contains commercial and operational output (coal extraction tonnes, OB removal m3).
-- Regulators have statutory safety jurisdiction, not commercial oversight; access is strictly internal.
CREATE TABLE IF NOT EXISTS production_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Production Data
    shift_date DATE NOT NULL,
    shift TEXT NOT NULL CHECK (shift IN ('A', 'B', 'C')),
    coal_tonnes NUMERIC(10,2) NOT NULL,
    overburden_m3 NUMERIC(10,2) NOT NULL,
    recorded_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Attendance Logs (Shift gate biometric punches & worker status - ZERO REGULATOR POLICY)
-- Comment: Contains individual biometric attendance punches, gate-level access, and expired cert checks.
-- Regulators do not have access to individual worker roll calls; access is strictly internal.
CREATE TABLE IF NOT EXISTS attendance_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Attendance Data
    shift_date DATE NOT NULL,
    shift TEXT NOT NULL CHECK (shift IN ('A', 'B', 'C')),
    worker_id TEXT NOT NULL,
    gate_id TEXT NOT NULL,
    punch_time TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('PRESENT', 'STOPPED_EXPIRED_TRAINING', 'STOPPED_EXPIRED_MEDICAL')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Incident Inquiries (Internal investigation notes & root-cause findings)
-- Comment: Internal inquiry drafts (status = 'DRAFT') remain private to mine internal investigators.
-- Regulators are granted an RLS policy ONLY when status = 'FINAL'.
CREATE TABLE IF NOT EXISTS incident_inquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Inquiry Data
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    status inquiry_status_enum NOT NULL DEFAULT 'DRAFT',
    findings TEXT NOT NULL,
    recommendations TEXT,
    created_by UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    finalized_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
