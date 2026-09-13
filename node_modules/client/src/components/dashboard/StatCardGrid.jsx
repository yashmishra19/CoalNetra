import React from 'react';
import Card from '../ui/Card';

export default function StatCardGrid({ stats = [] }) {
  const trendColorMap = {
    critical: 'text-red-600',
    warning: 'text-amber-600',
    good: 'text-emerald-600',
  };

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
      {stats.map((stat) => (
        <Card
          key={stat.id}
          accentColor={stat.accentColor}
          accentHeight="h-1"
          className="p-3.5 hover:shadow-md transition-shadow"
        >
          {/* Card Label */}
          <div className="text-[11px] font-medium text-gray-500 leading-tight">
            {stat.title}
          </div>

          {/* Number + Trend / Secondary */}
          <div className="flex items-baseline gap-1.5 mt-1.5">
            <span className="text-2xl font-bold text-gray-950 tracking-tight leading-none">
              {stat.value}
            </span>

            {stat.trend && (
              <span
                className={`text-xs font-semibold flex items-center ${
                  trendColorMap[stat.trend.color] || 'text-gray-600'
                }`}
              >
                {stat.trend.direction === 'up' ? '▲' : '▼'} {stat.trend.value}
              </span>
            )}

            {stat.secondaryValue && (
              <span className="text-sm font-normal text-gray-500">
                {stat.secondaryValue}
              </span>
            )}
          </div>

          {/* Subtext */}
          {stat.subtext && (
            <div className="text-[11px] text-gray-500 mt-1.5 leading-snug">
              {stat.subtext}
            </div>
          )}
        </Card>
      ))}
    </div>
  );
}
