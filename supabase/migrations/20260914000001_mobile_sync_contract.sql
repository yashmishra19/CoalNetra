-- Shared mobile sync contract: idempotent offline observations and grievances.
ALTER TABLE observations ADD COLUMN IF NOT EXISTS client_uuid TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS idx_observations_client_uuid ON observations (client_uuid) WHERE client_uuid IS NOT NULL;

CREATE TABLE IF NOT EXISTS grievances (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_uuid TEXT NOT NULL UNIQUE,
    mine_id UUID NOT NULL REFERENCES mines(id) ON DELETE RESTRICT,
    raised_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    is_anonymous BOOLEAN NOT NULL DEFAULT false,
    lang TEXT NOT NULL DEFAULT 'en',
    raw_text TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'OPEN',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

ALTER TABLE grievances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Grievances select by mine scope" ON grievances FOR SELECT TO authenticated
USING (mine_id = auth_scope_id() OR is_regulator());
CREATE POLICY "Field users insert grievances" ON grievances FOR INSERT TO authenticated
WITH CHECK (mine_id = auth_scope_id());

ALTER PUBLICATION supabase_realtime ADD TABLE observations;
ALTER PUBLICATION supabase_realtime ADD TABLE capas;
ALTER PUBLICATION supabase_realtime ADD TABLE obligations;
ALTER PUBLICATION supabase_realtime ADD TABLE grievances;
