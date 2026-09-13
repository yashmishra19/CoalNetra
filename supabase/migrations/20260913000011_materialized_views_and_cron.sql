-- Migration: 20260913000011_materialized_views_and_cron.sql
-- Description: Materialized views for fast executive/regulator KPI counters, and cron jobs for sweeps

/*
========================================================================================
MATERIALIZED VIEW CADENCE & 10X SCALE BREAKDOWN:
- Current proposed cadence: REFRESH MATERIALIZED VIEW CONCURRENTLY every 5 minutes.
- Where this breaks down at 10x scale (500 mines, 50,000 writes/day):
  1. CONCURRENT refresh requires building a complete temporary table snapshot and diffing
     via unique index. At 50,000 rows/day, diff calculation every 5 minutes wastes CPU and I/O.
  2. At 10x scale, migrate from batch materialized views to:
     - Real-time trigger-maintained rollup summary tables (O(1) write cost), OR
     - TimescaleDB Continuous Aggregates / Logical Replication streaming into ClickHouse/Redis.
========================================================================================
*/

-- ========================================================================================
-- 1. Mine Obligation Counts Materialized View (Mine Manager KPI Dashboard)
-- ========================================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_mine_obligation_counts AS
SELECT 
    m.id AS mine_id,
    m.name AS mine_name,
    m.dgms_region_id,
    COUNT(o.id) AS total_obligations,
    COUNT(CASE WHEN o.status = 'PENDING' AND o.due_date >= now() THEN 1 END) AS pending_count,
    COUNT(CASE WHEN o.status = 'OVERDUE' OR (o.status = 'PENDING' AND o.due_date < now()) THEN 1 END) AS overdue_count,
    COUNT(CASE WHEN o.status = 'COMPLETED' THEN 1 END) AS completed_count,
    CASE 
        WHEN COUNT(o.id) = 0 THEN 100.00
        ELSE ROUND((COUNT(CASE WHEN o.status = 'COMPLETED' THEN 1 END)::numeric / COUNT(o.id)::numeric) * 100.0, 2)
    END AS compliance_percentage,
    now() AS last_refreshed_at
FROM mines m
LEFT JOIN obligations o ON o.mine_id = m.id
GROUP BY m.id, m.name, m.dgms_region_id;

-- Unique index required for REFRESH MATERIALIZED VIEW CONCURRENTLY
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_mine_obligation_counts_mine_id 
ON mv_mine_obligation_counts (mine_id);

-- ========================================================================================
-- 2. Region Incident Counts Materialized View (DGMS Regulator Risk Radar)
-- ========================================================================================
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_region_incident_counts AS
SELECT 
    r.id AS dgms_region_id,
    r.name AS region_name,
    t.incident_type,
    COUNT(i.id) AS total_incidents,
    COUNT(CASE WHEN i.occurred_at >= now() - INTERVAL '30 days' THEN 1 END) AS past_30d_count,
    COUNT(CASE WHEN i.occurred_at >= now() - INTERVAL '365 days' THEN 1 END) AS past_365d_count,
    COUNT(CASE WHEN i.within_24h_window = true THEN 1 END) AS compliant_notice_count,
    now() AS last_refreshed_at
FROM dgms_regions r
CROSS JOIN (
    SELECT unnest(enum_range(NULL::incident_type_enum)) AS incident_type
) t
LEFT JOIN incidents i ON i.dgms_region_id = r.id AND i.incident_type = t.incident_type
GROUP BY r.id, r.name, t.incident_type;

-- Unique index required for REFRESH MATERIALIZED VIEW CONCURRENTLY
CREATE UNIQUE INDEX IF NOT EXISTS idx_mv_region_incident_counts_unique 
ON mv_region_incident_counts (dgms_region_id, incident_type);

-- ========================================================================================
-- 3. Maintenance Sweep Functions (CAPA Escalation & Overdue Directions)
-- ========================================================================================
CREATE OR REPLACE FUNCTION perform_capa_escalation_sweep()
RETURNS INT AS $$
DECLARE
    v_updated_count INT;
BEGIN
    -- Escalate overdue open CAPAs (escalation_level + 1)
    WITH overdue_capas AS (
        UPDATE capas
        SET 
            status = 'ESCALATED',
            escalation_level = escalation_level + 1,
            updated_at = now()
        WHERE 
            status IN ('OPEN', 'ESCALATED') AND 
            due_date < now()
        RETURNING id
    )
    SELECT COUNT(*) INTO v_updated_count FROM overdue_capas;

    -- Mark overdue directions
    UPDATE directions
    SET status = 'OVERDUE', updated_at = now()
    WHERE status = 'ISSUED' AND compliance_date < now();

    RETURN v_updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION refresh_koylanetra_materialized_views()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_mine_obligation_counts;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_region_incident_counts;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ========================================================================================
-- 4. pg_cron Job Scheduling (Every 15 min for escalation, Every 5 min for MVs)
-- Conditional block that activates if pg_cron is installed
-- ========================================================================================
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
        -- Schedule 15-minute CAPA escalation sweep
        PERFORM cron.schedule(
            'koylanetra_capa_escalation_sweep',
            '*/15 * * * *',
            'SELECT perform_capa_escalation_sweep();'
        );

        -- Schedule 5-minute Materialized View concurrent refresh
        PERFORM cron.schedule(
            'koylanetra_mv_refresh',
            '*/5 * * * *',
            'SELECT refresh_koylanetra_materialized_views();'
        );
    END IF;
EXCEPTION WHEN OTHERS THEN
    -- In environments without pg_cron privileges, ignore extension error
    NULL;
END $$;
