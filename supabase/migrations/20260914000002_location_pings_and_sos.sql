-- Location pings table for real-time tracking of mine staff
CREATE TABLE IF NOT EXISTS location_pings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_uuid TEXT NOT NULL UNIQUE,
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE CASCADE,
    reported_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    role TEXT NOT NULL DEFAULT 'sirdar',
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION,
    location_confidence TEXT NOT NULL DEFAULT 'gps_live',
    captured_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- SOS events table for emergency mesh alerts
CREATE TABLE IF NOT EXISTS sos_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_uuid TEXT NOT NULL UNIQUE,
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE CASCADE,
    triggered_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    role TEXT NOT NULL DEFAULT 'sirdar',
    user_name TEXT,
    lat DOUBLE PRECISION,
    lng DOUBLE PRECISION,
    location_confidence TEXT NOT NULL DEFAULT 'unknown',
    sent_via_channel TEXT NOT NULL DEFAULT 'cellular',
    mesh_relayed_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    triggered_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_location_pings_mine_captured ON location_pings(mine_id, captured_at DESC);
CREATE INDEX IF NOT EXISTS idx_sos_events_mine_triggered ON sos_events(mine_id, triggered_at DESC);

-- Enable RLS
ALTER TABLE location_pings ENABLE ROW LEVEL SECURITY;
ALTER TABLE sos_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Location pings select by mine scope" ON location_pings FOR SELECT TO authenticated
USING (mine_id = auth_scope_id() OR is_regulator());
CREATE POLICY "Field users insert location pings" ON location_pings FOR INSERT TO authenticated
WITH CHECK (mine_id = auth_scope_id());

CREATE POLICY "SOS events select by mine scope" ON sos_events FOR SELECT TO authenticated
USING (mine_id = auth_scope_id() OR is_regulator());
CREATE POLICY "Field users insert SOS events" ON sos_events FOR INSERT TO authenticated
WITH CHECK (mine_id = auth_scope_id());

-- Add to Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE location_pings;
ALTER PUBLICATION supabase_realtime ADD TABLE sos_events;
