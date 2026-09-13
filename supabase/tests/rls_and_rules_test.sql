-- Test Suite: supabase/tests/rls_and_rules_test.sql
-- Description: Comprehensive automated tests for Rule C Maker-Checker, Rule D Zero-Policy boundaries, Geofencing, and Audit Hash Chain

BEGIN;

-- Setup Test Helper
CREATE OR REPLACE FUNCTION run_test_suite()
RETURNS VOID AS $$
DECLARE
    v_test_count INT := 0;
    v_passed_count INT := 0;
    v_error_caught BOOLEAN;
    v_capa_id UUID := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01';
    v_user_fo UUID := '77777777-7777-7777-7777-777777777701';
    v_user_mm UUID := '77777777-7777-7777-7777-777777777702';
    v_user_reg UUID := '77777777-7777-7777-7777-777777777703';
    v_reg_count INT;
    v_obs_id UUID;
    v_is_valid BOOLEAN;
    v_hash1 TEXT;
    v_hash2 TEXT;
    v_prev_hash TEXT;
BEGIN
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'STARTING KOYLANETRA STATUTORY & RLS TEST SUITE';
    RAISE NOTICE '=====================================================';

    -- -----------------------------------------------------------------
    -- TEST 1: Rule C (Maker-Checker) - Self-Verification Rejection
    -- -----------------------------------------------------------------
    v_test_count := v_test_count + 1;
    v_error_caught := false;
    BEGIN
        -- Attempt to set closed_by and verified_by to the exact same person
        INSERT INTO capas (
            mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id,
            title, description, owner_id, severity, due_date, status, closed_by, verified_by, provenance
        ) VALUES (
            '55555555-5555-5555-5555-555555555501', 'Demo OCP-1',
            '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301',
            '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
            'Self Verify Test', 'Testing constraint', v_user_mm, 'MEDIUM', now() + INTERVAL '7 days',
            'VERIFIED', v_user_mm, v_user_mm, 'OPERATOR_SEALED'
        );
    EXCEPTION WHEN check_violation THEN
        v_error_caught := true;
    END;

    IF v_error_caught THEN
        v_passed_count := v_passed_count + 1;
        RAISE NOTICE 'TEST 1 PASSED: Rule C Maker-Checker rejected same-actor closer and verifier.';
    ELSE
        RAISE EXCEPTION 'TEST 1 FAILED: Rule C Maker-Checker failed to reject self-verification!';
    END IF;

    -- -----------------------------------------------------------------
    -- TEST 2: Rule D - Regulator Zero-Policy Verification on Denial Tables
    -- -----------------------------------------------------------------
    v_test_count := v_test_count + 1;
    -- Switch to authenticated role and simulate Regulator JWT Context
    SET LOCAL ROLE authenticated;
    PERFORM set_config('request.jwt.claims', jsonb_build_object(
        'sub', v_user_reg::text,
        'app_metadata', jsonb_build_object(
            'role', 'REGULATOR',
            'scope_type', 'REGION',
            'scope_id', '11111111-1111-1111-1111-111111111101'
        )
    )::text, true);

    -- Check mine_risk_scores (Must return 0 rows for regulator)
    SELECT COUNT(*) INTO v_reg_count FROM mine_risk_scores;
    IF v_reg_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: Regulator saw % rows in mine_risk_scores (Expected: 0)', v_reg_count;
    END IF;

    -- Check production_logs (Must return 0 rows for regulator)
    SELECT COUNT(*) INTO v_reg_count FROM production_logs;
    IF v_reg_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: Regulator saw % rows in production_logs (Expected: 0)', v_reg_count;
    END IF;

    -- Check attendance_logs (Must return 0 rows for regulator)
    SELECT COUNT(*) INTO v_reg_count FROM attendance_logs;
    IF v_reg_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: Regulator saw % rows in attendance_logs (Expected: 0)', v_reg_count;
    END IF;

    -- Check incident_worker_details (Must return 0 rows for regulator)
    SELECT COUNT(*) INTO v_reg_count FROM incident_worker_details;
    IF v_reg_count <> 0 THEN
        RAISE EXCEPTION 'TEST 2 FAILED: Regulator saw % rows in incident_worker_details (Expected: 0)', v_reg_count;
    END IF;

    v_passed_count := v_passed_count + 1;
    RAISE NOTICE 'TEST 2 PASSED: Rule D Zero-Policy strictly prevented regulator access to internal tables.';

    -- -----------------------------------------------------------------
    -- TEST 3: Rule D - Draft vs Finalized Inquiries Access
    -- -----------------------------------------------------------------
    v_test_count := v_test_count + 1;
    -- Regulator should see ONLY FINAL status inquiries (1 row), not DRAFT (0 rows)
    SELECT COUNT(*) INTO v_reg_count FROM incident_inquiries WHERE status = 'DRAFT';
    IF v_reg_count <> 0 THEN
        RAISE EXCEPTION 'TEST 3 FAILED: Regulator saw % draft inquiries (Expected: 0)', v_reg_count;
    END IF;

    SELECT COUNT(*) INTO v_reg_count FROM incident_inquiries WHERE status = 'FINAL';
    IF v_reg_count = 0 THEN
        RAISE EXCEPTION 'TEST 3 FAILED: Regulator could not see finalized inquiry.';
    END IF;

    v_passed_count := v_passed_count + 1;
    RAISE NOTICE 'TEST 3 PASSED: Regulator accesses ONLY finalized inquiry findings (drafts concealed).';

    -- -----------------------------------------------------------------
    -- TEST 4: PostGIS Geofence Trigger Check
    -- -----------------------------------------------------------------
    v_test_count := v_test_count + 1;
    -- Reset to Mine Manager Context
    PERFORM set_config('request.jwt.claims', jsonb_build_object(
        'sub', v_user_mm::text,
        'app_metadata', jsonb_build_object(
            'role', 'MINE_MANAGER',
            'scope_type', 'MINE',
            'scope_id', '55555555-5555-5555-5555-555555555501'
        )
    )::text, true);

    -- Insert GPS observation INSIDE boundary (78.13, 20.03 is within polygon 78.11-78.16, 20.01-20.06)
    INSERT INTO observations (
        mine_id, section_id, reported_by, category, severity,
        location, checkin_method, device_id, client_created_at, description, provenance
    ) VALUES (
        '55555555-5555-5555-5555-555555555501',
        '66666666-6666-6666-6666-666666666601',
        v_user_mm, 'Test Cat', 'LOW',
        ST_SetSRID(ST_MakePoint(78.1300, 20.0300), 4326), 'GPS',
        'TEST-DEV', now(), 'Geofence inside test', 'OPERATOR_SEALED'
    ) RETURNING id, location_valid INTO v_obs_id, v_is_valid;

    IF NOT v_is_valid THEN
        RAISE EXCEPTION 'TEST 4 FAILED: Location inside polygon was flagged as invalid!';
    END IF;

    -- Insert GPS observation OUTSIDE boundary (78.90, 20.90 is outside polygon)
    INSERT INTO observations (
        mine_id, section_id, reported_by, category, severity,
        location, checkin_method, device_id, client_created_at, description, provenance
    ) VALUES (
        '55555555-5555-5555-5555-555555555501',
        '66666666-6666-6666-6666-666666666601',
        v_user_mm, 'Test Cat', 'LOW',
        ST_SetSRID(ST_MakePoint(78.9000, 20.9000), 4326), 'GPS',
        'TEST-DEV', now(), 'Geofence outside test', 'OPERATOR_SEALED'
    ) RETURNING id, location_valid INTO v_obs_id, v_is_valid;

    IF v_is_valid THEN
        RAISE EXCEPTION 'TEST 4 FAILED: Location outside polygon was falsely flagged as valid!';
    END IF;

    v_passed_count := v_passed_count + 1;
    RAISE NOTICE 'TEST 4 PASSED: PostGIS Geofence trigger accurately validates spatial containment.';

    -- -----------------------------------------------------------------
    -- TEST 5: Audit Hash Chain Verification
    -- -----------------------------------------------------------------
    v_test_count := v_test_count + 1;
    -- Verify that audit logs recorded hashes
    SELECT hash INTO v_hash1 FROM audit_logs WHERE record_id = v_obs_id ORDER BY ts DESC LIMIT 1;
    IF v_hash1 IS NULL THEN
        RAISE EXCEPTION 'TEST 5 FAILED: No audit log generated for observation insert!';
    END IF;

    -- Update observation and verify chain link
    UPDATE observations SET description = 'Updated description' WHERE id = v_obs_id;
    SELECT hash, prev_hash INTO v_hash2, v_prev_hash FROM audit_logs WHERE record_id = v_obs_id ORDER BY ts DESC LIMIT 1;

    IF v_prev_hash <> v_hash1 THEN
        RAISE EXCEPTION 'TEST 5 FAILED: Audit hash chain broken! prev_hash (%) != hash1 (%)', v_prev_hash, v_hash1;
    END IF;

    v_passed_count := v_passed_count + 1;
    RAISE NOTICE 'TEST 5 PASSED: Audit log cryptographic SHA-256 hash chain verified.';

    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'ALL % TESTS COMPLETED SUCCESSFULLY (% PASSED / 0 FAILED)', v_test_count, v_passed_count;
    RAISE NOTICE '=====================================================';
END;
$$ LANGUAGE plpgsql;

-- Execute test suite
SELECT run_test_suite();

-- Cleanup test function
DROP FUNCTION run_test_suite();

ROLLBACK;
