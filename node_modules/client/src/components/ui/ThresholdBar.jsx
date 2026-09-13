import React from 'react';

/**
 * Reusable ThresholdBar component for environmental telemetry (Air quality PM10, Water discharge, Noise)
 * Displays colored fill, a vertical limit/target tick mark, and right-aligned value
 *
 * @param {Object} props
 * @param {string} props.label
 * @param {number} props.value
 * @param {number} props.limit
 * @param {number} [props.max]
 * @param {string} [props.unit]
 * @param {string} [props.subtext]
 * @param {string} [props.className]
 */
export default function ThresholdBar({
  label,
  value,
  limit,
  max,
  unit = '',
  subtext,
  className = '',
}) {
  const effectiveMax = max || Math.max(limit * 1.5, value * 1.25, 100);
  const fillPct = Math.min(100, Math.max(0, (value / effectiveMax) * 100));
  const limitPct = Math.min(100, Math.max(0, (limit / effectiveMax) * 100));

  const isExceeded = value > limit;
  const isNearLimit = value > limit * 0.85;

  let barColor = 'bg-emerald-500';
  let valueColor = 'text-emerald-700';
  if (isExceeded) {
    barColor = 'bg-red-500';
    valueColor = 'text-red-700 font-bold';
  } else if (isNearLimit) {
    barColor = 'bg-amber-500';
    valueColor = 'text-amber-800 font-bold';
  }

  return (
    <div className={`space-y-1 text-xs ${className}`}>
      {/* Label and Value */}
      <div className="flex items-baseline justify-between gap-2">
        <div className="flex items-center gap-1.5 min-w-0">
          <span className="font-semibold text-gray-900 truncate">{label}</span>
          {subtext && (
            <span className="text-[11px] text-gray-400 truncate">{subtext}</span>
          )}
        </div>
        <div className="shrink-0 font-mono text-xs">
          <span className={valueColor}>{value}</span>
          {unit && <span className="text-gray-500 ml-0.5">{unit}</span>}
          <span className="text-gray-400 text-[10px] ml-1">/ limit {limit}</span>
        </div>
      </div>

      {/* Bar with Limit Tick */}
      <div className="relative w-full bg-gray-100 rounded-full h-2 overflow-hidden">
        {/* Value Fill */}
        <div
          className={`h-full ${barColor} rounded-full transition-all duration-300`}
          style={{ width: `${fillPct}%` }}
        />

        {/* Limit Marker Line */}
        <div
          className="absolute top-0 bottom-0 w-0.5 bg-gray-700 z-10"
          style={{ left: `${limitPct}%` }}
          title={`Limit: ${limit}`}
        />
      </div>
    </div>
  );
}
