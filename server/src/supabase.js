import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('SUPABASE_URL and SUPABASE_ANON_KEY must be set in server/.env');
}

/**
 * Anon client — used only for auth.signInWithPassword().
 * All other queries go through createUserClient() so RLS is enforced.
 */
export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { autoRefreshToken: false, persistSession: false },
});

/**
 * Returns a Supabase client authenticated as the logged-in user.
 * Passes the user's JWT so Postgres RLS sees auth.uid() correctly.
 *
 * @param {string} accessToken  — the JWT from supabase.auth.signInWithPassword
 */
export function createUserClient(accessToken) {
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
    global: {
      headers: { Authorization: `Bearer ${accessToken}` },
    },
  });
}
