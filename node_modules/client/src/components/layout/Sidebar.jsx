import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { navItems } from '../../routes';
import { useApp } from './AppContext';
import { useAuth } from '../auth/AuthContext';
import { Flame } from 'lucide-react';

export default function Sidebar() {
  const location = useLocation();
  const { mineContext, navCounts } = useApp();
  const { logout } = useAuth();

  return (
    <aside className="fixed left-0 top-0 h-screen w-[220px] bg-[#0f1218] text-gray-300 flex flex-col z-30 overflow-y-auto border-r border-[#1e2330] select-none">
      {/* Brand Header */}
      <div className="px-4 pt-4 pb-3">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded bg-amber-500 flex items-center justify-center text-slate-950 font-black shadow-sm shrink-0">
            <Flame className="w-4 h-4 fill-slate-950 stroke-amber-500" />
          </div>
          <div className="min-w-0">
            <div className="text-white font-bold text-base tracking-tight leading-tight truncate">
              KoylaNetra
            </div>
            <div className="text-[11px] text-gray-400 leading-none mt-0.5 truncate">
              Mine governance
            </div>
          </div>
        </div>

        {/* Active Mine Selector Box */}
        <div className="mt-4 bg-[#181d28] border border-[#262e40] rounded-md p-2.5">
          <div className="text-[10px] uppercase font-semibold tracking-wider text-gray-400 leading-tight">
            Your mine
          </div>
          <div className="text-white font-bold text-[13px] leading-tight mt-0.5 truncate">
            {mineContext.name}
          </div>
          <div className="text-[11px] text-gray-400 leading-tight mt-0.5 truncate">
            {mineContext.area}
          </div>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-2 py-2 space-y-1">
        {navItems.map((item) => {
          const isActive =
            item.path === '/'
              ? location.pathname === '/'
              : location.pathname.startsWith(item.path);

          const count = navCounts[item.badgeKey];
          const Icon = item.icon;

          return (
            <Link
              key={item.key}
              to={item.path}
              className={`flex items-center justify-between px-5 h-11 text-[14px] transition-colors group rounded-md ${
                isActive
                  ? 'bg-[#1c2230] text-white font-semibold border-l-[3px] border-l-amber-500 shadow-xs'
                  : 'text-gray-300 hover:text-white hover:bg-[#1c2230]'
              }`}
            >
              <div className="flex items-center gap-3 min-w-0">
                <Icon
                  size={18}
                  className={`shrink-0 ${
                    isActive ? 'text-white' : 'text-gray-400 group-hover:text-gray-200'
                  }`}
                />
                <span className="truncate">{item.label}</span>
              </div>

              {count > 0 && (
                <span
                  className="text-[11px] font-bold rounded-full w-4 h-4 flex items-center justify-center shrink-0 bg-red-600 text-white ml-auto"
                >
                  {count}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* User Profile Footer */}
      <div className="mt-auto border-t border-[#1e2330] px-5 py-4">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 rounded-full bg-[#2a3447] text-gray-200 text-[13px] font-bold flex items-center justify-center border border-[#3a4760] shrink-0">
            {mineContext.user?.initials || 'RM'}
          </div>
          <div className="min-w-0">
            <div className="text-[14px] font-medium text-white truncate leading-snug">
              {mineContext.user?.name || 'R. K. Mehato'}
            </div>
            <div className="text-[12px] text-gray-400 truncate leading-snug">
              {mineContext.user?.role || 'Mine Manager'}
            </div>
          </div>
        </div>
        <button
          onClick={logout}
          className="text-[11px] text-gray-400 hover:text-white cursor-pointer transition mt-2 text-left block"
        >
          Sign out
        </button>
      </div>
    </aside>
  );
}
