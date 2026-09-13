import React from 'react';
import Card from './Card';
import { ChevronRight } from 'lucide-react';

export default function CalendarMonth({
  month = 'September 2026',
  onNextMonth,
  className = '',
}) {
  const weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  const days = [
    { day: 31, isCurrent: false },
    { day: 1, isCurrent: true, dots: ['good'] },
    { day: 2, isCurrent: true },
    { day: 3, isCurrent: true, dots: ['good'] },
    { day: 4, isCurrent: true },
    { day: 5, isCurrent: true, dots: ['good'] },
    { day: 6, isCurrent: true },
    { day: 7, isCurrent: true },
    { day: 8, isCurrent: true, dots: ['good'] },
    { day: 9, isCurrent: true, dots: ['critical'] },
    { day: 10, isCurrent: true, dots: ['good'] },
    { day: 11, isCurrent: true, dots: ['good'] },
    { day: 12, isCurrent: true, isToday: true, dots: ['critical', 'warning'] },
    { day: 13, isCurrent: true, dots: ['warning'] },
    { day: 14, isCurrent: true, dots: ['warning'] },
    { day: 15, isCurrent: true, dots: ['warning'] },
    { day: 16, isCurrent: true },
    { day: 17, isCurrent: true, dots: ['upcoming'] },
    { day: 18, isCurrent: true },
    { day: 19, isCurrent: true },
    { day: 20, isCurrent: true, dots: ['upcoming'] },
    { day: 21, isCurrent: true },
    { day: 22, isCurrent: true, dots: ['upcoming'] },
    { day: 23, isCurrent: true },
    { day: 24, isCurrent: true },
    { day: 25, isCurrent: true, dots: ['upcoming'] },
    { day: 26, isCurrent: true },
    { day: 27, isCurrent: true },
    { day: 28, isCurrent: true },
    { day: 29, isCurrent: true },
    { day: 30, isCurrent: true, dots: ['upcoming'] },
    { day: 1, isCurrent: false },
    { day: 2, isCurrent: false },
    { day: 3, isCurrent: false },
    { day: 4, isCurrent: false },
  ];

  const dotColorMap = {
    critical: 'bg-red-500',
    warning: 'bg-amber-500',
    good: 'bg-emerald-500',
    upcoming: 'bg-blue-400',
  };

  return (
    <Card className={`p-4 ${className}`}>
      <div className="flex items-center justify-between pb-3 border-b border-gray-100">
        <h3 className="text-[13px] font-bold text-gray-900 leading-tight">
          {month}
        </h3>
        <button
          type="button"
          onClick={onNextMonth}
          className="text-xs text-blue-700 hover:text-blue-900 font-medium flex items-center gap-0.5 hover:underline"
        >
          Next month
          <ChevronRight className="w-3.5 h-3.5" />
        </button>
      </div>

      <div className="grid grid-cols-7 gap-1 text-center text-[11px] font-semibold text-gray-400 pt-2 pb-1">
        {weekDays.map((wd, i) => (
          <div key={i}>{wd}</div>
        ))}
      </div>

      <div className="grid grid-cols-7 gap-1 text-center">
        {days.map((item, idx) => (
          <div
            key={idx}
            className={`h-8 flex flex-col items-center justify-center rounded text-xs transition-colors ${
              item.isToday
                ? 'bg-blue-50 text-blue-900 font-bold border border-blue-200'
                : item.isCurrent
                ? 'text-gray-800 hover:bg-gray-100/70'
                : 'text-gray-300'
            }`}
          >
            <span className="leading-none">{item.day}</span>
            {item.dots && item.dots.length > 0 && (
              <div className="flex items-center gap-0.5 mt-0.5">
                {item.dots.map((dColor, dIdx) => (
                  <span
                    key={dIdx}
                    className={`w-1 h-1 rounded-full ${dotColorMap[dColor] || 'bg-gray-400'}`}
                  />
                ))}
              </div>
            )}
          </div>
        ))}
      </div>

      <div className="flex items-center justify-between pt-3 mt-2 border-t border-gray-100 text-[10px] text-gray-500">
        <div className="flex items-center gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-red-500" />
          <span>Missed</span>
        </div>
        <div className="flex items-center gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-amber-500" />
          <span>Due soon</span>
        </div>
        <div className="flex items-center gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
          <span>Done</span>
        </div>
        <div className="flex items-center gap-1">
          <span className="w-1.5 h-1.5 rounded-full bg-blue-400" />
          <span>Upcoming</span>
        </div>
      </div>
    </Card>
  );
}
