# Mobile Demo Sync

The mobile app reads the seeded demo records through the API. Offline observation and statutory-rule changes are kept in the phone's SQLite database and remain pending until the server accepts them.

To enable writes for a trusted local demo only, configure the server environment (the existing `.env` file is not committed):

```env
DEMO_MODE=true
SUPABASE_SERVICE_ROLE_KEY=<service-role-key>
```

Keep `SUPABASE_SERVICE_ROLE_KEY` on the server. Never put it in Flutter, a `--dart-define`, a checked-in file, or a client build. The sync endpoint is intentionally disabled unless `DEMO_MODE=true` and the server key is configured. This demo gate is not a production authentication system; do not expose this service-role-backed demo API to an untrusted network.

Run the API from this directory with `npm start`. For a physical Android device, run Flutter from `mobile_app` and set `API_BASE_URL` to the computer's reachable LAN address, for example `http://192.168.1.20:5000`. Keep the phone and computer on a network that permits device-to-device traffic.

Apply the pending SQL migrations in `supabase/migrations` before enabling sync. Sync pushes observations, grievances, obligation edits, and SOS signals. The SOS table accepts an idempotent client UUID, latest GPS coordinates, and active/cancelled status; connected clients poll active signals for the same demo mine. SOS records remain queued on the phone until an accepted response arrives.

This API path is network delivery only. It does not implement BLE discovery/mesh, Android Find Hub / Find My Device network participation, voice/radio communication, or emergency-service dispatch. Google's crowdsourced tracker network is not an open general-purpose API for arbitrary app signals or user-location beacons. Direct BLE proximity discovery is a separate Android feature requiring runtime Bluetooth permissions and on-device testing; it cannot depend on the crowdsourced tracker network.

Document metadata/storage/OCR are still not connected to this API.
