DROP INDEX IF EXISTS idx_observations_client_uuid;
CREATE UNIQUE INDEX idx_observations_client_uuid
ON observations (client_uuid);