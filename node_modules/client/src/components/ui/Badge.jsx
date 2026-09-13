import React from 'react';

/**
 * Reusable Badge component
 * @param {Object} props
 * @param {React.ReactNode} props.children
 * @param {'critical'|'warning'|'good'|'info'|'neutral'|'gps-verified'|'qr-tag'|'location-flagged'|'counter'|'subtle-gray'} [props.variant]
 * @param {'sm'|'md'|'lg'} [props.size]
 * @param {string} [props.className]
 */
export default function Badge({
  children,
  variant = 'neutral',
  size = 'md',
  className = '',
  ...rest
}) {
  const variantMap = {
    critical: 'bg-red-700 text-white font-semibold',
    'critical-subtle': 'bg-red-50 text-red-700 border border-red-200 font-medium',
    warning: 'bg-amber-600 text-white font-semibold',
    'warning-subtle': 'bg-amber-50 text-amber-800 border border-amber-200 font-medium',
    good: 'bg-emerald-600 text-white font-semibold',
    'good-subtle': 'bg-emerald-50 text-emerald-800 border border-emerald-200 font-medium',
    info: 'bg-blue-600 text-white font-semibold',
    'info-subtle': 'bg-blue-50 text-blue-800 border border-blue-200 font-medium',
    neutral: 'bg-gray-100 text-gray-700 border border-gray-200 font-medium',
    'subtle-gray': 'bg-gray-100 text-gray-600 font-medium text-2xs',
    counter: 'bg-red-600 text-white text-xs font-bold rounded-full px-1.5 py-0.2 min-w-[18px] text-center leading-tight',
    'counter-sidebar': 'bg-red-600 text-white text-[11px] font-bold rounded-full w-4 h-4 flex items-center justify-center',
    'gps-verified': 'bg-emerald-50 text-emerald-700 border border-emerald-200 font-medium text-xs rounded px-2 py-0.5',
    'qr-tag': 'bg-slate-100 text-slate-700 border border-slate-300 font-medium text-xs rounded px-2 py-0.5',
    'location-flagged': 'bg-red-50 text-red-700 border border-red-200 font-medium text-xs rounded px-2 py-0.5',
  };

  const sizeMap = {
    sm: 'text-[10px] px-1.5 py-0.5',
    md: 'text-xs px-2 py-0.5',
    lg: 'text-sm px-2.5 py-1',
  };

  const isCounter = variant === 'counter' || variant === 'counter-sidebar';
  const sizeClasses = isCounter ? '' : sizeMap[size];

  return (
    <span
      className={`inline-flex items-center justify-center rounded transition-colors whitespace-nowrap ${variantMap[variant] || variantMap.neutral} ${sizeClasses} ${className}`}
      {...rest}
    >
      {children}
    </span>
  );
}
