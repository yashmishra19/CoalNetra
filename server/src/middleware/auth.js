/**
 * requireAuth middleware
 *
 * Validates the Bearer JWT, attaches req.userClient (a Supabase client
 * that runs queries as the logged-in user so Postgres RLS is enforced)
 * and req.authUser (the Supabase auth user object).
 *
 * Usage:
 *   import { requireAuth } from '../middleware/auth.js';
 *   router.get('/my-route', requireAuth, async (req, res) => {
 *     const { data } = await req.userClient.from('...').select('*');
 *   });
 */

import { supabase, createUserClient } from '../supabase.js';

export async function requireAuth(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) {
    return res.status(401).json({ error: 'Authentication required' });
  }

  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) {
    return res.status(401).json({ error: 'Invalid or expired token' });
  }

  req.authUser = user;
  req.accessToken = token;
  req.userClient = createUserClient(token);
  next();
}
