-- Migration: 20260913000010_triggers_and_functions.sql
-- Description: Core statutory triggers and functions (Scope fan-out, PostGIS geofence, CAPA SLA due dates, Audit hash chain, Auth app_metadata sync)

-- ========================================================================================
-- 1. Scope Fan-out Trigger
-- When a mine's hierarchy or name changes, propagate the denormalized scope to all downstream tables.
-- ========================================================================================
CREATE OR REPLACE FUNCTION sync_mine_hierarchy_fanout()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.area_id <> NEW.area_id OR 
        OLD.subsidiary_id <> NEW.subsidiary_id OR 
        OLD.district_id <> NEW.district_id OR 
        OLD.dgms_region_id <> NEW.dgms_region_id OR 
        OLD.name <> NEW.name) THEN

        -- Obligations
        UPDATE obligations SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id, updated_at = now()
        WHERE mine_id = NEW.id;

        -- Observations
        UPDATE observations SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id
        WHERE mine_id = NEW.id;

        -- CAPAs
        UPDATE capas SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id, updated_at = now()
        WHERE mine_id = NEW.id;

        -- Inspections
        UPDATE inspections SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id, updated_at = now()
        WHERE mine_id = NEW.id;

        -- Incidents
        UPDATE incidents SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id, updated_at = now()
        WHERE mine_id = NEW.id;

        -- Direction Targets
        UPDATE direction_targets SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id
        WHERE mine_id = NEW.id;

        -- Prohibition Orders
        UPDATE prohibition_orders SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id, updated_at = now()
        WHERE mine_id = NEW.id;

        -- Denial Tables (Rule D)
        UPDATE mine_risk_scores SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id
        WHERE mine_id = NEW.id;

        UPDATE production_logs SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id
        WHERE mine_id = NEW.id;

        UPDATE attendance_logs SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id
        WHERE mine_id = NEW.id;

        UPDATE incident_inquiries SET 
            mine_name = NEW.name, area_id = NEW.area_id, subsidiary_id = NEW.subsidiary_id,
            district_id = NEW.district_id, dgms_region_id = NEW.dgms_region_id, updated_at = now()
        WHERE mine_id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_mine_hierarchy_fanout ON mines;
CREATE TRIGGER trg_sync_mine_hierarchy_fanout
AFTER UPDATE OF area_id, subsidiary_id, district_id, dgms_region_id, name ON mines
FOR EACH ROW EXECUTE FUNCTION sync_mine_hierarchy_fanout();

-- ========================================================================================
-- 2. PostGIS Geofence & Auto-Scope Trigger on Observations
-- Validates presence via lease boundary polygon or QR/NFC tag verification
-- ========================================================================================
CREATE OR REPLACE FUNCTION process_observation_checkin()
RETURNS TRIGGER AS $$
DECLARE
    v_lease_boundary GEOMETRY;
    v_mine RECORD;
BEGIN
    -- Auto-fetch mine hierarchy if missing or verify consistency
    SELECT m.name, m.area_id, m.subsidiary_id, m.district_id, m.dgms_region_id, m.lease_boundary
    INTO v_mine
    FROM mines m WHERE m.id = NEW.mine_id;

    IF FOUND THEN
        NEW.mine_name := v_mine.name;
        NEW.area_id := v_mine.area_id;
        NEW.subsidiary_id := v_mine.subsidiary_id;
        NEW.district_id := v_mine.district_id;
        NEW.dgms_region_id := v_mine.dgms_region_id;
        v_lease_boundary := v_mine.lease_boundary;
    END IF;

    -- Physical tag check-in (underground or offline): defaults location_valid = true
    IF NEW.checkin_method IN ('QR', 'NFC') THEN
        NEW.location_valid := true;
    -- GPS check-in: verifies spatial containment within mine lease polygon
    ELSIF NEW.checkin_method = 'GPS' AND NEW.location IS NOT NULL AND v_lease_boundary IS NOT NULL THEN
        NEW.location_valid := ST_Contains(v_lease_boundary, NEW.location);
    ELSE
        NEW.location_valid := false;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_process_observation_checkin ON observations;
CREATE TRIGGER trg_process_observation_checkin
BEFORE INSERT ON observations
FOR EACH ROW EXECUTE FUNCTION process_observation_checkin();

-- ========================================================================================
-- 3. CAPA SLA Auto-Due Date & Auto-Scope Trigger
-- Critical +24h, High +3d, Medium +7d, Low +15d
-- ========================================================================================
CREATE OR REPLACE FUNCTION process_capa_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_mine RECORD;
BEGIN
    -- Auto-populate scope from mine if not supplied
    SELECT m.name, m.area_id, m.subsidiary_id, m.district_id, m.dgms_region_id
    INTO v_mine
    FROM mines m WHERE m.id = NEW.mine_id;

    IF FOUND THEN
        NEW.mine_name := v_mine.name;
        NEW.area_id := v_mine.area_id;
        NEW.subsidiary_id := v_mine.subsidiary_id;
        NEW.district_id := v_mine.district_id;
        NEW.dgms_region_id := v_mine.dgms_region_id;
    END IF;

    -- Auto-calculate statutory SLA due date based on severity
    IF NEW.due_date IS NULL THEN
        CASE NEW.severity
            WHEN 'CRITICAL' THEN NEW.due_date := now() + INTERVAL '24 hours';
            WHEN 'HIGH'     THEN NEW.due_date := now() + INTERVAL '3 days';
            WHEN 'MEDIUM'   THEN NEW.due_date := now() + INTERVAL '7 days';
            WHEN 'LOW'      THEN NEW.due_date := now() + INTERVAL '15 days';
            ELSE                 NEW.due_date := now() + INTERVAL '7 days';
        END CASE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_process_capa_insert ON capas;
CREATE TRIGGER trg_process_capa_insert
BEFORE INSERT ON capas
FOR EACH ROW EXECUTE FUNCTION process_capa_insert();

-- ========================================================================================
-- 4. Audit Hash-Chain Trigger
-- Computes cryptographic SHA-256 hash of every modified row and links to previous hash.
-- ========================================================================================
CREATE OR REPLACE FUNCTION audit_hash_chain_logger()
RETURNS TRIGGER AS $$
DECLARE
    v_record_id UUID;
    v_record_type TEXT;
    v_action audit_action_enum;
    v_row_json JSONB;
    v_prev_hash TEXT;
    v_current_hash TEXT;
    v_actor_id UUID;
BEGIN
    v_record_id := NEW.id;
    v_record_type := TG_TABLE_NAME;
    v_row_json := to_jsonb(NEW);
    v_actor_id := auth.uid();

    IF TG_OP = 'INSERT' THEN
        v_action := 'CREATE';
    ELSIF TG_OP = 'UPDATE' THEN
        IF TG_TABLE_NAME = 'capas' AND NEW.status = 'VERIFIED' AND OLD.status <> 'VERIFIED' THEN
            v_action := 'VERIFY';
        ELSIF TG_TABLE_NAME = 'capas' AND NEW.status = 'PENDING_VERIFICATION' AND OLD.status <> 'PENDING_VERIFICATION' THEN
            v_action := 'CLOSE';
        ELSIF TG_TABLE_NAME = 'prohibition_orders' AND NEW.revoked_at IS NOT NULL AND OLD.revoked_at IS NULL THEN
            v_action := 'REVOKE';
        ELSE
            v_action := 'UPDATE';
        END IF;
    END IF;

    -- Lookup previous hash for this specific record_id
    SELECT hash INTO v_prev_hash
    FROM audit_logs
    WHERE record_id = v_record_id
    ORDER BY ts DESC
    LIMIT 1;

    -- Compute SHA-256 hash of (NEW row JSON string + prev_hash)
    v_current_hash := encode(digest(v_row_json::text || COALESCE(v_prev_hash, 'GENESIS'), 'sha256'), 'hex');

    -- Insert into immutable append-only audit log
    INSERT INTO audit_logs (record_type, record_id, action, actor_id, ts, row_data, hash, prev_hash)
    VALUES (v_record_type, v_record_id, v_action, v_actor_id, now(), v_row_json, v_current_hash, v_prev_hash);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Attach Audit Hash Chain Triggers to All Auditable Tables
DROP TRIGGER IF EXISTS trg_audit_obligations ON obligations;
CREATE TRIGGER trg_audit_obligations AFTER INSERT OR UPDATE ON obligations FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

DROP TRIGGER IF EXISTS trg_audit_observations ON observations;
CREATE TRIGGER trg_audit_observations AFTER INSERT OR UPDATE ON observations FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

DROP TRIGGER IF EXISTS trg_audit_capas ON capas;
CREATE TRIGGER trg_audit_capas AFTER INSERT OR UPDATE ON capas FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

DROP TRIGGER IF EXISTS trg_audit_inspections ON inspections;
CREATE TRIGGER trg_audit_inspections AFTER INSERT OR UPDATE ON inspections FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

DROP TRIGGER IF EXISTS trg_audit_incidents ON incidents;
CREATE TRIGGER trg_audit_incidents AFTER INSERT OR UPDATE ON incidents FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

DROP TRIGGER IF EXISTS trg_audit_directions ON directions;
CREATE TRIGGER trg_audit_directions AFTER INSERT OR UPDATE ON directions FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

DROP TRIGGER IF EXISTS trg_audit_prohibition_orders ON prohibition_orders;
CREATE TRIGGER trg_audit_prohibition_orders AFTER INSERT OR UPDATE ON prohibition_orders FOR EACH ROW EXECUTE FUNCTION audit_hash_chain_logger();

-- ========================================================================================
-- 5. Supabase Auth App Metadata Synchronizer
-- Synchronizes role, scope_type, and scope_id to auth.users.raw_app_meta_data
-- ========================================================================================
CREATE OR REPLACE FUNCTION sync_user_auth_app_metadata()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE auth.users
    SET raw_app_meta_data = COALESCE(raw_app_meta_data, '{}'::jsonb) || jsonb_build_object(
        'role', NEW.role,
        'scope_type', NEW.scope_type,
        'scope_id', NEW.scope_id
    )
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trg_sync_user_auth_app_metadata ON public.users;
CREATE TRIGGER trg_sync_user_auth_app_metadata
AFTER INSERT OR UPDATE OF role, scope_type, scope_id ON public.users
FOR EACH ROW EXECUTE FUNCTION sync_user_auth_app_metadata();
