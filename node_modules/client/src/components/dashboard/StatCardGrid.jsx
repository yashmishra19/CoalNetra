import React from 'react';

export default function StatCardGrid({ stats = [] }) {
  const trendColorMap = {
    critical: 'text-status-critical',
    warning: 'text-status-warning',
    good: 'text-status-good',
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
      {stats.map((stat) => (
        <div
          key={stat.id || stat.title || stat.label}
          className="bg-white border border-page-border rounded-xl p-5 flex flex-col justify-between"
        >
          <div>
            <div className="text-[12px] font-semibold uppercase tracking-wider text-status-neutral flex items-center">
              {stat.dot && (
                <span className={`w-2 h-2 rounded-full inline-block mr-1.5 ${stat.dot}`} />
              )}
              {stat.title || stat.label}
            </div>

            <div className="flex items-baseline gap-1.5 mt-2">
              <span className="text-[30px] font-bold text-brand-primary leading-none">
                {stat.value}
              </span>

              {stat.trend && (
                <span
                  className={`text-[12px] font-semibold flex items-center ${
                    trendColorMap[stat.trend.color] || 'text-status-neutral'
                  }`}
                >
                  {stat.trend.direction === 'up' ? '▲' : '▼'} {stat.trend.value}
                </span>
              )}

              {(stat.secondaryValue || stat.suffix) && (
                <span className="text-[14px] font-medium text-status-neutral">
                  {stat.secondaryValue || stat.suffix}
                </span>
              )}
            </div>
          </div>

          {(stat.subtext || stat.detail) && (
            <div className="text-[12px] text-status-neutral mt-1 leading-snug">
              {stat.subtext || stat.detail}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

