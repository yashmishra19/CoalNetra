import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AppProvider } from './components/layout/AppContext';
import Today from './pages/Today';
import Compliance from './pages/Compliance';
import InspectionsCapa from './pages/InspectionsCapa';
import Workforce from './pages/Workforce';
import Production from './pages/Production';
import RiskMap from './pages/RiskMap';
import Reports from './pages/Reports';

export default function App() {
  return (
    <AppProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Today />} />
          <Route path="/compliance" element={<Compliance />} />
          <Route path="/inspections-capa" element={<InspectionsCapa />} />
          <Route path="/risk-map" element={<RiskMap />} />
          <Route path="/workforce" element={<Workforce />} />
          <Route path="/production-environment" element={<Production />} />
          <Route path="/reports-approvals" element={<Reports />} />
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AppProvider>
  );
}
