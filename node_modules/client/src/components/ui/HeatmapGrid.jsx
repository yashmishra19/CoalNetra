import React from 'react';

export default function HeatmapGrid({ days = [], rows = [], className = '' }) {
  const getCellColor = (val) => {
    if (val === 3) return 'bg-emerald-100 text-emerald-800 font-bold border-emerald-200';
    if (val >= 1) return 'bg-amber-100 text-amber-900 font-bold border-amber-200';
    return 'bg-red-100 text-red-800 font-bold border-red-200';
  };

  return (
    <div className={`w-full overflow-x-auto ${className}`}>
      <table className="w-full text-xs text-left border-collapse">
        <thead>
          <tr className="border-b border-gray-200">
            <th className="py-2 px-2 text-[11px] font-semibold text-gray-500 min-w-[130px]">
              Location
            </th>
            {days.map((day, idx) => (
              <th
                key={idx}
                className="py-2 px-1.5 text-center text-[11px] font-semibold text-gray-500 min-w-[36px]"
              >
                {day}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-100">
          {rows.map((row, rIdx) => (
            <tr key={rIdx} className="hover:bg-slate-50/50">
              <td className="py-2 px-2 text-xs font-semibold text-gray-900 leading-snug">
                {row.name}
              </td>
              {row.counts.map((val, cIdx) => (
                <td key={cIdx} className="py-1.5 px-1 text-center">
                  <span
                    className={`inline-flex items-center justify-center w-6 h-6 rounded text-xs border ${getCellColor(
                      val
                    )}`}
                  >
                    {val}
                  </span>
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
