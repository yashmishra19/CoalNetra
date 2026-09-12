import { Router } from 'express';

const router = Router();

const mockUsers = [
  { id: 'u1', email: 'mahato@coalgov.in', password: 'mine123', name: 'R. Mahato', role: 'mine_manager', designation: 'Mine Manager', site: 'Sardega OCP', avatar: 'https://i.pravatar.cc/80?img=12' },
  { id: 'u2', email: 'kulkarni@dgms.gov.in', password: 'dgms123', name: 'P.B. Kulkarni', role: 'regulator', designation: 'Director of Mines Safety', region: 'Nagpur Region-2', initials: 'PK' },
  { id: 'u3', email: 'demo@koylanetra.in', password: 'demo', name: 'Demo User', role: 'both', designation: 'Demo Account' }
];

router.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = mockUsers.find(u => u.email === email && u.password === password);
  if (!user) return res.status(401).json({ error: 'Invalid email or password' });
  const { password: _, ...safeUser } = user;
  res.json({ user: safeUser, token: 'mock-jwt-' + user.id });
});

router.get('/me', (req, res) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'Not authenticated' });
  const userId = token.replace('mock-jwt-', '');
  const user = mockUsers.find(u => u.id === userId);
  if (!user) return res.status(401).json({ error: 'Invalid token' });
  const { password: _, ...safeUser } = user;
  res.json({ user: safeUser });
});

export default router;
