import React from 'react';

export default function FilterPillGroup({
  options = [],
  activeKey,
  onChange,
  className = '',
}) {
  return (
    <div className={`flex flex-wrap items-center gap-1.5 ${className}`}>
      {options.map((opt) => {
        const isActive = activeKey === opt.key;
        return (
          <button
            key={opt.key}
            type="button"
            onClick={() => onChange && onChange(opt.key)}
            className={`px-2.5 py-1 text-xs rounded-md transition-all font-medium flex items-center gap-1.5 ${
              isActive
                ? 'bg-slate-900 text-white font-semibold shadow-xs'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200/80 border border-transparent'
            }`}
          >
            <span>{opt.label}</span>
            {opt.count !== undefined && (
              <span
                className={`text-[11px] px-1.5 py-0.2 rounded-full font-bold ${
                  isActive
                    ? 'bg-slate-700 text-white'
                    : 'bg-gray-200 text-gray-700'
                }`}
              >
                {opt.count}
              </span>
            )}
          </button>
        );
      })}
    </div>
  );
}
