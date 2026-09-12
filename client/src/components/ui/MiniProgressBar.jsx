import React from 'react';

export default function MiniProgressBar({
  value,
  max = 100,
  color,
  showText = false,
  height = 'h-1.5',
  width = 'w-16',
  className = '',
}) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  let barColorClass = 'bg-emerald-500';
  if (color === 'critical' || (!color && percentage < 50)) {
    barColorClass = 'bg-red-500';
  } else if (color === 'warning' || (!color && percentage < 80)) {
    barColorClass = 'bg-amber-500';
  } else if (color === 'good' || (!color && percentage >= 80)) {
    barColorClass = 'bg-emerald-500';
  } else if (color === 'info') {
    barColorClass = 'bg-blue-600';
  } else if (color) {
    barColorClass = color;
  }

  return (
    <div className={`inline-flex items-center gap-2 ${className}`}>
      <div className={`bg-gray-200 rounded-full overflow-hidden ${width} ${height}`}>
        <div
          className={`${height} ${barColorClass} rounded-full transition-all duration-300`}
          style={{ width: `${percentage}%` }}
        />
      </div>
      {showText && (
        <span className="text-xs font-semibold text-gray-700 font-mono">
          {Math.round(percentage)}%
        </span>
      )}
    </div>
  );
}
