-- Migration: 20260913000006_rls_helpers.sql
-- Description: Helper SQL functions for parsing Supabase JWT claims (app_metadata / user_metadata / database fallback)
-- Eliminates duplicate JWT parsing logic across RLS policies.

-- 1. Helper function: Get User Role
CREATE OR REPLACE FUNCTION auth_role() 
RETURNS TEXT AS $$
BEGIN
    RETURN COALESCE(
        current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'role',
        current_setting('request.jwt.claims', true)::jsonb -> 'user_metadata' ->> 'role',
        (SELECT role::text FROM public.users WHERE id = auth.uid())
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- 2. Helper function: Get User Scope Type (MINE | SUBSIDIARY | REGION)
CREATE OR REPLACE FUNCTION auth_scope_type() 
RETURNS TEXT AS $$
BEGIN
    RETURN COALESCE(
        current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'scope_type',
        current_setting('request.jwt.claims', true)::jsonb -> 'user_metadata' ->> 'scope_type',
        (SELECT scope_type::text FROM public.users WHERE id = auth.uid())
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- 3. Helper function: Get User Scope ID
CREATE OR REPLACE FUNCTION auth_scope_id() 
RETURNS UUID AS $$
BEGIN
    RETURN COALESCE(
        (current_setting('request.jwt.claims', true)::jsonb -> 'app_metadata' ->> 'scope_id')::uuid,
        (current_setting('request.jwt.claims', true)::jsonb -> 'user_metadata' ->> 'scope_id')::uuid,
        (SELECT scope_id FROM public.users WHERE id = auth.uid())
    );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- 4. Role Predicate Helpers
CREATE OR REPLACE FUNCTION is_role(target_role TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth_role() = target_role;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_field_officer()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth_role() = 'FIELD_OFFICER';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_mine_manager()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth_role() = 'MINE_MANAGER';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION is_regulator()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN auth_role() = 'REGULATOR';
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

-- 5. Scope Boundary Predicate Helpers
CREATE OR REPLACE FUNCTION in_mine_scope(target_mine_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    IF is_mine_manager() OR is_field_officer() THEN
        RETURN auth_scope_type() = 'MINE' AND auth_scope_id() = target_mine_id;
    ELSIF is_regulator() THEN
        RETURN auth_scope_type() = 'REGION' AND EXISTS (
            SELECT 1 FROM mines m 
            WHERE m.id = target_mine_id AND m.dgms_region_id = auth_scope_id()
        );
    END IF;
    RETURN false;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

CREATE OR REPLACE FUNCTION in_region_scope(target_region_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN is_regulator() AND auth_scope_type() = 'REGION' AND auth_scope_id() = target_region_id;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
