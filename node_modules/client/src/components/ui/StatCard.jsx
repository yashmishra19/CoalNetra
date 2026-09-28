import React from 'react';

export default function StatCard({
  title,
  label,
  value,
  secondaryValue,
  suffix,
  subtext,
  detail,
  trend,
  dot,
  className = '',
}) {
  const trendColorMap = {
    critical: 'text-status-critical',
    warning: 'text-status-warning',
    good: 'text-status-good',
  };

  const displayTitle = label || title;
  const displaySuffix = suffix || secondaryValue;
  const displayDetail = detail || subtext;

  return (
    <div className={`bg-white border border-page-border rounded-xl p-5 flex flex-col justify-between ${className}`}>
      <div>
        <div className="text-[12px] font-semibold uppercase tracking-wider text-status-neutral flex items-center">
          {dot && (
            <span className={`w-2 h-2 rounded-full inline-block mr-1.5 ${dot}`} />
          )}
          {displayTitle}
        </div>

        <div className="flex items-baseline gap-1.5 mt-2">
          <span className="text-[30px] font-bold text-brand-primary leading-none">
            {value}
          </span>

          {trend && (
            <span
              className={`text-[12px] font-semibold flex items-center ${
                trendColorMap[trend.color] || 'text-status-neutral'
              }`}
            >
              {trend.direction === 'up' ? '▲' : '▼'} {trend.value}
            </span>
          )}

          {displaySuffix && (
            <span className="text-[14px] font-medium text-status-neutral">
              {displaySuffix}
            </span>
          )}
        </div>
      </div>

      {displayDetail && (
        <div className="text-[12px] text-status-neutral mt-1 leading-snug">
          {displayDetail}
        </div>
      )}
    </div>
  );
}

