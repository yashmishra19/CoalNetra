import React from 'react';

/**
 * Reusable StatusDot indicator
 * @param {Object} props
 * @param {'critical'|'warning'|'good'|'neutral'|'info'} [props.status]
 * @param {'sm'|'md'|'lg'} [props.size]
 * @param {boolean} [props.pulse]
 * @param {string} [props.className]
 */
export default function StatusDot({
  status = 'neutral',
  size = 'md',
  pulse = false,
  className = '',
}) {
  const colorMap = {
    critical: 'bg-red-500',
    warning: 'bg-amber-500',
    good: 'bg-emerald-500',
    neutral: 'bg-gray-400',
    info: 'bg-blue-500',
  };

  const sizeMap = {
    sm: 'w-1.5 h-1.5',
    md: 'w-2 h-2',
    lg: 'w-2.5 h-2.5',
  };

  return (
    <span className={`relative inline-flex items-center justify-center shrink-0 ${className}`}>
      {pulse && (
        <span
          className={`absolute inline-flex h-full w-full rounded-full opacity-75 animate-ping ${
            colorMap[status] || colorMap.neutral
          }`}
        />
      )}
      <span
        className={`relative inline-block rounded-full ${sizeMap[size]} ${
          colorMap[status] || colorMap.neutral
        }`}
      />
    </span>
  );
}
