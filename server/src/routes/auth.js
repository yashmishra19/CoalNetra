import { Router } from 'express';
import { createClient } from '@supabase/supabase-js';
import { supabase } from '../supabase.js';

const router = Router();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

// Creates a client that acts AS the logged-in user, so row-level
// security rules (like "read only your own profile") apply correctly.
function clientForToken(token) {
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
}

router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const { data, error } = await supabase.auth.signInWithPassword({ email, password });
  if (error || !data.session) {
    return res.status(401).json({ error: 'Invalid email or password' });
  }

  const token = data.session.access_token;
  const scoped = clientForToken(token);

  const { data: profile, error: profileError } = await scoped
    .from('users')
    .select('*')
    .eq('id', data.user.id)
    .single();

  if (profileError || !profile) {
    return res.status(403).json({ error: 'No profile found for this account. Contact an administrator.' });
  }

  const safeUser = {
    id: profile.id,
    email: data.user.email,
    name: profile.full_name || data.user.email,
    role: profile.role,
    scopeType: profile.scope_type,
    scopeId: profile.scope_id,
  };

  res.json({ user: safeUser, token });
});

router.get('/me', async (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Not authenticated' });

  const scoped = clientForToken(token);
  const { data: userData, error: userError } = await scoped.auth.getUser(token);
  if (userError || !userData.user) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  const { data: profile, error: profileError } = await scoped
    .from('users')
    .select('*')
    .eq('id', userData.user.id)
    .single();

  if (profileError || !profile) {
    return res.status(403).json({ error: 'No profile found for this account.' });
  }

  const safeUser = {
    id: profile.id,
    email: userData.user.email,
    name: profile.full_name || userData.user.email,
    role: profile.role,
    scopeType: profile.scope_type,
    scopeId: profile.scope_id,
  };

  res.json({ user: safeUser });
});

export default router;