import React from 'react';
import { useNavigate, Navigate } from 'react-router-dom';
import { useAuth } from '../components/auth/AuthContext';
import { HardHat, Shield, ArrowRight } from 'lucide-react';

export default function SelectRole() {
  const { user, loading, logout } = useAuth();
  const navigate = useNavigate();

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#0f172a]">
        <div className="w-8 h-8 border-2 border-white/30 border-t-white rounded-full animate-spin" />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  // Single-role users shouldn't be here
  if (user.role === 'mine_manager') return <Navigate to="/" replace />;
  if (user.role === 'regulator') return <Navigate to="/regulator" replace />;

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#0f172a] flex items-center justify-center p-4 font-sans">
      <div className="bg-white rounded-2xl shadow-2xl w-full max-w-[540px] mx-4 p-8 text-center">
        <h1 className="text-xl font-semibold text-brand-primary">
          Welcome, {user.name}
        </h1>
        <p className="text-[15px] text-status-neutral mt-1">Choose your dashboard</p>

        <div className="mt-8 grid grid-cols-1 sm:grid-cols-2 gap-5">
          {/* Mine Manager Card */}
          <button
            onClick={() => navigate('/')}
            className="border-2 border-page-border rounded-xl p-6 cursor-pointer hover:border-status-warning hover:shadow-lg transition-all group text-center"
          >
            <div className="w-14 h-14 rounded-2xl bg-status-warning-bg flex items-center justify-center mx-auto">
              <HardHat size={28} className="text-status-warning" />
            </div>
            <div className="text-[16px] font-semibold text-brand-primary mt-4">Mine Manager</div>
            <p className="text-[13px] text-status-neutral mt-2 leading-relaxed">
              Operational dashboard for mine statutory post-holders
            </p>
            <div className="mt-4 flex justify-center">
              <ArrowRight size={18} className="text-status-neutral group-hover:text-status-warning group-hover:translate-x-1 transition-all" />
            </div>
          </button>

          {/* Regulator Card */}
          <button
            onClick={() => navigate('/regulator')}
            className="border-2 border-page-border rounded-xl p-6 cursor-pointer hover:border-status-info hover:shadow-lg transition-all group text-center"
          >
            <div className="w-14 h-14 rounded-2xl bg-status-info-bg flex items-center justify-center mx-auto">
              <Shield size={28} className="text-status-info" />
            </div>
            <div className="text-[16px] font-semibold text-brand-primary mt-4">DGMS Regulator</div>
            <p className="text-[13px] text-status-neutral mt-2 leading-relaxed">
              Regional oversight, inspections and compliance monitoring
            </p>
            <div className="mt-4 flex justify-center">
              <ArrowRight size={18} className="text-status-neutral group-hover:text-status-info group-hover:translate-x-1 transition-all" />
            </div>
          </button>
        </div>

        <div className="mt-6">
          <button
            onClick={logout}
            className="text-[14px] text-status-neutral hover:text-status-critical cursor-pointer transition"
          >
            Sign out
          </button>
        </div>
      </div>
    </div>
  );
}
