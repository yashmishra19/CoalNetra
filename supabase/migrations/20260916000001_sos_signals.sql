CREATE TABLE IF NOT EXISTS sos_signals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_uuid TEXT NOT NULL UNIQUE,
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    user_name TEXT NOT NULL,
    role TEXT NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    status TEXT NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'CANCELLED')),
    client_created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE INDEX IF NOT EXISTS idx_sos_signals_active_mine
ON sos_signals (mine_id, updated_at DESC)
WHERE status = 'ACTIVE';

ALTER TABLE sos_signals ENABLE ROW LEVEL SECURITY;