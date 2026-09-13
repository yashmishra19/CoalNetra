-- Migration: 20260913000007_rls_hierarchy_and_identity.sql
-- Description: Row Level Security policies for Hierarchy and Identity tables

-- ========================================================================================
-- 1. DGMS Regions (Public Read for Authenticated Users)
-- ========================================================================================
ALTER TABLE dgms_regions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read regions"
ON dgms_regions FOR SELECT
TO authenticated
USING (true);

-- ========================================================================================
-- 2. Districts (Public Read for Authenticated Users)
-- ========================================================================================
ALTER TABLE districts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read districts"
ON districts FOR SELECT
TO authenticated
USING (true);

-- ========================================================================================
-- 3. Subsidiaries (Public Read for Authenticated Users)
-- ========================================================================================
ALTER TABLE subsidiaries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read subsidiaries"
ON subsidiaries FOR SELECT
TO authenticated
USING (true);

-- ========================================================================================
-- 4. Areas (Public Read for Authenticated Users)
-- ========================================================================================
ALTER TABLE areas ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow authenticated users to read areas"
ON areas FOR SELECT
TO authenticated
USING (true);

-- ========================================================================================
-- 5. Mines (Filtered by DGMS Region for Regulators, or Mine Scope for Managers/Officers)
-- ========================================================================================
ALTER TABLE mines ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Mines read policy by role scope"
ON mines FOR SELECT
TO authenticated
USING (
    (is_regulator() AND dgms_region_id = auth_scope_id()) OR
    ((is_mine_manager() OR is_field_officer()) AND id = auth_scope_id())
);

CREATE POLICY "Mine Manager update own mine profile"
ON mines FOR UPDATE
TO authenticated
USING (is_mine_manager() AND id = auth_scope_id())
WITH CHECK (is_mine_manager() AND id = auth_scope_id());

-- ========================================================================================
-- 6. Sections (Filtered by Mine or Region)
-- ========================================================================================
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Sections read policy by role scope"
ON sections FOR SELECT
TO authenticated
USING (
    ((is_mine_manager() OR is_field_officer()) AND mine_id = auth_scope_id()) OR
    (is_regulator() AND EXISTS (
        SELECT 1 FROM mines m WHERE m.id = sections.mine_id AND m.dgms_region_id = auth_scope_id()
    ))
);

CREATE POLICY "Mine Manager manage sections in own mine"
ON sections FOR ALL
TO authenticated
USING (is_mine_manager() AND mine_id = auth_scope_id())
WITH CHECK (is_mine_manager() AND mine_id = auth_scope_id());

-- ========================================================================================
-- 7. Public Users (Identity & Scope RLS)
-- ========================================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
ON public.users FOR SELECT
TO authenticated
USING (id = auth.uid());

CREATE POLICY "Mine Manager can read users in same mine scope"
ON public.users FOR SELECT
TO authenticated
USING (
    is_mine_manager() AND scope_type = 'MINE' AND scope_id = auth_scope_id()
);

CREATE POLICY "Regulators can read users in same region scope"
ON public.users FOR SELECT
TO authenticated
USING (
    is_regulator() AND (
        (scope_type = 'REGION' AND scope_id = auth_scope_id()) OR
        (scope_type = 'MINE' AND EXISTS (
            SELECT 1 FROM mines m WHERE m.id = public.users.scope_id AND m.dgms_region_id = auth_scope_id()
        ))
    )
);

CREATE POLICY "Users can update own name/email"
ON public.users FOR UPDATE
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());
