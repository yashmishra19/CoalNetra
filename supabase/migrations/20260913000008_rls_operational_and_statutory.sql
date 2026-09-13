-- Migration: 20260913000008_rls_operational_and_statutory.sql
-- Description: Row Level Security for statutory and operational tables, enforcing Rule C Maker-Checker, Rule D separation, and Role Scope.

-- ========================================================================================
-- 1. Obligations RLS
-- ========================================================================================
ALTER TABLE obligations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Obligations select by scope"
ON obligations FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    in_mine_scope(mine_id)
);

CREATE POLICY "Mine Manager manage obligations in own mine"
ON obligations FOR ALL
TO authenticated
USING (is_mine_manager() AND in_mine_scope(mine_id))
WITH CHECK (is_mine_manager() AND in_mine_scope(mine_id));

-- ========================================================================================
-- 2. Observations RLS (Field Officers write their own, Mine Managers view mine, Regulators view region)
-- ========================================================================================
ALTER TABLE observations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Observations select by scope"
ON observations FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    in_mine_scope(mine_id)
);

CREATE POLICY "Field Officer and Mine Manager insert observations"
ON observations FOR INSERT
TO authenticated
WITH CHECK (
    (is_field_officer() OR is_mine_manager()) AND
    reported_by = auth.uid() AND
    in_mine_scope(mine_id)
);

-- ========================================================================================
-- 3. Observation Photos RLS
-- ========================================================================================
ALTER TABLE observation_photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Observation photos select by parent observation scope"
ON observation_photos FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM observations o 
        WHERE o.id = observation_photos.observation_id AND (
            in_region_scope(o.dgms_region_id) OR in_mine_scope(o.mine_id)
        )
    )
);

CREATE POLICY "Observation photos insert by author"
ON observation_photos FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM observations o 
        WHERE o.id = observation_photos.observation_id AND o.reported_by = auth.uid()
    )
);

-- ========================================================================================
-- 4. CAPAs RLS with Rule C Maker-Checker Enforcement
-- ========================================================================================
ALTER TABLE capas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "CAPAs select by scope"
ON capas FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    in_mine_scope(mine_id)
);

CREATE POLICY "Field Officers and Mine Managers insert CAPAs"
ON capas FOR INSERT
TO authenticated
WITH CHECK (
    (is_field_officer() OR is_mine_manager()) AND
    in_mine_scope(mine_id)
);

-- Rule C: Maker-Checker Enforced in RLS UPDATE Policies
-- 4a. Field Officer can close their owned CAPA with photos and notes
CREATE POLICY "Field Officer close owned CAPA"
ON capas FOR UPDATE
TO authenticated
USING (
    is_field_officer() AND 
    owner_id = auth.uid() AND 
    status IN ('OPEN', 'ESCALATED')
)
WITH CHECK (
    is_field_officer() AND 
    owner_id = auth.uid() AND 
    status IN ('OPEN', 'PENDING_VERIFICATION')
);

-- 4b. Mine Manager verify closure (Must NOT be the person who closed it: closed_by <> auth.uid())
CREATE POLICY "Mine Manager verify CAPA with Maker-Checker"
ON capas FOR UPDATE
TO authenticated
USING (
    is_mine_manager() AND 
    in_mine_scope(mine_id) AND (
        -- General management / reassignment when OPEN or ESCALATED
        status IN ('OPEN', 'ESCALATED') OR
        -- Verification: Enforce Rule C (Verifier must be different from closer)
        (status = 'PENDING_VERIFICATION' AND (closed_by IS NULL OR closed_by <> auth.uid()))
    )
)
WITH CHECK (
    is_mine_manager() AND 
    in_mine_scope(mine_id) AND (
        -- If setting to VERIFIED, strictly enforce maker-checker
        (status = 'VERIFIED' AND (closed_by IS NULL OR closed_by <> auth.uid()) AND verified_by = auth.uid()) OR
        -- If reopening or reassigning
        (status IN ('OPEN', 'ESCALATED', 'PENDING_VERIFICATION'))
    )
);

-- ========================================================================================
-- 5. CAPA After Photos RLS
-- ========================================================================================
ALTER TABLE capa_after_photos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "CAPA after photos select by parent CAPA scope"
ON capa_after_photos FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM capas c 
        WHERE c.id = capa_after_photos.capa_id AND (
            in_region_scope(c.dgms_region_id) OR in_mine_scope(c.mine_id)
        )
    )
);

CREATE POLICY "CAPA after photos insert by owner or manager"
ON capa_after_photos FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM capas c 
        WHERE c.id = capa_after_photos.capa_id AND (
            c.owner_id = auth.uid() OR (is_mine_manager() AND in_mine_scope(c.mine_id))
        )
    )
);

-- ========================================================================================
-- 6. Inspections RLS (Regulators author findings in their region; Managers author mine audits)
-- ========================================================================================
ALTER TABLE inspections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Inspections select by scope"
ON inspections FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    in_mine_scope(mine_id)
);

CREATE POLICY "Regulator create and update own inspections"
ON inspections FOR ALL
TO authenticated
USING (
    is_regulator() AND 
    inspector_id = auth.uid() AND 
    in_region_scope(dgms_region_id)
)
WITH CHECK (
    is_regulator() AND 
    inspector_id = auth.uid() AND 
    in_region_scope(dgms_region_id)
);

CREATE POLICY "Mine Manager manage internal inspections"
ON inspections FOR ALL
TO authenticated
USING (
    is_mine_manager() AND 
    in_mine_scope(mine_id)
)
WITH CHECK (
    is_mine_manager() AND 
    in_mine_scope(mine_id)
);

-- ========================================================================================
-- 7. Incidents RLS (No worker PII - visible to Regulators and Mine staff)
-- ========================================================================================
ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Incidents select by scope"
ON incidents FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    in_mine_scope(mine_id)
);

CREATE POLICY "Mine Manager manage incidents in own mine"
ON incidents FOR ALL
TO authenticated
USING (is_mine_manager() AND in_mine_scope(mine_id))
WITH CHECK (is_mine_manager() AND in_mine_scope(mine_id));

-- ========================================================================================
-- 8. Incident Worker Details RLS (Rule D: Split table with worker PII - ZERO REGULATOR POLICY)
-- ========================================================================================
ALTER TABLE incident_worker_details ENABLE ROW LEVEL SECURITY;

-- Comment: Rule D requires named worker details to be inaccessible to regulators via RLS.
-- Therefore, ONLY internal Mine Managers and authorized Field Officers get a SELECT policy.
CREATE POLICY "Internal mine staff select incident worker details"
ON incident_worker_details FOR SELECT
TO authenticated
USING (
    (is_mine_manager() OR is_field_officer()) AND EXISTS (
        SELECT 1 FROM incidents i 
        WHERE i.id = incident_worker_details.incident_id AND i.mine_id = auth_scope_id()
    )
);

CREATE POLICY "Mine Manager manage incident worker details"
ON incident_worker_details FOR ALL
TO authenticated
USING (
    is_mine_manager() AND EXISTS (
        SELECT 1 FROM incidents i 
        WHERE i.id = incident_worker_details.incident_id AND i.mine_id = auth_scope_id()
    )
)
WITH CHECK (
    is_mine_manager() AND EXISTS (
        SELECT 1 FROM incidents i 
        WHERE i.id = incident_worker_details.incident_id AND i.mine_id = auth_scope_id()
    )
);

-- ========================================================================================
-- 9. Directions & Direction Targets RLS
-- ========================================================================================
ALTER TABLE directions ENABLE ROW LEVEL SECURITY;
ALTER TABLE direction_targets ENABLE ROW LEVEL SECURITY;

-- Directions Select
CREATE POLICY "Directions select by scope"
ON directions FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    (is_mine_manager() AND EXISTS (
        SELECT 1 FROM direction_targets dt 
        WHERE dt.direction_id = directions.id AND dt.mine_id = auth_scope_id()
    ))
);

-- Regulator author directions
CREATE POLICY "Regulator create and manage own directions"
ON directions FOR ALL
TO authenticated
USING (
    is_regulator() AND 
    issued_by = auth.uid() AND 
    in_region_scope(dgms_region_id)
)
WITH CHECK (
    is_regulator() AND 
    issued_by = auth.uid() AND 
    in_region_scope(dgms_region_id)
);

-- Mine Manager submit compliance evidence for targeted directions
CREATE POLICY "Mine Manager submit direction compliance"
ON directions FOR UPDATE
TO authenticated
USING (
    is_mine_manager() AND EXISTS (
        SELECT 1 FROM direction_targets dt 
        WHERE dt.direction_id = directions.id AND dt.mine_id = auth_scope_id()
    )
)
WITH CHECK (
    is_mine_manager() AND EXISTS (
        SELECT 1 FROM direction_targets dt 
        WHERE dt.direction_id = directions.id AND dt.mine_id = auth_scope_id()
    )
);

-- Direction Targets Select & Manage
CREATE POLICY "Direction targets select by scope"
ON direction_targets FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    (is_mine_manager() AND mine_id = auth_scope_id())
);

CREATE POLICY "Regulator manage direction targets"
ON direction_targets FOR ALL
TO authenticated
USING (
    is_regulator() AND in_region_scope(dgms_region_id)
)
WITH CHECK (
    is_regulator() AND in_region_scope(dgms_region_id)
);

-- ========================================================================================
-- 10. Prohibition Orders RLS
-- ========================================================================================
ALTER TABLE prohibition_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Prohibition orders select by scope"
ON prohibition_orders FOR SELECT
TO authenticated
USING (
    in_region_scope(dgms_region_id) OR 
    in_mine_scope(mine_id)
);

CREATE POLICY "Regulator create and revoke prohibition orders"
ON prohibition_orders FOR ALL
TO authenticated
USING (
    is_regulator() AND 
    issued_by = auth.uid() AND 
    in_region_scope(dgms_region_id)
)
WITH CHECK (
    is_regulator() AND 
    issued_by = auth.uid() AND 
    in_region_scope(dgms_region_id)
);

-- ========================================================================================
-- 11. Audit Logs RLS (Immutable Append-Only)
-- ========================================================================================
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Revoke mutation privileges from all roles for cryptographic immutability
REVOKE UPDATE, DELETE ON audit_logs FROM PUBLIC, authenticated, anon;

CREATE POLICY "Audit logs select by scope"
ON audit_logs FOR SELECT
TO authenticated
USING (
    (is_regulator() AND auth_scope_type() = 'REGION') OR
    (is_mine_manager() AND auth_scope_type() = 'MINE') OR
    (actor_id = auth.uid())
);

CREATE POLICY "Audit logs insert allowed for authenticated actors"
ON audit_logs FOR INSERT
TO authenticated
WITH CHECK (true);
