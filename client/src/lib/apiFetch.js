/**
 * Authenticated fetch helper.
 *
 * Reads the Supabase JWT from localStorage and injects it as
 * Authorization: Bearer <token> on every request to /api/*.
 *
 * Usage:
 *   import { apiFetch } from './apiFetch';
 *   const data = await apiFetch('/api/obligations?mineId=...');
 */

const TOKEN_KEY = 'koylanetra_token';

export async function apiFetch(url, options = {}) {
  const token = localStorage.getItem(TOKEN_KEY);
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {}),
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const res = await fetch(url, { ...options, headers });
  return res;
}
