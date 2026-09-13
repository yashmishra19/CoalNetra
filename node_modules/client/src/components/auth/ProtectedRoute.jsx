import React from 'react';
import { Navigate } from 'react-router-dom';
import { useAuth } from './AuthContext';

export default function ProtectedRoute({ children, allowedRoles }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center bg-page-bg">
        <div className="w-8 h-8 border-2 border-status-neutral/30 border-t-status-neutral rounded-full animate-spin" />
        <span className="mt-3 text-[14px] text-status-neutral">Loading...</span>
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // role 'both' can access everything
  if (user.role !== 'both' && !allowedRoles.includes(user.role)) {
    // If user has a single role, send them to their dashboard
    if (user.role === 'mine_manager') return <Navigate to="/" replace />;
    if (user.role === 'regulator') return <Navigate to="/regulator" replace />;
    return <Navigate to="/login" replace />;
  }

  return children;
}
