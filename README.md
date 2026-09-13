# KoylaNetra — Backend Architecture & Statutory Compliance Engine

KoylaNetra is a statutory governance, mine safety, and compliance platform for Indian coal mines built on **Supabase (Postgres 17 + PostGIS)**. It replaces physical statutory registers and manual reporting under the **Coal Mines Regulations (CMR) 2017** and the **Occupational Safety, Health and Working Conditions (OSHWC) Code 2020**.

---

## 1. System Architecture & Three Role Boundaries

```mermaid
flowchart TD
    subgraph Roles["User Roles & Trust Boundaries"]
        FO["👷 Field Officer\n(Mobile / Offline-First / Underground)"]
        MM["🏢 Mine Manager\n(Single Mine Scope / Statutory Liability)"]
        REG["⚖️ DGMS Regulator\n(Geographic Regional Jurisdiction)"]
    end

    subgraph Hierarchy["Hierarchy & Spatial Boundary"]
        REGN["DGMS Region"] --> DIST["District"]
        SUB["Subsidiary (e.g. WCL)"] --> AREA["Area (e.g. Wani)"]
        AREA --> MINE["Mine (Lease Polygon)"]
        DIST --> MINE
        REGN --> MINE
        MINE --> SEC["Sections (QR / NFC Tags)"]
    end

    subgraph DataBoundary["Statutory & Operational Data Layer"]
        OBS["Observations & Photos\n(Geofenced / Tag Validated)"]
        CAPA["CAPAs & After Photos\n(Rule C Maker-Checker)"]
        INC["Incidents (No Worker PII)\n(24h Statutory Clock)"]
        DIR["DGMS Directions &\nProhibition Orders"]
        AUD["Audit Hash Chain\n(Append-Only SHA-256)"]
    end

    subgraph DenialLayer["Rule D Denial Boundary (Zero Policy for Regulators)"]
        RISK["Internal Mine Risk Scores"]
        PROD["Live Shift Production"]
        ATT["Worker Biometric Gate Punches"]
        PII["Incident Worker Injury Details"]
        DRAFT["Draft Inquiry Notes"]
    end

    FO -->|Offline Sync / QR Check-in| OBS
    FO -->|Close Action + After Photos| CAPA
    MM -->|Assign & Maker-Checker Verify| CAPA
    MM -->|Manage Compliance & Returns| MINE
    MM -->|Access Internal Operations| DenialLayer
    REG -->|Geographic Read & Audit| DataBoundary
    REG -->|Issue Notices & Directions| DIR
    REG -.->|BLOCK (Zero RLS Policy)| DenialLayer
```

---

## 2. Non-Negotiable Core Design Rules

### Rule A: Denormalize Scope Onto Every Regulator-Visible Row
Every table accessible to regulators carries:
`mine_id`, `mine_name`, `area_id`, `subsidiary_id`, `district_id`, `dgms_region_id`

- **Write Time**: Auto-populated via database triggers (`BEFORE INSERT`).
- **Hierarchy Evolution**: An `AFTER UPDATE` fan-out trigger (`trg_sync_mine_hierarchy_fanout`) on `mines` propagates any hierarchy reassignments across all downstream tables instantly.

### Rule B: First-Class Provenance
Every regulator-facing record includes:
`provenance text CHECK (provenance IN ('INSPECTOR', 'INSTRUMENT', 'OPERATOR_SEALED', 'OPERATOR_UNSEALED'))`
- `OPERATOR_SEALED`: A cryptographic SHA-256 hash of the row was computed and written to the audit hash chain at creation time.

### Rule C: Maker-Checker on Corrective Actions (CAPAs)
A corrective action closed by one person must be verified by a different person:
1. **Table Constraint**: `CONSTRAINT check_capa_maker_checker CHECK (verified_by IS NULL OR verified_by <> closed_by)`
2. **RLS Policy**: The `UPDATE` policy on `capas` explicitly checks that `closed_by <> auth.uid()` when transitioning status to `VERIFIED`.

### Rule D: Regulator Data Boundary in RLS (Zero-Policy Guarantee)
Regulators possess statutory safety jurisdiction, not commercial or internal management oversight:
- **Zero Policy (Default Deny)** on: `mine_risk_scores`, `production_logs`, `attendance_logs`, `incident_worker_details`, and draft `incident_inquiries`.
- Any query against these tables by a user with role `REGULATOR` returns **0 rows** at the Postgres kernel level.
- `incident_inquiries` provides an RLS policy strictly for `status = 'FINAL'`.

### Rule E: Offline-First for Field Officers
Field officers working in open pits or underground mines experience complete network isolation:
- **Client-Generated UUIDv4 PKs**: Primary keys are generated on device; retries are idempotent and never cause duplicate rows.
- **Dual Timestamps**: `client_created_at` (device clock at inspection) and `server_created_at` (server default `now()`).
- **Independent Records**: Records are valid the moment Postgres receives the insert without relying on prior trigger dependencies.

---

## 3. Database Schema & Migration File Map

| Migration File | Purpose & Contents |
| :--- | :--- |
| `20260913000001_extensions_and_enums.sql` | Enables `postgis`, `pgcrypto`. Defines enums: `user_role`, `scope_type`, `provenance_type`, `capa_status_enum`, `law_status_enum`, etc. |
| `20260913000002_hierarchy_and_identity.sql` | `dgms_regions`, `districts`, `subsidiaries`, `areas`, `mines` (PostGIS `Polygon`), `sections` (QR/NFC tags), `public.users` (1:1 `auth.users`). |
| `20260913000003_statutory_and_operational.sql` | `obligations`, `observations`, `observation_photos`, `capas` (Maker-Checker), `capa_after_photos`, `inspections`, `incidents` (24h window), `incident_worker_details`, `directions`, `direction_targets`, `prohibition_orders`, `audit_logs`. |
| `20260913000004_denial_and_subtables.sql` | Rule-D Denial Tables: `mine_risk_scores`, `production_logs`, `attendance_logs`, `incident_inquiries`. |
| `20260913000005_indexes.sql` | Partial indexes (`capas(due_date) WHERE status='OPEN'`), PostGIS GIST spatial indexes, audit hash-chain indexes, and scope indexes. |
| `20260913000006_rls_helpers.sql` | JWT claim parser functions: `auth_role()`, `auth_scope_id()`, `in_mine_scope()`, `in_region_scope()`. |
| `20260913000007_rls_hierarchy_and_identity.sql` | RLS for reference and identity tables. |
| `20260913000008_rls_operational_and_statutory.sql` | RLS enforcing Rule C Maker-Checker on CAPAs and operational boundaries. |
| `20260913000009_rls_denial_tables.sql` | RLS implementing Zero-Policy denial for Regulators. |
| `20260913000010_triggers_and_functions.sql` | PostGIS Geofence calculation, Scope Fan-out, CAPA SLA due dates, Cryptographic Audit Hash Chain, and Auth App Metadata sync. |
| `20260913000011_materialized_views_and_cron.sql` | Materialized views (`mv_mine_obligation_counts`, `mv_region_incident_counts`), escalation sweeps, and `pg_cron` jobs. |
| `20260913000012_storage_policies.sql` | Private storage bucket `koylanetra-media` and path-based RLS `{mine_id}/{record_type}/{record_id}/{filename}`. |

---

## 4. Per-Role Query Patterns & Index Design

### Field Officer
```sql
-- 1. Idempotent Offline Sync
INSERT INTO observations (id, mine_id, section_id, reported_by, category, severity, checkin_method, device_id, client_created_at, description, provenance)
VALUES ($1, $2, $3, auth.uid(), $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (id) DO UPDATE SET description = EXCLUDED.description
WHERE observations.server_created_at IS NULL;

-- 2. Open Assigned CAPAs (Indexed by owner_id, status, due_date)
SELECT * FROM capas 
WHERE owner_id = auth.uid() AND status = 'OPEN' 
ORDER BY due_date ASC;

-- 3. Offline Section Cache
SELECT tag_code, name, is_underground FROM sections WHERE mine_id = $1;

-- 4. Post-Reconnect Reconciliation (Indexed by device_id, server_created_at)
SELECT id, server_created_at FROM observations 
WHERE device_id = $1 AND server_created_at > $2;
```

### Mine Manager
```sql
-- 1. Pending & Overdue Statutory Obligations (Indexed by mine_id, status, due_date)
SELECT * FROM obligations 
WHERE mine_id = $1 AND status <> 'COMPLETED' 
ORDER BY due_date ASC;

-- 2. Priority CAPA Backlog (Indexed by mine_id, status, escalation_level)
SELECT * FROM capas 
WHERE mine_id = $1 AND status IN ('OPEN', 'ESCALATED') 
ORDER BY escalation_level DESC, due_date ASC;

-- 3. Critical Observations Radar (Indexed by mine_id, severity, server_created_at)
SELECT * FROM observations 
WHERE mine_id = $1 AND severity IN ('HIGH', 'CRITICAL') AND server_created_at > now() - INTERVAL '24 hours';

-- 4. Maker-Checker Verification Mutation
UPDATE capas 
SET status = 'VERIFIED', verified_by = auth.uid(), verified_at = now(), verification_notes = $1 
WHERE id = $2 AND status = 'PENDING_VERIFICATION' AND (closed_by IS NULL OR closed_by <> auth.uid());
```

### DGMS Regulator
```sql
-- 1. Regional Jurisdiction Overview (Indexed by dgms_region_id)
SELECT * FROM mines WHERE dgms_region_id = $1;

-- 2. Serious Accidents & Dangerous Occurrences (Indexed by dgms_region_id, incident_type, occurred_at)
SELECT * FROM incidents 
WHERE dgms_region_id = $1 AND incident_type IN ('FATAL', 'SERIOUS', 'DANGEROUS_OCCURRENCE')
  AND occurred_at BETWEEN $2 AND $3;

-- 3. Active Enforcement Directions
SELECT * FROM directions WHERE issued_by = auth.uid() ORDER BY status, compliance_date;

-- 4. Finalized Statutory Inquiries (Drafts filtered by RLS)
SELECT * FROM incident_inquiries WHERE dgms_region_id = $1 AND status = 'FINAL';
```

---

## 5. Offline Sync & Conflict Resolution Strategy

1. **Client-Side Generation**: Field devices assign UUIDv4 identifiers at observation / CAPA capture time before writing to local SQLite / IndexedDB storage.
2. **Deterministic Hashing**: When capturing photos, the client calculates the SHA-256 checksum immediately upon camera shutter release.
3. **Reconciliation Queue**: Upon reconnecting, the mobile client streams batches of pending mutations. Idempotent upserts ensure that network drops during multi-record sync never cause duplicate entity creation.
4. **Offline Physical Tag Fallback**: Because satellite GPS signals cannot penetrate underground seams, presence is proven by scanning cryptographically signed physical NFC tags or high-contrast laminated QR codes affixed at designated statutory survey stations.

---

## 6. Scalability Analysis: 10x Scale Flags & Mitigations

**Current Design Baseline**: ~50 mines, 500 field users, 5,000 records/day.  
**10x Scaling Target**: 500 mines, 5,000 field users, 50,000 records/day (1.5M records/month).

| Component | 10x Scale Bottleneck | Architectural Mitigation |
| :--- | :--- | :--- |
| **Materialized Views** | `REFRESH MATERIALIZED VIEW CONCURRENTLY` every 5m causes heavy I/O and table lock overhead. | Replace batch MVs with **Trigger-Maintained Real-Time Rollup Tables** or TimescaleDB continuous aggregates. |
| **CAPA Escalation Sweep** | Scanning 50,000 open items across 500 mines via `pg_cron` locks rows and causes update spikes. | Implement **Keyset Pagination in batches of 500**, or offload to an asynchronous background worker queue. |
| **Audit Logs** | Generating ~150,000 immutable rows/day (~4.5M rows/month) degrades B-tree index efficiency. | Implement **Declarative Range Partitioning by Month** on `audit_logs(ts)` with cold storage archiving to S3/Parquet. |
| **PostGIS Spatial Queries** | Dynamic polygon-point containment on high-frequency GPS stream. | Cache spatial containment per survey section; only perform raw PostGIS `ST_Contains` when GPS moves > 50m. |

---

## 7. Migration & Seed Execution Guide

### Applying Migrations via Supabase CLI
```bash
# 1. Start local Supabase instance
supabase start

# 2. Apply all migrations in order
supabase db reset

# 3. Execute automated test suite
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f supabase/tests/rls_and_rules_test.sql
```

### Seeding Demo Data
```bash
# Seed the complete statutory dataset (Demo OCP-1)
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f supabase/seed.sql
```
