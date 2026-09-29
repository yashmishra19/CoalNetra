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
const PORT = process.env.PORT || 5000;

app.use(cors());
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
    // Quick ping: count rows in a known table (fast, doesn't leak data)
    const { error } = await supabase.rpc('get_mine_dashboard', {
      p_mine_id: '55555555-5555-5555-5555-555555555501',
    });
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

app.listen(PORT, () => {
  console.log(`KoylaNetra API Server running on port ${PORT}`);
});
