import { Router } from 'express';

const router = Router();

// Nav badge counts
router.get('/counts', (req, res) => {
  res.json({
    today: 0,
    compliance: 8,
    inspectionsCapa: 6,
    riskMap: 0,
    workforce: 0,
    production: 0,
    reports: 4,
    notifications: 10
  });
});

export default router;
