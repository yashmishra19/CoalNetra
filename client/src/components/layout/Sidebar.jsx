import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { navItems } from '../../routes';
import { useApp } from './AppContext';
import { Flame } from 'lucide-react';

export default function Sidebar() {
  const location = useLocation();
  const { mineContext, navCounts } = useApp();

  return (
    <aside className="w-[230px] bg-[#0f1218] text-gray-300 flex flex-col shrink-0 min-h-screen border-r border-[#1e2330] select-none">
      {/* Brand Header */}
      <div className="px-4 pt-4 pb-3">
        <div className="flex items-center gap-2">
          <div className="w-6 h-6 rounded bg-amber-500 flex items-center justify-center text-slate-950 font-black shadow-sm">
            <Flame className="w-4 h-4 fill-slate-950 stroke-amber-500" />
          </div>
          <div>
            <div className="text-white font-bold text-base tracking-tight leading-tight flex items-center gap-1">
              KoylaNetra
            </div>
            <div className="text-[11px] text-gray-400 leading-none mt-0.5">
              Mine governance
            </div>
          </div>
        </div>

        {/* Active Mine Selector Box */}
        <div className="mt-4 bg-[#181d28] border border-[#262e40] rounded-md p-2.5">
          <div className="text-[10px] uppercase font-semibold tracking-wider text-gray-400 leading-tight">
            Your mine
          </div>
          <div className="text-white font-bold text-[13px] leading-tight mt-0.5">
            {mineContext.name}
          </div>
          <div className="text-[11px] text-gray-400 leading-tight mt-0.5">
            {mineContext.area}
          </div>
        </div>
      </div>

      {/* Navigation Links */}
      <nav className="flex-1 px-2 py-2 space-y-0.5">
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
              className={`flex items-center justify-between px-3 py-2 rounded-md text-[13px] transition-colors group ${
                isActive
                  ? 'bg-white text-gray-900 font-semibold shadow-sm'
                  : 'text-gray-300 hover:text-white hover:bg-[#1c2230]'
              }`}
            >
              <div className="flex items-center gap-2.5 min-w-0">
                <Icon
                  className={`w-4 h-4 shrink-0 ${
                    isActive ? 'text-gray-900 stroke-[2.2]' : 'text-gray-400 group-hover:text-gray-200'
                  }`}
                />
                <span className="truncate">{item.label}</span>
              </div>

              {count > 0 && (
                <span
                  className={`text-[11px] font-bold rounded-full w-4 h-4 flex items-center justify-center shrink-0 ${
                    isActive
                      ? 'bg-red-600 text-white'
                      : 'bg-red-600 text-white'
                  }`}
                >
                  {count}
                </span>
              )}
            </Link>
          );
        })}
      </nav>

      {/* User Profile Footer */}
      <div className="p-3 border-t border-[#1e2330] mt-auto">
        <div className="flex items-center gap-2.5 px-1 py-1">
          <div className="w-8 h-8 rounded-full bg-[#2a3447] text-gray-200 text-xs font-bold flex items-center justify-center border border-[#3a4760] shrink-0">
            {mineContext.user?.initials || 'RM'}
          </div>
          <div className="min-w-0 flex-1">
            <div className="text-[13px] font-semibold text-white truncate leading-snug">
              {mineContext.user?.name || 'R. K. Mehato'}
            </div>
            <div className="text-[11px] text-gray-400 truncate leading-snug">
              {mineContext.user?.role || 'Mine Manager'}
            </div>
          </div>
        </div>
      </div>
    </aside>
  );
}
