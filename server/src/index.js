import express from 'express';
import cors from 'cors';
import todayRouter from './routes/today.js';
import navRouter from './routes/nav.js';

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// API Routes
app.use('/api/today', todayRouter);
app.use('/api/nav', navRouter);

app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString(), app: 'KoylaNetra API' });
});

app.listen(PORT, () => {
  console.log(`KoylaNetra API Server running on port ${PORT}`);
});
