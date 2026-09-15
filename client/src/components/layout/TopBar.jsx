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
    <header className="px-6 py-3.5 bg-white border-b border-page-border flex items-center justify-between sticky top-0 z-20 select-none flex-wrap gap-3">
      {/* Left: Datetime & Shift Switcher */}
      <div className="flex items-center gap-4 text-xs text-brand-primary flex-wrap">
        <div>
          <span className="font-semibold text-brand-primary">{mineContext.currentDateTime}</span>
          <span className="text-status-neutral ml-1">. Shift {activeShift} in hours, ends {mineContext.shiftEndTime}</span>
        </div>

        <div className="flex items-center bg-page-bg p-0.5 rounded-lg border border-page-border">
          {shifts.map((s) => (
            <button
              key={s.id}
              onClick={() => setActiveShift(s.id)}
              className={`px-2.5 py-1 text-[12px] rounded-md transition-all font-medium cursor-pointer ${
                activeShift === s.id
                  ? 'bg-white text-brand-primary shadow-xs border border-page-border font-semibold'
                  : 'text-status-neutral hover:text-brand-primary'
              }`}
            >
              {s.label}
            </button>
          ))}
        </div>
      </div>

      {/* Right: Sync Status + Language Toggle + Notifications */}
      <div className="flex items-center gap-4 flex-wrap">
        {/* Sync Status */}
        <div className="flex items-center gap-1.5 text-xs text-status-neutral">
          <span className="w-2 h-2 rounded-full bg-status-good inline-block" />
          <span className="text-status-neutral text-[12px]">{mineContext.syncStatus}</span>
        </div>

        {/* Language Toggle */}
        <div className="inline-flex rounded-lg overflow-hidden border border-page-border">
          <button
            onClick={() => setLanguage('en')}
            className={`px-3 py-1.5 text-[12px] font-medium cursor-pointer transition-colors ${
              language === 'en'
                ? 'bg-brand-primary text-white'
                : 'bg-white text-brand-primary hover:bg-page-bg'
            }`}
          >
            English
          </button>
          <button
            onClick={() => setLanguage('hi')}
            className={`px-3 py-1.5 text-[12px] font-medium cursor-pointer transition-colors ${
              language === 'hi'
                ? 'bg-brand-primary text-white'
                : 'bg-white text-brand-primary hover:bg-page-bg'
            }`}
          >
            हिन्दी
          </button>
        </div>

        {/* Notification Bell */}
        <button
          type="button"
          className="relative p-1.5 text-status-neutral hover:text-brand-primary hover:bg-page-bg rounded transition-colors cursor-pointer"
          aria-label="Notifications"
        >
          <Bell size={18} className="text-status-neutral" />
          {navCounts.notifications > 0 && (
            <span className="w-2.5 h-2.5 bg-status-critical rounded-full absolute -top-0.5 -right-0.5 border-2 border-white" />
          )}
        </button>
      </div>
    </header>
  );
}

