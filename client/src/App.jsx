import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './components/auth/AuthContext';
import { AppProvider } from './components/layout/AppContext';
import ProtectedRoute from './components/auth/ProtectedRoute';
import Login from './pages/Login';
import SelectRole from './pages/SelectRole';
import Today from './pages/Today';
import Compliance from './pages/Compliance';
import InspectionsCapa from './pages/InspectionsCapa';
import Workforce from './pages/Workforce';
import Production from './pages/Production';
import RiskMap from './pages/RiskMap';
import Reports from './pages/Reports';
import RegulatorShell from './components/regulator/RegulatorShell';
import RegulatorDashboard from './pages/regulator/RegulatorDashboard';
import MinesRegister from './pages/regulator/MinesRegister';
import Inspections from './pages/regulator/Inspections';
import Directions from './pages/regulator/Directions';
import Accidents from './pages/regulator/Accidents';
import Permissions from './pages/regulator/Permissions';
import Assurance from './pages/regulator/Assurance';

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          {/* Public Routes */}
          <Route path="/login" element={<Login />} />

          {/* Role Selection (any authenticated user) */}
          <Route path="/select-role" element={<SelectRole />} />

          {/* Mine Manager Routes */}
          <Route
            path="/"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><Today /></AppProvider>
              </ProtectedRoute>
            }
          />
          <Route
            path="/compliance"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><Compliance /></AppProvider>
              </ProtectedRoute>
            }
          />
          <Route
            path="/inspections-capa"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><InspectionsCapa /></AppProvider>
              </ProtectedRoute>
            }
          />
          <Route
            path="/risk-map"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><RiskMap /></AppProvider>
              </ProtectedRoute>
            }
          />
          <Route
            path="/workforce"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><Workforce /></AppProvider>
              </ProtectedRoute>
            }
          />
          <Route
            path="/production-environment"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><Production /></AppProvider>
              </ProtectedRoute>
            }
          />
          <Route
            path="/reports-approvals"
            element={
              <ProtectedRoute allowedRoles={['mine_manager', 'both']}>
                <AppProvider><Reports /></AppProvider>
              </ProtectedRoute>
            }
          />

          {/* Regulator Routes */}
          <Route
            path="/regulator"
            element={
              <ProtectedRoute allowedRoles={['regulator', 'both']}>
                <RegulatorShell />
              </ProtectedRoute>
            }
          >
            <Route index element={<RegulatorDashboard />} />
            <Route path="mines-register" element={<MinesRegister />} />
            <Route path="inspections" element={<Inspections />} />
            <Route path="directions" element={<Directions />} />
            <Route path="accidents" element={<Accidents />} />
            <Route path="permissions" element={<Permissions />} />
            <Route path="assurance" element={<Assurance />} />
          </Route>

          {/* Catch-all */}
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
