import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../components/auth/AuthContext';
import { Eye, EyeOff, AlertCircle, HardHat, Shield } from 'lucide-react';

export default function Login() {
  const { login, user, loading: authLoading, error, clearError } = useAuth();
  const navigate = useNavigate();

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const autoSubmitRef = useRef(null);

  // If already logged in, redirect
  useEffect(() => {
    if (!authLoading && user) {
      const role = (user.role || '').toLowerCase();
      if (role === 'mine_manager') navigate('/', { replace: true });
      else if (role === 'regulator') navigate('/regulator', { replace: true });
      else if (role === 'field_officer') navigate('/today', { replace: true });
      else if (role === 'both') navigate('/select-role', { replace: true });
    }
  }, [user, authLoading, navigate]);

  const handleLogin = async (emailVal, passwordVal) => {
    setSubmitting(true);
    const result = await login(emailVal || email, passwordVal || password);
    setSubmitting(false);

    if (result) {
      const role = (result.role || '').toLowerCase();
      if (role === 'mine_manager') navigate('/', { replace: true });
      else if (role === 'regulator') navigate('/regulator', { replace: true });
      else if (role === 'field_officer') navigate('/today', { replace: true });
      else if (role === 'both') navigate('/select-role', { replace: true });
      else navigate('/', { replace: true });
    }
  };

  const handleQuickAccess = (quickEmail, quickPassword) => {
    setEmail(quickEmail);
    setPassword(quickPassword);
    clearError();

    // Clear any pending auto-submit
    if (autoSubmitRef.current) clearTimeout(autoSubmitRef.current);

    autoSubmitRef.current = setTimeout(() => {
      handleLogin(quickEmail, quickPassword);
    }, 300);
  };

  // Cleanup timeout on unmount
  useEffect(() => {
    return () => {
      if (autoSubmitRef.current) clearTimeout(autoSubmitRef.current);
    };
  }, []);

  const handleInputChange = (setter) => (e) => {
    setter(e.target.value);
    if (error) clearError();
  };

  // Show loading while checking auth state
  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#0f172a]">
        <div className="w-8 h-8 border-2 border-white/30 border-t-white rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e293b] to-[#0f172a] flex items-center justify-center p-4 font-sans">
      <div className="bg-white rounded-2xl sm:rounded-2xl shadow-2xl w-full max-w-[440px] overflow-hidden">

        {/* Card Header */}
        <div className="bg-[#0f172a] px-6 sm:px-8 py-8 text-center">
          <h1 className="text-3xl font-bold text-white tracking-tight">KoylaNetra</h1>
          <p className="text-[14px] text-white/60 mt-1">Coal Mine Governance Platform</p>
          <div className="w-16 h-0.5 bg-status-warning mx-auto mt-4 rounded-full" />
        </div>

        {/* Card Body */}
        <div className="px-6 sm:px-8 py-8">
          <h2 className="text-lg font-semibold text-brand-primary mb-6">Sign in to your account</h2>

          {/* Email Field */}
          <div>
            <label className="text-[13px] font-medium text-status-neutral-text mb-1.5 block">
              Email address
            </label>
            <input
              type="email"
              value={email}
              onChange={handleInputChange(setEmail)}
              placeholder="you@example.com"
              className="w-full border border-page-border rounded-lg px-4 py-3 text-[15px] text-brand-primary outline-none transition focus:border-status-info focus:ring-2 focus:ring-status-info/20 placeholder:text-status-neutral/50"
            />
          </div>

          {/* Password Field */}
          <div className="mt-4">
            <label className="text-[13px] font-medium text-status-neutral-text mb-1.5 block">
              Password
            </label>
            <div className="relative">
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={handleInputChange(setPassword)}
                placeholder="Enter your password"
                className="w-full border border-page-border rounded-lg px-4 py-3 pr-12 text-[15px] text-brand-primary outline-none transition focus:border-status-info focus:ring-2 focus:ring-status-info/20 placeholder:text-status-neutral/50"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute right-4 top-1/2 -translate-y-1/2 text-status-neutral cursor-pointer hover:text-brand-primary transition"
                aria-label={showPassword ? 'Hide password' : 'Show password'}
              >
                {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </div>
          </div>

          {/* Error Message */}
          {error && (
            <div className="mt-4 bg-status-critical-bg border border-status-critical-border rounded-lg px-4 py-3 flex items-center gap-2">
              <AlertCircle size={16} className="text-status-critical flex-shrink-0" />
              <span className="text-[14px] text-status-critical-text">{error}</span>
            </div>
          )}

          {/* Sign In Button */}
          <button
            onClick={() => handleLogin()}
            disabled={submitting}
            className={`mt-6 w-full bg-brand-primary text-white font-semibold rounded-lg py-3.5 text-[15px] hover:bg-brand-dark active:scale-[0.98] transition-all cursor-pointer ${
              submitting ? 'opacity-60 cursor-not-allowed' : ''
            }`}
          >
            {submitting ? (
              <span className="flex items-center justify-center gap-2">
                <span className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin inline-block" />
                Signing in...
              </span>
            ) : (
              'Sign in'
            )}
          </button>

          {/* Divider */}
          <div className="mt-6 flex items-center gap-4">
            <span className="flex-1 h-px bg-page-border" />
            <span className="text-[13px] text-status-neutral">or</span>
            <span className="flex-1 h-px bg-page-border" />
          </div>

          {/* Quick Access Hint */}
          <div className="mt-6 p-4 bg-page-bg border border-page-border rounded-lg">
            <p className="text-[12px] text-status-neutral text-center mb-2">Demo accounts available</p>
            <div className="flex flex-col gap-1">
              <p className="text-[12px] text-status-neutral"><HardHat size={12} className="inline mr-1 text-status-warning" />Mine Manager: minemanager@koylanetra.test</p>
              <p className="text-[12px] text-status-neutral"><Shield size={12} className="inline mr-1 text-status-info" />Regulator: regulator@koylanetra.test</p>
              <p className="text-[12px] text-status-neutral"><HardHat size={12} className="inline mr-1 text-status-critical" />Field Officer: fieldofficer@koylanetra.test</p>
            </div>
          </div>
        </div>

        {/* Card Footer */}
        <div className="px-6 sm:px-8 py-4 bg-page-bg border-t border-page-border text-center">
          <p className="text-[11px] text-status-neutral">Government of India · Ministry of Labour and Employment</p>
          <p className="text-[11px] text-status-neutral mt-0.5">Directorate General of Mines Safety</p>
        </div>
      </div>
    </div>
  );
}
