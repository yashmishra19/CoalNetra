-- Migration: 20260913000003_statutory_and_operational.sql
-- Description: Create statutory and operational tables with Rule A denormalized scope, Rule B provenance, Rule C maker-checker, Rule E offline-first timestamps

-- 1. Statutory Obligations
CREATE TABLE IF NOT EXISTS obligations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Statutory & Operational Fields
    title TEXT NOT NULL,
    description TEXT,
    frequency obligation_frequency_enum NOT NULL,
    owner_role user_role NOT NULL DEFAULT 'MINE_MANAGER',
    due_date TIMESTAMPTZ NOT NULL,
    status obligation_status_enum NOT NULL DEFAULT 'PENDING',
    cmr_2017_ref TEXT,
    oshwc_2020_ref TEXT,
    law_status law_status_enum NOT NULL DEFAULT 'BOTH_CITED',
    -- Rule B: Provenance
    provenance provenance_type NOT NULL DEFAULT 'OPERATOR_SEALED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Field Safety Observations (Rule E: Offline-First Client UUIDs & dual timestamps)
CREATE TABLE IF NOT EXISTS observations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Operational Fields
    section_id UUID NOT NULL REFERENCES sections(id) ON DELETE RESTRICT,
    reported_by UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    category TEXT NOT NULL,
    severity severity_level_enum NOT NULL,
    location GEOMETRY(Point, 4326),
    checkin_method checkin_method_enum NOT NULL,
    tag_scanned TEXT REFERENCES sections(tag_code) ON DELETE RESTRICT,
    device_id TEXT NOT NULL,
    client_created_at TIMESTAMPTZ NOT NULL,
    server_created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    location_valid BOOLEAN NOT NULL DEFAULT false,
    description TEXT NOT NULL,
    -- Rule B: Provenance
    provenance provenance_type NOT NULL DEFAULT 'OPERATOR_UNSEALED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Observation Photos (Subtable - Unbounded Photo Attachment Prevention)
CREATE TABLE IF NOT EXISTS observation_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    observation_id UUID NOT NULL REFERENCES observations(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    sha256_hash TEXT NOT NULL,
    captured_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Inspections
CREATE TABLE IF NOT EXISTS inspections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Operational Fields
    discipline inspection_discipline_enum NOT NULL,
    inspector_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    planned_date TIMESTAMPTZ NOT NULL,
    completed_date TIMESTAMPTZ,
    status inspection_status_enum NOT NULL DEFAULT 'PLANNED',
    findings TEXT,
    -- Rule B: Provenance
    provenance provenance_type NOT NULL DEFAULT 'INSPECTOR',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 5. Corrective and Preventive Actions (CAPAs) with Rule C Maker-Checker
CREATE TABLE IF NOT EXISTS capas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Operational Fields
    source_observation_id UUID REFERENCES observations(id) ON DELETE SET NULL,
    source_inspection_id UUID REFERENCES inspections(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    severity severity_level_enum NOT NULL,
    due_date TIMESTAMPTZ NOT NULL,
    status capa_status_enum NOT NULL DEFAULT 'OPEN',
    escalation_level INT NOT NULL DEFAULT 0,
    closed_by UUID REFERENCES public.users(id) ON DELETE RESTRICT,
    closed_at TIMESTAMPTZ,
    closure_notes TEXT,
    verified_by UUID REFERENCES public.users(id) ON DELETE RESTRICT,
    verified_at TIMESTAMPTZ,
    verification_notes TEXT,
    -- Rule B: Provenance
    provenance provenance_type NOT NULL DEFAULT 'OPERATOR_SEALED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    -- Rule C: Maker-Checker constraint (Enforce that closer and verifier cannot be the same person)
    CONSTRAINT check_capa_maker_checker CHECK (verified_by IS NULL OR verified_by <> closed_by)
);

-- 6. CAPA After Photos (Subtable)
CREATE TABLE IF NOT EXISTS capa_after_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    capa_id UUID NOT NULL REFERENCES capas(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    sha256_hash TEXT NOT NULL,
    captured_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. Incidents (Rule D: No named worker columns in this table)
CREATE TABLE IF NOT EXISTS incidents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Operational Fields
    incident_type incident_type_enum NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL,
    notified_phone_at TIMESTAMPTZ,
    written_notice_at TIMESTAMPTZ,
    within_24h_window BOOLEAN GENERATED ALWAYS AS (
        written_notice_at IS NOT NULL AND (timezone('UTC', written_notice_at) <= timezone('UTC', occurred_at) + INTERVAL '24 hours')
    ) STORED,
    description TEXT NOT NULL,
    location_description TEXT,
    -- Rule B: Provenance
    provenance provenance_type NOT NULL DEFAULT 'OPERATOR_SEALED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. Incident Worker Details (Rule D: Split table carrying PII, zero regulator policy)
CREATE TABLE IF NOT EXISTS incident_worker_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    incident_id UUID NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
    worker_name TEXT NOT NULL,
    worker_id_number TEXT NOT NULL,
    injury_description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 9. DGMS Regulator Directions
CREATE TABLE IF NOT EXISTS directions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issued_by UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    defect_category TEXT NOT NULL,
    enforcement_step enforcement_step_enum NOT NULL,
    compliance_date TIMESTAMPTZ NOT NULL,
    evidence_received BOOLEAN NOT NULL DEFAULT false,
    evidence_received_at TIMESTAMPTZ,
    status direction_status_enum NOT NULL DEFAULT 'ISSUED',
    issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 10. Direction Targets (Join table carrying each targeted mine's denorm scope)
CREATE TABLE IF NOT EXISTS direction_targets (
    direction_id UUID NOT NULL REFERENCES directions(id) ON DELETE CASCADE,
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE CASCADE,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (direction_id, mine_id)
);

-- 11. DGMS Prohibition Orders
CREATE TABLE IF NOT EXISTS prohibition_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Rule A: Denormalized Scope
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    mine_name TEXT NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    -- Operational Fields
    section_id UUID REFERENCES sections(id) ON DELETE SET NULL, -- NULL indicates whole mine
    scope prohibition_scope_enum NOT NULL DEFAULT 'WHOLE_MINE',
    ground TEXT NOT NULL,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    revocation_condition TEXT NOT NULL,
    revoked_at TIMESTAMPTZ,
    issued_by UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 12. Audit Logs (Immutable Append-Only Hash Chain)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    record_type TEXT NOT NULL,
    record_id UUID NOT NULL,
    action audit_action_enum NOT NULL,
    actor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    ts TIMESTAMPTZ NOT NULL DEFAULT now(),
    row_data JSONB NOT NULL,
    hash TEXT NOT NULL,
    prev_hash TEXT
);
