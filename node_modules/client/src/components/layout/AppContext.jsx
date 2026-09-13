import React, { createContext, useContext, useState, useEffect } from 'react';
import { getNavCounts, getMineContext } from '../../lib/apiNav';

const AppContext = createContext(null);

export function AppProvider({ children }) {
  const [mineContext, setMineContext] = useState({
    id: 'ocp-1',
    name: 'Demo OCP-1',
    area: 'Sonpur Area, opencast',
    shift: 'B',
    shiftTimes: '14:22',
    shiftEndTime: '22:00',
    currentDateTime: 'Thu 12 Sep 2024, 16:20',
    syncStatus: 'Synced 2 min ago, 3 field records queued',
    user: {
      name: 'R. K. Mehato',
      role: 'Mine Manager',
      initials: 'RM',
    },
  });

  const [activeShift, setActiveShift] = useState('B');
  const [language, setLanguage] = useState('en'); // 'en' | 'hi'
  const [navCounts, setNavCounts] = useState({
    today: 0,
    compliance: 8,
    inspectionsCapa: 6,
    riskMap: 0,
    workforce: 0,
    production: 0,
    reports: 4,
    notifications: 10,
  });

  useEffect(() => {
    getNavCounts().then(setNavCounts);
    getMineContext().then((ctx) => {
      setMineContext(ctx);
      setActiveShift(ctx.shift || 'B');
    });
  }, []);

  return (
    <AppContext.Provider
      value={{
        mineContext,
        setMineContext,
        activeShift,
        setActiveShift,
        language,
        setLanguage,
        navCounts,
        setNavCounts,
      }}
    >
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
}
