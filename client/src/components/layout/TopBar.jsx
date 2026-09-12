import React from 'react';
import { useApp } from './AppContext';
import { Bell } from 'lucide-react';

export default function TopBar() {
  const {
    mineContext,
    activeShift,
    setActiveShift,
    language,
    setLanguage,
    navCounts,
  } = useApp();

  const shifts = [
    { id: 'A', label: 'A 06-14' },
    { id: 'B', label: 'B 14-22' },
    { id: 'C', label: 'C 22-06' },
  ];

  return (
    <header className="h-12 bg-white border-b border-page-border px-6 flex items-center justify-between sticky top-0 z-20 select-none">
      {/* Left: Datetime & Shift Switcher */}
      <div className="flex items-center gap-4 text-xs text-gray-700">
        <div>
          <span className="font-semibold text-gray-900">{mineContext.currentDateTime}</span>
          <span className="text-gray-500 ml-1">. Shift {activeShift} in hours, ends {mineContext.shiftEndTime}</span>
        </div>

        <div className="flex items-center bg-gray-100 p-0.5 rounded border border-gray-200">
          {shifts.map((s) => (
            <button
              key={s.id}
              onClick={() => setActiveShift(s.id)}
              className={`px-2 py-0.5 text-[11px] rounded transition-all font-medium ${
                activeShift === s.id
                  ? 'bg-white text-gray-900 shadow-xs border border-gray-300 font-semibold'
                  : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              {s.label}
            </button>
          ))}
        </div>
      </div>

      {/* Right: Sync Status + Language Toggle + Notifications */}
      <div className="flex items-center gap-4">
        {/* Sync Status */}
        <div className="flex items-center gap-1.5 text-xs text-gray-600">
          <span className="w-2 h-2 rounded-full bg-emerald-500 inline-block" />
          <span className="text-gray-600 text-[11px]">{mineContext.syncStatus}</span>
        </div>

        {/* Language Toggle */}
        <div className="flex items-center bg-gray-100 rounded border border-gray-300 p-0.5">
          <button
            onClick={() => setLanguage('en')}
            className={`px-2 py-0.5 text-xs rounded font-medium transition-colors ${
              language === 'en'
                ? 'bg-slate-900 text-white font-semibold'
                : 'text-gray-700 hover:text-gray-900'
            }`}
          >
            English
          </button>
          <button
            onClick={() => setLanguage('hi')}
            className={`px-2 py-0.5 text-xs rounded font-medium transition-colors ${
              language === 'hi'
                ? 'bg-slate-900 text-white font-semibold'
                : 'text-gray-700 hover:text-gray-900'
            }`}
          >
            हिन्दी
          </button>
        </div>

        {/* Notification Bell */}
        <button
          type="button"
          className="relative p-1.5 text-gray-600 hover:text-gray-900 hover:bg-gray-100 rounded-md transition-colors"
          aria-label="Notifications"
        >
          <Bell className="w-4 h-4 text-gray-700" />
          {navCounts.notifications > 0 && (
            <span className="absolute -top-1 -right-1 bg-red-600 text-white text-[10px] font-bold rounded-full min-w-[16px] h-4 flex items-center justify-center px-1 shadow-xs">
              {navCounts.notifications}
            </span>
          )}
        </button>
      </div>
    </header>
  );
}
