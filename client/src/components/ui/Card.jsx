import React from 'react';

/**
 * Reusable Card component with optional top colored accent bar
 * @param {Object} props
 * @param {React.ReactNode} props.children
 * @param {string} [props.className]
 * @param {'critical'|'warning'|'good'|'info'|'neutral'|null} [props.accentColor]
 * @param {string} [props.accentHeight]
 * @param {boolean} [props.noPadding]
 */
export default function Card({
  children,
  className = '',
  accentColor = null,
  accentHeight = 'h-1.5',
  noPadding = false,
  ...rest
}) {
  const accentColorMap = {
    critical: 'bg-status-critical',
    warning: 'bg-status-warning',
    good: 'bg-status-good',
    info: 'bg-status-info',
    neutral: 'bg-gray-400',
  };

  return (
    <div
      className={`bg-white rounded-lg border border-page-border shadow-sm overflow-hidden flex flex-col ${
        noPadding ? '' : 'p-4'
      } ${className}`}
      {...rest}
    >
      {accentColor && (
        <div className={`w-full ${accentHeight} ${accentColorMap[accentColor] || accentColor} -mt-4 -mx-4 mb-4`} />
      )}
      {children}
    </div>
  );
}
