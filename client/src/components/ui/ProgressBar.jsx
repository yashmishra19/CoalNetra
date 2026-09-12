import React from 'react';

/**
 * Reusable ProgressBar component
 * @param {Object} props
 * @param {number} props.value
 * @param {number} [props.max]
 * @param {'critical'|'warning'|'good'|'info'|'blue'|string} [props.color]
 * @param {string} [props.height]
 * @param {string} [props.className]
 */
export default function ProgressBar({
  value,
  max = 100,
  color = 'good',
  height = 'h-2',
  className = '',
}) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  const colorMap = {
    critical: 'bg-red-500',
    warning: 'bg-amber-500',
    good: 'bg-emerald-500',
    info: 'bg-blue-600',
    blue: 'bg-blue-500',
    navy: 'bg-[#1b3252]',
  };

  const barColor = colorMap[color] || color;

  return (
    <div className={`w-full bg-gray-200 rounded-full overflow-hidden ${height} ${className}`}>
      <div
        className={`${height} ${barColor} transition-all duration-300 rounded-full`}
        style={{ width: `${percentage}%` }}
      />
    </div>
  );
}
