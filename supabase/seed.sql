-- Seed: supabase/seed.sql
-- Description: Complete statutory seed dataset for KoylaNetra demo (Demo OCP-1, 6 Sections, 3 Users, 20 Obligations, 15 Observations, 12 CAPAs, 2 Incidents, 4 Directions)

-- Disable triggers during direct relational bootstrap if needed
SET session_replication_role = 'replica';

-- ========================================================================================
-- 1. DGMS Region & District Hierarchy
-- ========================================================================================
INSERT INTO dgms_regions (id, name, code, office_address)
VALUES (
    '11111111-1111-1111-1111-111111111101',
    'DGMS Nagpur Region-2',
    'DGMS-NAGPUR-02',
    'CGO Complex, Seminary Hills, Nagpur, Maharashtra - 440006'
) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO districts (id, name, state, dgms_region_id)
VALUES (
    '22222222-2222-2222-2222-222222222201',
    'Yavatmal',
    'Maharashtra',
    '11111111-1111-1111-1111-111111111101'
) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ========================================================================================
-- 2. Corporate Subsidiary & Operational Area
-- ========================================================================================
INSERT INTO subsidiaries (id, name, code)
VALUES (
    '33333333-3333-3333-3333-333333333301',
    'Western Coalfields Limited',
    'WCL'
) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

INSERT INTO areas (id, subsidiary_id, name, code)
VALUES (
    '44444444-4444-4444-4444-444444444401',
    '33333333-3333-3333-3333-333333333301',
    'Wani Area',
    'WANI'
) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ========================================================================================
-- 3. Mine: Demo OCP-1 (Opencast, Yavatmal, DGMS Nagpur Region-2)
-- Polygon Lease Boundary enclosing (20.01 to 20.06 N, 78.11 to 78.16 E)
-- ========================================================================================
INSERT INTO mines (
    id, name, code, area_id, subsidiary_id, district_id, dgms_region_id, mine_type, lease_boundary
) VALUES (
    '55555555-5555-5555-5555-555555555501',
    'Demo OCP-1',
    'WCL-WANI-DOCP1',
    '44444444-4444-4444-4444-444444444401',
    '33333333-3333-3333-3333-333333333301',
    '22222222-2222-2222-2222-222222222201',
    '11111111-1111-1111-1111-111111111101',
    'OPENCAST',
    ST_SetSRID(ST_GeomFromText('POLYGON((78.1100 20.0100, 78.1600 20.0100, 78.1600 20.0600, 78.1100 20.0600, 78.1100 20.0100))'), 4326)
) ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name;

-- ========================================================================================
-- 4. 6 Sections with Physical QR/NFC Tags
-- ========================================================================================
INSERT INTO sections (id, mine_id, name, tag_code, tag_type, location, is_underground) VALUES
('66666666-6666-6666-6666-666666666601', '55555555-5555-5555-5555-555555555501', 'Bench 3 Coal Face', 'KN-TAG-BN3', 'QR', ST_SetSRID(ST_MakePoint(78.1250, 20.0250), 4326), false),
('66666666-6666-6666-6666-666666666602', '55555555-5555-5555-5555-555555555501', 'Haul Road North - Segment 2', 'KN-TAG-HRN', 'BOTH', ST_SetSRID(ST_MakePoint(78.1320, 20.0310), 4326), false),
('66666666-6666-6666-6666-666666666603', '55555555-5555-5555-5555-555555555501', 'Overburden Dump-3 Toe', 'KN-TAG-DM3', 'QR', ST_SetSRID(ST_MakePoint(78.1400, 20.0450), 4326), false),
('66666666-6666-6666-6666-666666666604', '55555555-5555-5555-5555-555555555501', 'Sump-1 Dewatering Pump House', 'KN-TAG-SMP', 'NFC', ST_SetSRID(ST_MakePoint(78.1180, 20.0190), 4326), false),
('66666666-6666-6666-6666-666666666605', '55555555-5555-5555-5555-555555555501', 'Explosives Magazine Complex', 'KN-TAG-MAG', 'BOTH', ST_SetSRID(ST_MakePoint(78.1520, 20.0510), 4326), false),
('66666666-6666-6666-6666-666666666606', '55555555-5555-5555-5555-555555555501', 'Central HEMM Workshop & Fuel Point', 'KN-TAG-WKP', 'QR', ST_SetSRID(ST_MakePoint(78.1150, 20.0150), 4326), false)
ON CONFLICT (id) DO NOTHING;

-- ========================================================================================
-- 5. Three Users (One per Role)
-- 1. Field Officer: B. Oraon (fo@koylanetra.gov.in)
-- 2. Mine Manager: Rajesh Kumar (manager@koylanetra.gov.in)
-- 3. Regulator: Dr. V. K. Sharma (regulator@dgms.gov.in)
-- ========================================================================================
-- Seed auth.users if auth schema exists
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at)
VALUES 
('77777777-7777-7777-7777-777777777701', 'fo@koylanetra.gov.in', crypt('KoylaField@2026', gen_salt('bf')), now(), '{"role":"FIELD_OFFICER","scope_type":"MINE","scope_id":"55555555-5555-5555-5555-555555555501"}'::jsonb, '{"full_name":"B. Oraon"}'::jsonb, now(), now()),
('77777777-7777-7777-7777-777777777702', 'manager@koylanetra.gov.in', crypt('KoylaManager@2026', gen_salt('bf')), now(), '{"role":"MINE_MANAGER","scope_type":"MINE","scope_id":"55555555-5555-5555-5555-555555555501"}'::jsonb, '{"full_name":"Rajesh Kumar"}'::jsonb, now(), now()),
('77777777-7777-7777-7777-777777777703', 'regulator@dgms.gov.in', crypt('DgmsRegulator@2026', gen_salt('bf')), now(), '{"role":"REGULATOR","scope_type":"REGION","scope_id":"11111111-1111-1111-1111-111111111101"}'::jsonb, '{"full_name":"Dr. V. K. Sharma"}'::jsonb, now(), now())
ON CONFLICT (id) DO UPDATE SET raw_app_meta_data = EXCLUDED.raw_app_meta_data;

INSERT INTO public.users (id, email, full_name, role, scope_type, scope_id)
VALUES
('77777777-7777-7777-7777-777777777701', 'fo@koylanetra.gov.in', 'B. Oraon', 'FIELD_OFFICER', 'MINE', '55555555-5555-5555-5555-555555555501'),
('77777777-7777-7777-7777-777777777702', 'manager@koylanetra.gov.in', 'Rajesh Kumar', 'MINE_MANAGER', 'MINE', '55555555-5555-5555-5555-555555555501'),
('77777777-7777-7777-7777-777777777703', 'regulator@dgms.gov.in', 'Dr. V. K. Sharma', 'REGULATOR', 'REGION', '11111111-1111-1111-1111-111111111101')
ON CONFLICT (id) DO UPDATE SET full_name = EXCLUDED.full_name;

-- ========================================================================================
-- 6. 20 Statutory Obligations (Mix of CMR-Only, OSHWC-Only, Both-Cited)
-- ========================================================================================
INSERT INTO obligations (
    id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id,
    title, description, frequency, owner_role, due_date, status, cmr_2017_ref, oshwc_2020_ref, law_status, provenance
) VALUES
-- 1
('88888888-8888-8888-8888-888888888801', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Daily Haul Road Berm Inspection', 'Inspect berm height equal to largest tire radius on all haul routes', 'DAILY', 'FIELD_OFFICER', now() + INTERVAL '4 hours', 'PENDING', 'Reg 104', 'Sec 23(1)', 'BOTH_CITED', 'OPERATOR_SEALED'),
-- 2
('88888888-8888-8888-8888-888888888802', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Dump-3 Slope Stability Radar Review', 'Review daily prism and radar displacement rate graphs', 'DAILY', 'MINE_MANAGER', now() + INTERVAL '2 hours', 'PENDING', 'Reg 106', NULL, 'CMR_ONLY', 'INSTRUMENT'),
-- 3
('88888888-8888-8888-8888-888888888803', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Explosives Magazine Daily Stock Balance', 'Verify Form 32 register with physical physical detonator counts', 'DAILY', 'FIELD_OFFICER', now() - INTERVAL '3 hours', 'OVERDUE', 'Reg 148', 'Sec 31', 'BOTH_CITED', 'OPERATOR_SEALED'),
-- 4
('88888888-8888-8888-8888-888888888804', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Weekly Heavy Equipment Brake Test', 'Dynamic brake test on CAT 777D dumper fleet', 'WEEKLY', 'MINE_MANAGER', now() + INTERVAL '1 day', 'PENDING', 'Reg 98', NULL, 'CMR_ONLY', 'OPERATOR_SEALED'),
-- 5
('88888888-8888-8888-8888-888888888805', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Weekly Airborne Respirable Dust Sampling', 'Collect gravimetric dust sampler cassettes across active benches', 'WEEKLY', 'FIELD_OFFICER', now() + INTERVAL '2 days', 'PENDING', 'Reg 143', 'Sec 6(1)', 'BOTH_CITED', 'OPERATOR_SEALED'),
-- 6
('88888888-8888-8888-8888-888888888806', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Contractor Safety Induction Compliance', 'Ensure 100% contractor personnel have valid VTC cards', 'MONTHLY', 'MINE_MANAGER', now() + INTERVAL '5 days', 'PENDING', NULL, 'Sec 12(3)', 'OSHWC_ONLY', 'OPERATOR_SEALED'),
-- 7
('88888888-8888-8888-8888-888888888807', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Monthly Production & Safety Return (August)', 'Statutory Form II submission to DGMS Regional Office', 'MONTHLY', 'MINE_MANAGER', now() - INTERVAL '2 days', 'OVERDUE', 'Reg 5', 'Sec 10', 'BOTH_CITED', 'OPERATOR_SEALED'),
-- 8
('88888888-8888-8888-8888-888888888808', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Quarterly Pit Sump Dewatering Capacity Audit', 'Verify high-head standby submersible pumps', 'QUARTERLY', 'MINE_MANAGER', now() + INTERVAL '20 days', 'PENDING', 'Reg 152', NULL, 'CMR_ONLY', 'OPERATOR_SEALED'),
-- 9
('88888888-8888-8888-8888-888888888809', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Periodic Medical Examination (PME) Audit', 'Validate 20% workforce annual health check completion', 'QUARTERLY', 'MINE_MANAGER', now() + INTERVAL '12 days', 'PENDING', NULL, 'Sec 8(2)', 'OSHWC_ONLY', 'OPERATOR_SEALED'),
-- 10
('88888888-8888-8888-8888-888888888810', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'Pre-Shift Blasting Risk Assessment', 'Check flyrock exclusion zone and vibration monitor setup', 'DAILY', 'FIELD_OFFICER', now() - INTERVAL '1 hour', 'COMPLETED', 'Reg 164', 'Sec 24', 'BOTH_CITED', 'OPERATOR_SEALED'),
-- 11 to 20
('88888888-8888-8888-8888-888888888811', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Fire Extinguisher Monthly Hydro-Test', 'Test and tag fire suppression on Shovel-7', 'MONTHLY', 'FIELD_OFFICER', now() + INTERVAL '14 days', 'PENDING', 'Reg 122', NULL, 'CMR_ONLY', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888812', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Drinking Water Quality Testing', 'Bacteriological test at Canteen and Bench 3 point', 'MONTHLY', 'FIELD_OFFICER', now() + INTERVAL '8 days', 'PENDING', NULL, 'Sec 18', 'OSHWC_ONLY', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888813', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Annual Pit Slope Geotechnical Survey', 'LiDAR contour survey of highwall', 'ANNUAL', 'MINE_MANAGER', now() + INTERVAL '45 days', 'PENDING', 'Reg 107', 'Sec 22', 'BOTH_CITED', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888814', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Electrical Earth Resistance Measurement', 'Measure earth electrode resistance at Substation 2', 'QUARTERLY', 'FIELD_OFFICER', now() - INTERVAL '4 days', 'OVERDUE', 'Reg 131', NULL, 'CMR_ONLY', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888815', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Safety Committee Bi-Monthly Meeting', 'Joint worker-management safety review meeting', 'MONTHLY', 'MINE_MANAGER', now() + INTERVAL '3 days', 'PENDING', 'Reg 30', 'Sec 22(1)', 'BOTH_CITED', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888816', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Statutory Mine Lighting Lux Measurement', 'Check 10 lux minimum on night haul road paths', 'MONTHLY', 'FIELD_OFFICER', now() - INTERVAL '5 days', 'COMPLETED', 'Reg 154', NULL, 'CMR_ONLY', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888817', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'First Aid Station Supply Audit', 'Stock verification of stretchers, splints, oxygen cylinders', 'MONTHLY', 'FIELD_OFFICER', now() + INTERVAL '10 days', 'PENDING', 'Reg 196', 'Sec 19', 'BOTH_CITED', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888818', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Explosives Van Escort and Lock Verification', 'Check GPS tracking and siren system on explosive carrier', 'WEEKLY', 'FIELD_OFFICER', now() + INTERVAL '1 day', 'PENDING', 'Reg 150', NULL, 'CMR_ONLY', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888819', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Annual Vocational Training Register Audit', 'Ensure all statutory refreshers logged in Form B', 'ANNUAL', 'MINE_MANAGER', now() + INTERVAL '60 days', 'PENDING', NULL, 'Sec 13', 'OSHWC_ONLY', 'OPERATOR_SEALED'),
('88888888-8888-8888-8888-888888888820', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Pre-Monsoon Drainage Plan Verification', 'Check capacity of Garland drains around Dump-3', 'ANNUAL', 'MINE_MANAGER', now() - INTERVAL '15 days', 'COMPLETED', 'Reg 109', 'Sec 22', 'BOTH_CITED', 'OPERATOR_SEALED')
ON CONFLICT (id) DO NOTHING;

-- ========================================================================================
-- 7. 15 Field Observations (GPS, QR, NFC Check-ins; Diverse Severity & Provenance)
-- ========================================================================================
INSERT INTO observations (
    id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id,
    section_id, reported_by, category, severity, location, checkin_method, tag_scanned,
    device_id, client_created_at, server_created_at, location_valid, description, provenance
) VALUES
-- Obs 1: Low Berm
('99999999-9999-9999-9999-999999999901', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'66666666-6666-6666-6666-666666666602', '77777777-7777-7777-7777-777777777701', 'Haulage & Roads', 'CRITICAL', ST_SetSRID(ST_MakePoint(78.1325, 20.0315), 4326), 'QR', 'KN-TAG-HRN',
'MOBI-TAB-014', now() - INTERVAL '5 hours', now() - INTERVAL '5 hours', true, 'Haul Road North outer berm washed out over 35m length. Height below 1.2m.', 'OPERATOR_SEALED'),

-- Obs 2: Dump Tension Cracks
('99999999-9999-9999-9999-999999999902', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'66666666-6666-6666-6666-666666666603', '77777777-7777-7777-7777-777777777701', 'Ground Control', 'HIGH', ST_SetSRID(ST_MakePoint(78.1402, 20.0452), 4326), 'GPS', NULL,
'MOBI-TAB-014', now() - INTERVAL '1 day', now() - INTERVAL '1 day', true, 'Tension crack of 15mm width visible along Dump-3 crest after heavy rain.', 'OPERATOR_SEALED'),

-- Obs 3: Loose Material on Bench Face
('99999999-9999-9999-9999-999999999903', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'66666666-6666-6666-6666-666666666601', '77777777-7777-7777-7777-777777777701', 'Ground Control', 'MEDIUM', ST_SetSRID(ST_MakePoint(78.1251, 20.0252), 4326), 'QR', 'KN-TAG-BN3',
'MOBI-TAB-014', now() - INTERVAL '8 hours', now() - INTERVAL '8 hours', true, 'Overhanging coal boulder on Bench 3 upper crest above loader loading point.', 'OPERATOR_SEALED'),

-- Obs 4: Sump-1 Pump Leakage
('99999999-9999-9999-9999-999999999904', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'66666666-6666-6666-6666-666666666604', '77777777-7777-7777-7777-777777777701', 'Electrical & Machinery', 'LOW', ST_SetSRID(ST_MakePoint(78.1182, 20.0191), 4326), 'NFC', 'KN-TAG-SMP',
'MOBI-TAB-014', now() - INTERVAL '12 hours', now() - INTERVAL '12 hours', true, 'Gland packing leaking water on high-pressure pump 2.', 'OPERATOR_UNSEALED'),

-- Obs 5 to 15
('99999999-9999-9999-9999-999999999905', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666605', '77777777-7777-7777-7777-777777777701', 'Explosives Safety', 'MEDIUM', ST_SetSRID(ST_MakePoint(78.1521, 20.0512), 4326), 'QR', 'KN-TAG-MAG', 'MOBI-TAB-014', now() - INTERVAL '2 days', now() - INTERVAL '2 days', true, 'Earthing wire detached on magazine lightning arrestor.', 'OPERATOR_SEALED'),
('99999999-9999-9999-9999-999999999906', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666606', '77777777-7777-7777-7777-777777777701', 'Machinery', 'HIGH', ST_SetSRID(ST_MakePoint(78.1152, 20.0151), 4326), 'QR', 'KN-TAG-WKP', 'MOBI-TAB-014', now() - INTERVAL '3 days', now() - INTERVAL '3 days', true, 'Overhead crane wire rope showing 3 broken strands.', 'OPERATOR_SEALED'),
('99999999-9999-9999-9999-999999999907', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666602', '77777777-7777-7777-7777-777777777701', 'Environment', 'MEDIUM', ST_SetSRID(ST_MakePoint(78.1322, 20.0312), 4326), 'GPS', NULL, 'MOBI-TAB-014', now() - INTERVAL '6 hours', now() - INTERVAL '6 hours', true, 'Dust suppression sprinkler line choked near junction 4.', 'OPERATOR_UNSEALED'),
('99999999-9999-9999-9999-999999999908', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666601', '77777777-7777-7777-7777-777777777701', 'Fire Safety', 'LOW', ST_SetSRID(ST_MakePoint(78.1255, 20.0255), 4326), 'GPS', NULL, 'MOBI-TAB-014', now() - INTERVAL '4 days', now() - INTERVAL '4 days', true, 'DCP extinguisher pressure gauge slightly in red zone.', 'OPERATOR_SEALED'),
('99999999-9999-9999-9999-999999999909', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666606', '77777777-7777-7777-7777-777777777701', 'Electrical', 'HIGH', ST_SetSRID(ST_MakePoint(78.1154, 20.0153), 4326), 'QR', 'KN-TAG-WKP', 'MOBI-TAB-014', now() - INTERVAL '5 days', now() - INTERVAL '5 days', true, 'Welding set flexible trailing cable joint taped with non-vulcanized tape.', 'OPERATOR_SEALED'),
('99999999-9999-9999-9999-999999999910', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666602', '77777777-7777-7777-7777-777777777701', 'Traffic', 'MEDIUM', ST_SetSRID(ST_MakePoint(78.1328, 20.0318), 4326), 'GPS', NULL, 'MOBI-TAB-014', now() - INTERVAL '1 day', now() - INTERVAL '1 day', true, 'Haul road reflection warning sign knocked down by grader.', 'OPERATOR_UNSEALED'),
('99999999-9999-9999-9999-999999999911', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666604', '77777777-7777-7777-7777-777777777701', 'General Safety', 'LOW', ST_SetSRID(ST_MakePoint(78.1185, 20.0195), 4326), 'NFC', 'KN-TAG-SMP', 'MOBI-TAB-014', now() - INTERVAL '3 days', now() - INTERVAL '3 days', true, 'Handrail loose on sump access stairs.', 'OPERATOR_SEALED'),
('99999999-9999-9999-9999-999999999912', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666601', '77777777-7777-7777-7777-777777777703', 'Statutory Inspection', 'CRITICAL', ST_SetSRID(ST_MakePoint(78.1258, 20.0258), 4326), 'GPS', NULL, 'REG-TAB-002', now() - INTERVAL '2 days', now() - INTERVAL '2 days', true, 'DGMS statutory inspection observed excavator operating within 5m of unstable crest.', 'INSPECTOR'),
('99999999-9999-9999-9999-999999999913', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666603', '77777777-7777-7777-7777-777777777701', 'Ground Control', 'HIGH', ST_SetSRID(ST_MakePoint(78.1405, 20.0455), 4326), 'QR', 'KN-TAG-DM3', 'MOBI-TAB-014', now() - INTERVAL '7 days', now() - INTERVAL '7 days', true, 'Drainage ditch at toe of Dump-3 silted up, causing ponding.', 'OPERATOR_SEALED'),
('99999999-9999-9999-9999-999999999914', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666606', '77777777-7777-7777-7777-777777777701', 'PPE Compliance', 'MEDIUM', ST_SetSRID(ST_MakePoint(78.1156, 20.0155), 4326), 'QR', 'KN-TAG-WKP', 'MOBI-TAB-014', now() - INTERVAL '6 days', now() - INTERVAL '6 days', true, 'Two mechanics grinding without full face shields.', 'OPERATOR_UNSEALED'),
('99999999-9999-9999-9999-999999999915', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '66666666-6666-6666-6666-666666666602', '77777777-7777-7777-7777-777777777701', 'Traffic', 'HIGH', ST_SetSRID(ST_MakePoint(78.1330, 20.0320), 4326), 'QR', 'KN-TAG-HRN', 'MOBI-TAB-014', now() - INTERVAL '8 days', now() - INTERVAL '8 days', true, 'Dumper 24 observed with non-functioning rear audio-visual alarm.', 'OPERATOR_SEALED')
ON CONFLICT (id) DO NOTHING;

-- Photos for observations
INSERT INTO observation_photos (id, observation_id, url, sha256_hash, captured_at) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa01', '99999999-9999-9999-9999-999999999901', 'https://storage.supabase.co/koylanetra-media/55555555-5555-5555-5555-555555555501/obs/99999999-9999-9999-9999-999999999901/berm_damage.jpg', 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855', now() - INTERVAL '5 hours'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaa02', '99999999-9999-9999-9999-999999999902', 'https://storage.supabase.co/koylanetra-media/55555555-5555-5555-5555-555555555501/obs/99999999-9999-9999-9999-999999999902/dump_crack.jpg', '8729832049281039812309182309182309182309182309182309182309182309', now() - INTERVAL '1 day')
ON CONFLICT (id) DO NOTHING;

-- ========================================================================================
-- 8. 12 CAPAs in Mixed States (Including EXACTLY ONE 'PENDING_VERIFICATION')
-- ========================================================================================
INSERT INTO capas (
    id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id,
    source_observation_id, title, description, owner_id, severity, due_date, status,
    escalation_level, closed_by, closed_at, closure_notes, verified_by, verified_at, verification_notes, provenance
) VALUES
-- CAPA-1: PENDING_VERIFICATION (Closed by Field Officer, awaiting Mine Manager verification)
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'99999999-9999-9999-9999-999999999901', 'Rebuild Berm on Haul Road North (CAPA-231)', 'Dozing and compaction of 1.8m earthen berm with reflective guide markers',
'77777777-7777-7777-7777-777777777701', 'CRITICAL', now() + INTERVAL '19 hours', 'PENDING_VERIFICATION',
0, '77777777-7777-7777-7777-777777777701', now() - INTERVAL '1 hour', 'Dozer D-8 rebuilt berm to 1.85m height over 40m. Geo-tagged after-photos uploaded.', NULL, NULL, NULL, 'OPERATOR_SEALED'),

-- CAPA-2: ESCALATED (Overdue drainage)
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb02', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'99999999-9999-9999-9999-999999999913', 'Clear Silted Drainage at Dump-3 Toe (CAPA-198)', 'Deploy JCB to desilt 120m garland drain to prevent toe saturation',
'77777777-7777-7777-7777-777777777701', 'HIGH', now() - INTERVAL '1 day', 'ESCALATED',
1, NULL, NULL, NULL, NULL, NULL, NULL, 'OPERATOR_SEALED'),

-- CAPA-3: OPEN (Critical slope monitoring)
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb03', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'99999999-9999-9999-9999-999999999902', 'Establish 50m Barricade at Dump-3 Tension Crack', 'Cordon off dump crest and install prism monitoring stations',
'77777777-7777-7777-7777-777777777701', 'CRITICAL', now() + INTERVAL '18 hours', 'OPEN',
0, NULL, NULL, NULL, NULL, NULL, NULL, 'OPERATOR_SEALED'),

-- CAPA-4: OPEN (Medium)
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb04', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'99999999-9999-9999-9999-999999999903', 'Dress Overhanging Boulder on Bench 3 (CAPA-240)', 'Deploy long-reach excavator to pull down loose crest coal',
'77777777-7777-7777-7777-777777777701', 'MEDIUM', now() + INTERVAL '4 days', 'OPEN',
0, NULL, NULL, NULL, NULL, NULL, NULL, 'OPERATOR_SEALED'),

-- CAPA-5: VERIFIED (Maker-checker verified: closed by Field Officer, verified by Mine Manager)
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb05', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'99999999-9999-9999-9999-999999999906', 'Replace Overhead Crane Wire Rope in HEMM Workshop', 'Install certified steel core wire rope with load test certificate',
'77777777-7777-7777-7777-777777777701', 'HIGH', now() - INTERVAL '3 days', 'VERIFIED',
0, '77777777-7777-7777-7777-777777777701', now() - INTERVAL '2 days', 'New rope fitted, tested to 10T SWL.', '77777777-7777-7777-7777-777777777702', now() - INTERVAL '1 day', 'On-site load test inspected and certificate verified in file.', 'OPERATOR_SEALED'),

-- CAPA-6 to 12
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb06', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999905', 'Re-attach Magazine Lightning Earth Conductor', 'Copper weld lug back to test point', '77777777-7777-7777-7777-777777777701', 'MEDIUM', now() - INTERVAL '1 day', 'VERIFIED', 0, '77777777-7777-7777-7777-777777777701', now() - INTERVAL '2 days', 'Welded and tested < 2 ohms.', '77777777-7777-7777-7777-777777777702', now() - INTERVAL '1 day', 'Resistance verified at 1.4 ohms.', 'OPERATOR_SEALED'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb07', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999909', 'Vulcanize Trailing Cable Joint in Workshop', 'Remove tape and vulcanize insulation', '77777777-7777-7777-7777-777777777701', 'HIGH', now() + INTERVAL '2 days', 'OPEN', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'OPERATOR_SEALED'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb08', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999915', 'Replace Dumper 24 Audio Visual Reverse Alarm', 'Install high-decibel smart alarm', '77777777-7777-7777-7777-777777777701', 'HIGH', now() - INTERVAL '2 days', 'VERIFIED', 0, '77777777-7777-7777-7777-777777777701', now() - INTERVAL '3 days', 'Alarm replaced and tested.', '77777777-7777-7777-7777-777777777702', now() - INTERVAL '2 days', 'Audibility verified at 50m.', 'OPERATOR_SEALED'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb09', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999910', 'Re-erect Knocked Down Traffic Signage', 'Cement foundation pole and install retro-reflective sheet', '77777777-7777-7777-7777-777777777701', 'MEDIUM', now() + INTERVAL '5 days', 'OPEN', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'OPERATOR_SEALED'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb10', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999907', 'Flush and Clear Choked Dust Sprinkler Line', 'De-choke nozzles across 200m line', '77777777-7777-7777-7777-777777777701', 'MEDIUM', now() + INTERVAL '3 days', 'OPEN', 0, NULL, NULL, NULL, NULL, NULL, NULL, 'OPERATOR_SEALED'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb11', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999911', 'Fasten Sump Access Handrails', 'Weld and bolt loose bracket', '77777777-7777-7777-7777-777777777701', 'LOW', now() - INTERVAL '1 day', 'VERIFIED', 0, '77777777-7777-7777-7777-777777777701', now() - INTERVAL '2 days', 'Bracket secured.', '77777777-7777-7777-7777-777777777702', now() - INTERVAL '1 day', 'Checked on site.', 'OPERATOR_SEALED'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb12', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', '99999999-9999-9999-9999-999999999914', 'Provide Full Face Shields to Fabrication Cell', 'Issue 10 EN166 approved grinding shields', '77777777-7777-7777-7777-777777777701', 'MEDIUM', now() - INTERVAL '4 days', 'VERIFIED', 0, '77777777-7777-7777-7777-777777777701', now() - INTERVAL '5 days', 'Shields issued from stores.', '77777777-7777-7777-7777-777777777702', now() - INTERVAL '4 days', 'Mechanics verified wearing shields.', 'OPERATOR_SEALED')
ON CONFLICT (id) DO NOTHING;

-- After photos for CAPA-1 (Pending verification)
INSERT INTO capa_after_photos (id, capa_id, url, sha256_hash, captured_at) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccc01', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01', 'https://storage.supabase.co/koylanetra-media/55555555-5555-5555-5555-555555555501/capa/bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbb01/berm_rebuilt.jpg', 'a1b2c3d4e5f67890123456789abcdef0123456789abcdef0123456789abcdef0', now() - INTERVAL '1 hour')
ON CONFLICT (id) DO NOTHING;

-- ========================================================================================
-- 9. 2 Incidents (1 with statutory notice inside 24h, 1 outside)
-- ========================================================================================
INSERT INTO incidents (
    id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id,
    incident_type, occurred_at, notified_phone_at, written_notice_at, description, location_description, provenance
) VALUES
-- Incident 1: Written notice inside 24h (within_24h_window = true)
('dddddddd-dddd-dddd-dddd-dddddddddd01', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'SERIOUS', now() - INTERVAL '18 hours', now() - INTERVAL '16 hours', now() - INTERVAL '6 hours',
'Dumper D-32 collided with haul road embankment due to steering hydraulic hose rupture during descent.', 'Haul Road North Segment 2, near Ch. 450m', 'OPERATOR_SEALED'),

-- Incident 2: Delayed written notice beyond 24h (within_24h_window = false)
('dddddddd-dddd-dddd-dddd-dddddddddd02', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
'DANGEROUS_OCCURRENCE', now() - INTERVAL '25 days', now() - INTERVAL '24 days', now() - INTERVAL '22 days',
'Slope slumping over 40m length on southern flank of Dump-2 after intense localized cloudburst.', 'Dump-2 Southern Toe Area', 'OPERATOR_SEALED')
ON CONFLICT (id) DO NOTHING;

-- Worker PII for Incident 1 (Separate table - Rule D zero regulator policy)
INSERT INTO incident_worker_details (id, incident_id, worker_name, worker_id_number, injury_description) VALUES
('eeeeeeee-eeee-eeee-eeee-eeeeeeeeee01', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'Anil M. Sharma', 'EMP-WCL-89214', 'Fracture of right radius and severe contusions to left shoulder')
ON CONFLICT (id) DO NOTHING;

-- ========================================================================================
-- 10. 4 DGMS Directions (Including 1 Overdue)
-- ========================================================================================
INSERT INTO directions (
    id, issued_by, dgms_region_id, defect_category, enforcement_step, compliance_date, evidence_received, evidence_received_at, status, issued_at, notes
) VALUES
-- Direction 1: OVERDUE
('ffffffff-ffff-ffff-ffff-ffffffffff01', '77777777-7777-7777-7777-777777777703', '11111111-1111-1111-1111-111111111101',
'Haul Road Safety', 'WRITTEN_DIRECTION', now() - INTERVAL '2 days', false, NULL, 'OVERDUE', now() - INTERVAL '15 days',
'Bring all main coal transport corridors into full compliance with DGMS Standard Berm dimensions (height >= 1.8m).'),

-- Direction 2: ISSUED (Active, within deadline)
('ffffffff-ffff-ffff-ffff-ffffffffff02', '77777777-7777-7777-7777-777777777703', '11111111-1111-1111-1111-111111111101',
'Slope Monitoring', 'IMPROVEMENT_NOTICE', now() + INTERVAL '7 days', false, NULL, 'ISSUED', now() - INTERVAL '3 days',
'Install Continuous Slope Stability Radar on Dump-3 and provide real-time feed access to DGMS Regional Inspectorate.'),

-- Direction 3: COMPLIED
('ffffffff-ffff-ffff-ffff-ffffffffff03', '77777777-7777-7777-7777-777777777703', '11111111-1111-1111-1111-111111111101',
'Explosives Safety', 'OBSERVATION', now() - INTERVAL '5 days', true, now() - INTERVAL '6 days', 'COMPLIED', now() - INTERVAL '20 days',
'Repair lightning arrestor earthing pit at Magazine Complex and submit third-party electrical test certificate.'),

-- Direction 4: ISSUED (High Priority)
('ffffffff-ffff-ffff-ffff-ffffffffff04', '77777777-7777-7777-7777-777777777703', '11111111-1111-1111-1111-111111111101',
'Dust Suppression', 'WRITTEN_DIRECTION', now() + INTERVAL '3 days', false, NULL, 'ISSUED', now() - INTERVAL '4 days',
'Deploy additional 28kL pressurized mist water tankers along village haulage boundary to curtail PM10 levels.')
ON CONFLICT (id) DO NOTHING;

-- Target mine linking for directions
INSERT INTO direction_targets (
    direction_id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id
) VALUES
('ffffffff-ffff-ffff-ffff-ffffffffff01', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101'),
('ffffffff-ffff-ffff-ffff-ffffffffff02', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101'),
('ffffffff-ffff-ffff-ffff-ffffffffff03', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101'),
('ffffffff-ffff-ffff-ffff-ffffffffff04', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101')
ON CONFLICT (direction_id, mine_id) DO NOTHING;

-- Seed Denial Tables (Rule D)
INSERT INTO mine_risk_scores (id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id, score, component_breakdown, assessed_at)
VALUES (
    '10101010-1010-1010-1010-101010101010',
    '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
    68.0, '{"slope_displacement": 81, "haul_road_berms": 74, "bench_inspection_gaps": 66, "sump_pumping": 24}'::jsonb, now()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO production_logs (id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id, shift_date, shift, coal_tonnes, overburden_m3, recorded_by)
VALUES (
    '20202020-2020-2020-2020-202020202020',
    '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101',
    CURRENT_DATE, 'B', 19100.0, 48200.0, '77777777-7777-7777-7777-777777777702'
) ON CONFLICT (id) DO NOTHING;

INSERT INTO attendance_logs (id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id, shift_date, shift, worker_id, gate_id, punch_time, status)
VALUES 
('30303030-3030-3030-3030-303030303001', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', CURRENT_DATE, 'B', 'EMP-WCL-7819', 'GATE-01', now() - INTERVAL '7 hours', 'PRESENT'),
('30303030-3030-3030-3030-303030303002', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', CURRENT_DATE, 'B', 'EMP-WCL-9932', 'GATE-02', now() - INTERVAL '7 hours', 'STOPPED_EXPIRED_TRAINING')
ON CONFLICT (id) DO NOTHING;

INSERT INTO incident_inquiries (id, mine_id, mine_name, area_id, subsidiary_id, district_id, dgms_region_id, incident_id, status, findings, recommendations, created_by, finalized_at)
VALUES 
-- Finalized inquiry (visible to regulator)
('40404040-4040-4040-4040-404040404001', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'dddddddd-dddd-dddd-dddd-dddddddddd02', 'FINAL', 'Excessive pore pressure buildup at Dump-2 toe combined with inadequate garland drain slope.', 'Increase garland drain gradient to 1:200 and install horizontal sub-surface drain pipes.', '77777777-7777-7777-7777-777777777702', now() - INTERVAL '20 days'),
-- Draft inquiry (strictly hidden from regulator under Rule D)
('40404040-4040-4040-4040-404040404002', '55555555-5555-5555-5555-555555555501', 'Demo OCP-1', '44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'dddddddd-dddd-dddd-dddd-dddddddddd01', 'DRAFT', 'Preliminary metallurgical analysis of steering hose shows fatigue cracking at crimped ferrule.', 'Awaiting manufacturer OEM test report on burst pressure.', '77777777-7777-7777-7777-777777777702', NULL)
ON CONFLICT (id) DO NOTHING;

-- Restore normal trigger processing
SET session_replication_role = 'origin';

-- Refresh materialized views after seed
SELECT refresh_koylanetra_materialized_views();
