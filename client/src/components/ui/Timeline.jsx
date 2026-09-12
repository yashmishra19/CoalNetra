import React from 'react';

export default function Timeline({ events = [], className = '' }) {
  return (
    <div className={`space-y-3 relative pl-4 border-l-2 border-gray-200 ml-2 ${className}`}>
      {events.map((evt, idx) => {
        const isDone = evt.status === 'done';
        const isCurrent = evt.status === 'current';

        return (
          <div key={idx} className="relative group">
            <span
              className={`absolute -left-[23px] top-1 w-3.5 h-3.5 rounded-full border-2 bg-white flex items-center justify-center ${
                isDone
                  ? 'border-emerald-600 bg-emerald-600'
                  : isCurrent
                  ? 'border-blue-600 bg-blue-50'
                  : 'border-gray-300 bg-white'
              }`}
            >
              {isDone && <span className="w-1.5 h-1.5 bg-white rounded-full" />}
              {isCurrent && <span className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-pulse" />}
            </span>

            <div className="text-xs">
              <div className="flex items-baseline justify-between gap-2">
                <span className="font-semibold text-gray-900 leading-snug">
                  {evt.description}
                </span>
                <span className="text-[10px] text-gray-400 font-mono shrink-0">
                  {evt.timestamp}
                </span>
              </div>
              {evt.author && (
                <div className="text-[11px] text-gray-500 mt-0.5">
                  by {evt.author}
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
