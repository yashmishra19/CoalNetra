-- Migration: 20260913000001_extensions_and_enums.sql
-- Description: Enable required Postgres extensions and custom enum types

-- 1. Enable PostGIS and Cryptographic extensions
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. Domain & Identity Enums
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('FIELD_OFFICER', 'MINE_MANAGER', 'REGULATOR');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE scope_type AS ENUM ('MINE', 'SUBSIDIARY', 'REGION');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 3. Provenance Enum (Rule B: First-class Provenance)
DO $$ BEGIN
    CREATE TYPE provenance_type AS ENUM ('INSPECTOR', 'INSTRUMENT', 'OPERATOR_SEALED', 'OPERATOR_UNSEALED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 4. Operational & Statutory Enums
DO $$ BEGIN
    CREATE TYPE mine_type_enum AS ENUM ('OPENCAST', 'UNDERGROUND', 'MIXED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE tag_type_enum AS ENUM ('QR', 'NFC', 'BOTH');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE checkin_method_enum AS ENUM ('GPS', 'QR', 'NFC', 'MANUAL');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE severity_level_enum AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE capa_status_enum AS ENUM ('OPEN', 'PENDING_VERIFICATION', 'VERIFIED', 'ESCALATED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE obligation_frequency_enum AS ENUM ('DAILY', 'WEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUAL', 'EVENT_BASED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE law_status_enum AS ENUM ('CMR_ONLY', 'OSHWC_ONLY', 'BOTH_CITED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE obligation_status_enum AS ENUM ('PENDING', 'OVERDUE', 'COMPLETED', 'EXEMPTED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE inspection_discipline_enum AS ENUM ('MINING', 'ELECTRICAL', 'MECHANICAL', 'OCCUPATIONAL_HEALTH');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE inspection_status_enum AS ENUM ('PLANNED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE incident_type_enum AS ENUM ('FATAL', 'SERIOUS', 'DANGEROUS_OCCURRENCE', 'NEAR_MISS');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE enforcement_step_enum AS ENUM ('OBSERVATION', 'IMPROVEMENT_NOTICE', 'WRITTEN_DIRECTION', 'PROHIBITION_ORDER');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE direction_status_enum AS ENUM ('ISSUED', 'COMPLIED', 'OVERDUE', 'REVOKED');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE prohibition_scope_enum AS ENUM ('WHOLE_MINE', 'PART');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE inquiry_status_enum AS ENUM ('DRAFT', 'FINAL');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE audit_action_enum AS ENUM ('CREATE', 'UPDATE', 'CLOSE', 'VERIFY', 'REVOKE');
EXCEPTION WHEN duplicate_object THEN null; END $$;
