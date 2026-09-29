import dotenv from 'dotenv';
dotenv.config();

import express from 'express';
import cors from 'cors';
import { supabase } from './supabase.js';
import todayRouter from './routes/today.js';
import navRouter from './routes/nav.js';
import regulatorRouter from './routes/regulator.js';
import authRouter from './routes/auth.js';
import complianceRouter from './routes/compliance.js';
import syncRouter from './routes/sync.js';

const app = express();
const PORT = process.env.PORT || 3001;

// ── CORS ──────────────────────────────────────────────────
// In production, restrict to the frontend's Vercel domain.
// Set ALLOWED_ORIGIN in Vercel environment variables.
// In local dev (no ALLOWED_ORIGIN set) we allow everything.
const allowedOrigins = process.env.ALLOWED_ORIGIN
  ? [process.env.ALLOWED_ORIGIN]
  : [];
if (process.env.VERCEL_URL) {
  allowedOrigins.push(`https://${process.env.VERCEL_URL}`);
}

app.use(
  cors(
    allowedOrigins.length > 0
      ? {
          origin: (origin, callback) => {
            // Allow requests with no origin (server-to-server / same-origin)
            if (!origin || allowedOrigins.includes(origin)) {
              callback(null, true);
            } else {
              callback(new Error(`CORS: origin ${origin} not allowed`));
            }
          },
          credentials: true,
        }
      : undefined // no restrictions in local dev
  )
);
app.use(express.json());

// API Routes
app.use('/api/auth', authRouter);
app.use('/api/today', todayRouter);
app.use('/api/nav', navRouter);
app.use('/api/regulator', regulatorRouter);
app.use('/api/sync', syncRouter);
app.use('/api', complianceRouter); // obligations, capas, incidents, directions, mine, observations


// ─── Health check with DB ping ──────────────────────────────────────────────
app.get('/api/health', async (req, res) => {
  const result = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    app: 'KoylaNetra API',
    database: 'unknown',
    demoMode: process.env.DEMO_MODE === 'true',
  };

  try {
    // Quick ping: check database connectivity (fast, doesn't leak data)
    const { error } = await supabase.from('mines').select('count', { count: 'exact', head: true });
    if (error) {
      result.database = 'error';
      result.dbError = error.message;
    } else {
      result.database = 'connected';
    }
  } catch (err) {
    result.database = 'unreachable';
    result.dbError = err.message;
  }

  res.json(result);
});

// Export for Vercel serverless runtime
export default app;

// Only start the HTTP server when running locally (not on Vercel)
if (!process.env.VERCEL) {
  app.listen(PORT, () => {
    console.log(`KoylaNetra API Server running on port ${PORT}`);
  });
}

