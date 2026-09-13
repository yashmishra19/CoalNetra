-- Migration: 20260913000002_hierarchy_and_identity.sql
-- Description: Create hierarchy and identity tables

-- 1. DGMS Regions (Jurisdiction is geographic, not corporate)
CREATE TABLE IF NOT EXISTS dgms_regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    office_address TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Districts (FK to dgms_regions)
CREATE TABLE IF NOT EXISTS districts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    state TEXT NOT NULL,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 3. Corporate Subsidiaries (e.g. WCL, SECL, BCCL, Tata Steel, etc.)
CREATE TABLE IF NOT EXISTS subsidiaries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 4. Areas (Operational grouping under subsidiaries)
CREATE TABLE IF NOT EXISTS areas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_area_code_subsidiary UNIQUE (subsidiary_id, code)
);

-- 5. Mines (Carrying denormalized subsidiary_id, district_id, dgms_region_id and PostGIS lease_boundary)
CREATE TABLE IF NOT EXISTS mines (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    code TEXT UNIQUE NOT NULL,
    area_id UUID NOT NULL REFERENCES areas(id) ON DELETE RESTRICT,
    subsidiary_id UUID NOT NULL REFERENCES subsidiaries(id) ON DELETE RESTRICT,
    district_id UUID NOT NULL REFERENCES districts(id) ON DELETE RESTRICT,
    dgms_region_id UUID NOT NULL REFERENCES dgms_regions(id) ON DELETE RESTRICT,
    mine_type mine_type_enum NOT NULL DEFAULT 'OPENCAST',
    lease_boundary GEOMETRY(Polygon, 4326) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 6. Sections (Underground / Opencast working locations with QR/NFC physical tags)
CREATE TABLE IF NOT EXISTS sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    tag_code TEXT UNIQUE NOT NULL,
    tag_type tag_type_enum NOT NULL DEFAULT 'QR',
    location GEOMETRY(Point, 4326), -- Nullable since underground sections may have no GPS fix
    is_underground BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 7. Users (1:1 with auth.users, carrying role and polymorphic scope)
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    role user_role NOT NULL,
    scope_type scope_type NOT NULL,
    scope_id UUID NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 8. Scope Validation Function & Trigger for Polymorphic Scope
CREATE OR REPLACE FUNCTION validate_user_scope()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.scope_type = 'MINE' THEN
        IF NOT EXISTS (SELECT 1 FROM mines WHERE id = NEW.scope_id) THEN
            RAISE EXCEPTION 'Invalid scope_id % for scope_type MINE. Mine does not exist.', NEW.scope_id;
        END IF;
    ELSIF NEW.scope_type = 'SUBSIDIARY' THEN
        IF NOT EXISTS (SELECT 1 FROM subsidiaries WHERE id = NEW.scope_id) THEN
            RAISE EXCEPTION 'Invalid scope_id % for scope_type SUBSIDIARY. Subsidiary does not exist.', NEW.scope_id;
        END IF;
    ELSIF NEW.scope_type = 'REGION' THEN
        IF NOT EXISTS (SELECT 1 FROM dgms_regions WHERE id = NEW.scope_id) THEN
            RAISE EXCEPTION 'Invalid scope_id % for scope_type REGION. DGMS Region does not exist.', NEW.scope_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_validate_user_scope ON public.users;
CREATE TRIGGER trg_validate_user_scope
BEFORE INSERT OR UPDATE OF scope_type, scope_id ON public.users
FOR EACH ROW EXECUTE FUNCTION validate_user_scope();
