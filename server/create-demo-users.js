import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
dotenv.config({ path: new URL('./.env', import.meta.url).pathname });
const SUPABASE_URL = process.env.SUPABASE_URL;
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!SUPABASE_URL || !SERVICE_KEY) {
    console.error('Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY in server/.env');
    process.exit(1);
}

const admin = createClient(SUPABASE_URL, SERVICE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
});

const DEMO_MINE_ID = '55555555-5555-5555-5555-555555555501';
const DEMO_REGION_ID = '11111111-1111-1111-1111-111111111101';

const demoUsers = [
    { email: 'mahato@coalgov.in', password: 'mine123', name: 'R. Mahato', role: 'MINE_MANAGER', scope_type: 'MINE', scope_id: DEMO_MINE_ID },
    { email: 'kulkarni@dgms.gov.in', password: 'dgms123', name: 'P.B. Kulkarni', role: 'REGULATOR', scope_type: 'REGION', scope_id: DEMO_REGION_ID },
    { email: 'manager@koylanetra.gov.in', password: 'KoylaManager@2026', name: 'Rajesh Kumar', role: 'MINE_MANAGER', scope_type: 'MINE', scope_id: DEMO_MINE_ID },
    { email: 'regulator@dgms.gov.in', password: 'DgmsRegulator@2026', name: 'Dr. V. K. Sharma', role: 'REGULATOR', scope_type: 'REGION', scope_id: DEMO_REGION_ID },
    { email: 'fo@koylanetra.gov.in', password: 'KoylaField@2026', name: 'B. Oraon', role: 'FIELD_OFFICER', scope_type: 'MINE', scope_id: DEMO_MINE_ID },
];

for (const u of demoUsers) {
    console.log(`Creating ${u.email}...`);

    const { data, error } = await admin.auth.admin.createUser({
        email: u.email,
        password: u.password,
        email_confirm: true,
    });

    if (error) {
        console.error(`  Auth error for ${u.email}:`, error.message);
        continue;
    }

    const { error: profileError } = await admin
        .from('users')
        .upsert({
            id: data.user.id,
            email: u.email,
            full_name: u.name,
            role: u.role,
            scope_type: u.scope_type,
            scope_id: u.scope_id,
        });

    if (profileError) {
        console.error(`  Profile error for ${u.email}:`, profileError.message);
    } else {
        console.log(`  Done: ${u.email} -> ${data.user.id}`);
    }
}

console.log('Finished.');
process.exit(0);