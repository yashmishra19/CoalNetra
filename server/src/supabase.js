import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY;

export const supabase = createClient(
  SUPABASE_URL || 'http://localhost:54321',
  SUPABASE_ANON_KEY || 'anon-key'
);

export const supabaseAdmin = createClient(
  SUPABASE_URL || 'http://localhost:54321',
  SUPABASE_SERVICE_ROLE_KEY || SUPABASE_ANON_KEY || 'anon-key',
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  }
);

export function createUserClient(token) {
  return createClient(
    SUPABASE_URL || 'http://localhost:54321',
    SUPABASE_ANON_KEY || 'anon-key',
    {
      global: { headers: { Authorization: `Bearer ${token}` } },
      auth: { autoRefreshToken: false, persistSession: false },
    }
  );
}

