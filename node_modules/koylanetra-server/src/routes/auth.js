import { Router } from 'express';
import { supabase, createUserClient } from '../supabase.js';

const router = Router();

// ── POST /api/auth/login ──────────────────────────────────────────────────────
// Signs in with Supabase Auth (email + password).
// Returns the Supabase JWT access token + user profile from public.users.
router.post('/login', async (req, res) => {
  const { email, password } = req.body || {};
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  // 1. Sign in with Supabase Auth
  const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (authError || !authData?.session) {
    return res.status(401).json({ error: authError?.message || 'Invalid email or password' });
  }

  const { session, user: authUser } = authData;

  // 2. Fetch the app profile from public.users using the user's own token (RLS applies)
  const userClient = createUserClient(session.access_token);
  const { data: profile, error: profileError } = await userClient
    .from('users')
    .select('id, email, full_name, role, designation, mine_id, region_id')
    .eq('id', authUser.id)
    .single();

  if (profileError || !profile) {
    // Profile might not exist yet — return a minimal user object
    console.warn('Profile not found for', authUser.id, profileError?.message);
    const minimalUser = {
      id: authUser.id,
      email: authUser.email,
      full_name: authUser.email,
      role: 'field_officer',
      designation: '',
      mine_id: null,
      region_id: null,
    };
    return res.json({ user: minimalUser, token: session.access_token });
  }

  return res.json({ user: profile, token: session.access_token });
});

// ── GET /api/auth/me ──────────────────────────────────────────────────────────
// Validates the Bearer token and returns the user profile.
router.get('/me', async (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Not authenticated' });

  // Verify the token by calling Supabase
  const { data: { user: authUser }, error } = await supabase.auth.getUser(token);
  if (error || !authUser) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }

  // Fetch profile using the user's own token
  const userClient = createUserClient(token);
  const { data: profile, error: profileError } = await userClient
    .from('users')
    .select('id, email, full_name, role, designation, mine_id, region_id')
    .eq('id', authUser.id)
    .single();

  if (profileError || !profile) {
    return res.json({
      user: {
        id: authUser.id,
        email: authUser.email,
        full_name: authUser.email,
        role: 'field_officer',
        designation: '',
        mine_id: null,
        region_id: null,
      },
    });
  }

  return res.json({ user: profile });
});

export default router;
