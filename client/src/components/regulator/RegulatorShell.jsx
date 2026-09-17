import React, { useState } from 'react';
import { Outlet, NavLink } from 'react-router-dom';
import { useAuth } from '../auth/AuthContext';
import {
  LayoutGrid,
  Database,
  Search,
  ArrowRightCircle,
  AlertOctagon,
  FileCheck,
  Shield,
  ChevronDown,
  Bell,
  Menu,
  X
} from 'lucide-react';

export default function RegulatorShell() {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);
  const { logout } = useAuth();

  const navItems = [
    { label: 'Region view', path: '/regulator', end: true, icon: LayoutGrid, count: null },
    { label: 'Mines register', path: '/regulator/mines-register', end: false, icon: Database, count: null },
    { label: 'Inspections', path: '/regulator/inspections', end: false, icon: Search, count: 19, tone: 'critical' },
    { label: 'Directions', path: '/regulator/directions', end: false, icon: ArrowRightCircle, count: 19, tone: 'critical' },
    { label: 'Accidents & inquiries', path: '/regulator/accidents', end: false, icon: AlertOctagon, count: 2, tone: 'critical' },
    { label: 'Permissions', path: '/regulator/permissions', end: false, icon: FileCheck, count: 9, tone: 'warning' },
    { label: 'Assurance & reporting', path: '/regulator/assurance', end: false, icon: Shield, count: null },
  ];

  return (
    <div className="min-h-screen bg-page-bg flex flex-col relative font-sans text-brand-primary">
      {/* Mobile Overlay */}
      {isMobileMenuOpen && (
        <div
          className="fixed inset-0 bg-black/50 z-20 md:hidden"
          onClick={() => setIsMobileMenuOpen(false)}
        />
      )}

      {/* SIDEBAR (Dark Navy Theme #1A2332) */}
      <aside
        className={`fixed top-0 left-0 h-screen w-[220px] bg-[#1A2332] text-slate-300 flex flex-col z-30 overflow-y-auto transition-transform duration-300 ease-in-out shadow-xl border-r border-[#26334A]/50 ${
          isMobileMenuOpen ? 'translate-x-0' : '-translate-x-full md:translate-x-0'
        }`}
      >
        {/* Header Block */}
        <div className="px-5 pt-4 pb-2 relative">
          <button
            className="md:hidden absolute top-4 right-4 text-slate-400 hover:text-white"
            onClick={() => setIsMobileMenuOpen(false)}
            aria-label="Close menu"
          >
            <X size={18} />
          </button>
          <div className="text-[10px] text-slate-400 leading-tight">
            Government of India · Ministry of Labour
          </div>
          <div className="text-[10px] text-slate-400">
            and Employment
          </div>
          <div className="text-[11px] font-medium text-slate-300 mt-0.5">
            Directorate General of Mines Safety
          </div>

          <div className="mt-4">
            <h1 className="text-xl font-bold text-white leading-none">KoylaNetra</h1>
            <div className="text-[12px] text-slate-400 mt-0.5">Regulator view</div>
          </div>
        </div>

        {/* Jurisdiction Info Block */}
        <div className="mx-4 mt-4 bg-[#202B3D] border border-[#2B384E] rounded-lg p-3">
          <div className="text-[10px] uppercase tracking-wider font-semibold text-slate-400">
            Your jurisdiction
          </div>
          <div className="text-[14px] font-semibold text-white mt-1 truncate">
            Nagpur Region-2
          </div>
          <div className="text-[12px] text-slate-300 mt-0.5 leading-snug">
            Western Zone · 6 districts · 118 mines
          </div>
        </div>

        {/* Nav List */}
        <nav className="mt-5 flex-1 space-y-1 px-2">
          {navItems.map((item) => {
            const Icon = item.icon;
            return (
              <NavLink
                key={item.label}
                to={item.path}
                end={item.end}
                onClick={() => setIsMobileMenuOpen(false)}
                className={({ isActive }) =>
                  `w-full flex items-center justify-between px-5 h-11 text-[14px] transition-colors cursor-pointer rounded-md ${
                    isActive
                      ? 'font-semibold text-white bg-[#26334A] border-l-[3px] border-l-blue-500 shadow-sm'
                      : 'text-slate-300 hover:text-white hover:bg-[#202B3D]'
                  }`
                }
              >
                {({ isActive }) => (
                  <>
                    <div className="flex items-center gap-3 min-w-0">
                      <Icon size={18} className={`shrink-0 ${isActive ? 'text-white' : 'text-slate-400'}`} />
                      <span className="truncate">{item.label}</span>
                    </div>
                    {item.count !== null && (
                      <span className={`min-w-[20px] h-[20px] px-1.5 rounded-full flex items-center justify-center text-[11px] font-bold text-white shrink-0 ${
                        item.tone === 'warning' ? 'bg-[#D97706]' : 'bg-[#E5484D]'
                      } ml-auto`}>
                        {item.count}
                      </span>
                    )}
                  </>
                )}
              </NavLink>
            );
          })}
        </nav>

        {/* Footer / User Info */}
        <div className="mt-auto border-t border-[#26334A] px-5 py-4">
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-full bg-teal-700 text-white text-[13px] font-semibold flex items-center justify-center shrink-0">
              PK
            </div>
            <div className="min-w-0">
              <div className="text-[14px] font-medium text-white truncate">P.B. Kulkarni</div>
              <div className="text-[12px] text-slate-400 leading-tight mt-0.5 truncate">Director of Mines Safety</div>
            </div>
          </div>
          <button
            onClick={logout}
            className="text-[11px] text-slate-400 hover:text-slate-200 cursor-pointer transition mt-2 text-left block"
          >
            Sign out
          </button>
        </div>
      </aside>

      {/* MAIN CONTENT AREA (Kept light background) */}
      <div className="md:ml-[220px] min-h-screen bg-page-bg flex flex-col">
        {/* TOPBAR */}
        <header className="px-6 py-3.5">
          {/* Filter Row */}
          <div className="flex items-center justify-between flex-wrap gap-3">
            {/* Left controls */}
            <div className="flex items-center gap-2 flex-wrap">
              <button
                className="md:hidden p-1.5 bg-white border border-page-border rounded text-brand-primary hover:bg-page-bg transition mr-1"
                onClick={() => setIsMobileMenuOpen(true)}
                aria-label="Open sidebar menu"
              >
                <Menu size={18} />
              </button>
              <span className="text-[13px] text-status-neutral">Jurisdiction</span>
              {['All India', 'Nagpur Region-2', 'Chandrapur', 'Calendar 2026'].map((filterVal) => (
                <button
                  key={filterVal}
                  className="bg-white border border-page-border rounded-lg px-3 py-1.5 text-[13px] text-brand-primary font-medium inline-flex items-center gap-1.5 cursor-pointer hover:border-status-neutral transition"
                >
                  <span>{filterVal}</span>
                  <ChevronDown size={13} className="text-status-neutral" />
                </button>
              ))}
            </div>

            {/* Right controls */}
            <div className="flex items-center gap-3">
              {/* Feed Status */}
              <div className="flex items-center gap-2">
                <span className="w-2 h-2 rounded-full bg-status-good"></span>
                <span className="text-[12px] text-status-neutral">Statutory feed current to 10 Sep 16:00</span>
              </div>

              {/* Language Toggle */}
              <div className="inline-flex rounded-lg overflow-hidden border border-page-border">
                <button className="bg-brand-primary text-white px-3 py-1.5 text-[12px] font-medium">
                  English
                </button>
                <button className="bg-white text-brand-primary px-3 py-1.5 text-[12px]">
                  हिन्दी
                </button>
              </div>

              {/* Bell Notification */}
              <button className="relative p-1.5 text-status-neutral hover:bg-white rounded transition" aria-label="Notifications">
                <Bell size={18} className="text-status-neutral" />
                <span className="w-2.5 h-2.5 bg-status-critical rounded-full absolute -top-0.5 -right-0.5 border-2 border-white" />
              </button>
            </div>
          </div>

          {/* Title Section */}
          <div className="mt-5 flex items-center justify-between flex-wrap gap-4">
            <div className="max-w-[700px]">
              <h2 className="text-[26px] font-bold text-brand-primary tracking-tight">
                Nagpur Region-2, September 2026
              </h2>
              <p className="mt-1 mb-2 text-[14px] text-status-neutral leading-relaxed">
                All mines in six districts, whoever operates them. This office sees statutory submissions, its own inspection findings and aggregate trends. It does not receive an operational feed.
              </p>
            </div>
            <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap w-full sm:w-auto">
              <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition text-center w-full sm:w-auto">
                Monthly return to Zone
              </button>
              <button className="bg-brand-primary text-white rounded-lg px-4 py-2.5 text-[13px] font-semibold hover:bg-brand-dark transition text-center w-full sm:w-auto">
                Plan next month's inspections
              </button>
            </div>
          </div>
        </header>

        {/* PAGE CONTENT */}
        <main className="px-6 pb-12 flex-1">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

