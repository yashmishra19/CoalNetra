import React from 'react';
import Card from './Card';
import StatusDot from './StatusDot';
import ProgressBar from './ProgressBar';

export default function StatCard({
  variant = 'simple',
  title,
  value,
  secondaryValue,
  subtext,
  status = 'neutral',
  accentColor,
  trend,
  progress,
  className = '',
}) {
  const trendColorMap = {
    critical: 'text-red-600',
    warning: 'text-amber-600',
    good: 'text-emerald-600',
  };

  if (variant === 'kpi') {
    return (
      <Card
        accentColor={accentColor || status}
        accentHeight="h-1"
        className={`p-3.5 hover:shadow-md transition-shadow ${className}`}
      >
        <div className="text-[11px] font-medium text-gray-500 leading-tight">
          {title}
        </div>
        <div className="flex items-baseline gap-1.5 mt-1.5">
          <span className="text-2xl font-bold text-gray-950 tracking-tight leading-none">
            {value}
          </span>
          {trend && (
            <span
              className={`text-xs font-semibold flex items-center ${
                trendColorMap[trend.color] || 'text-gray-600'
              }`}
            >
              {trend.direction === 'up' ? '▲' : '▼'} {trend.value}
            </span>
          )}
          {secondaryValue && (
            <span className="text-sm font-normal text-gray-500">
              {secondaryValue}
            </span>
          )}
        </div>
        {subtext && (
          <div className="text-[11px] text-gray-500 mt-1.5 leading-snug">
            {subtext}
          </div>
        )}
      </Card>
    );
  }

  return (
    <Card className={`p-3.5 hover:shadow-xs transition-shadow ${className}`}>
      <div className="flex items-center gap-1.5">
        <StatusDot status={status} size="sm" />
        <span className="text-[11px] font-semibold text-gray-600 truncate leading-tight">
          {title}
        </span>
      </div>

      <div className="flex items-baseline gap-1 mt-1.5">
        <span className="text-xl font-bold text-gray-950 tracking-tight leading-none">
          {value}
        </span>
        {secondaryValue && (
          <span className="text-xs font-normal text-gray-500">
            {secondaryValue}
          </span>
        )}
      </div>

      {progress !== undefined && (
        <div className="mt-2">
          <ProgressBar value={progress} color={status} height="h-1.5" />
        </div>
      )}

      {subtext && (
        <div className="text-[11px] text-gray-500 mt-1.5 leading-snug">
          {subtext}
        </div>
      )}
    </Card>
  );
}
