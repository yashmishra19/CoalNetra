import React from 'react';

/**
 * Reusable Badge component
 * @param {Object} props
 * @param {React.ReactNode} props.children
 * @param {'critical'|'critical-subtle'|'warning'|'warning-subtle'|'good'|'good-subtle'|'info'|'info-subtle'|'neutral'|'gps-verified'|'qr-tag'|'location-flagged'|'counter'|'subtle-gray'} [props.variant]
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
    critical: 'bg-status-critical text-white font-semibold',
    'critical-subtle': 'bg-status-critical-bg text-status-critical border border-status-critical-border font-semibold',
    warning: 'bg-status-warning text-white font-semibold',
    'warning-subtle': 'bg-status-warning-bg text-status-warning border border-status-warning-border font-semibold',
    good: 'bg-status-good text-white font-semibold',
    'good-subtle': 'bg-status-good-bg text-status-good border border-status-good-border font-semibold',
    info: 'bg-status-info text-white font-semibold',
    'info-subtle': 'bg-status-info-bg text-status-info border border-status-info-border font-semibold',
    neutral: 'bg-page-bg text-brand-primary border border-page-border font-semibold',
    'subtle-gray': 'bg-page-bg text-status-neutral font-semibold',
    counter: 'bg-status-critical text-white text-[11px] font-bold rounded-full px-1.5 py-0.2 min-w-[18px] text-center leading-tight',
    'counter-sidebar': 'bg-status-critical text-white text-[11px] font-bold rounded-full w-4 h-4 flex items-center justify-center',
    'gps-verified': 'bg-status-good-bg text-status-good border border-status-good-border font-semibold text-[12px] rounded-md px-2 py-0.5',
    'qr-tag': 'bg-page-bg text-brand-primary border border-page-border font-semibold text-[12px] rounded-md px-2 py-0.5',
    'location-flagged': 'bg-status-critical-bg text-status-critical border border-status-critical-border font-semibold text-[12px] rounded-md px-2 py-0.5',
  };

  const sizeMap = {
    sm: 'text-[11px] px-2 py-0.5',
    md: 'text-[12px] px-2.5 py-0.5 font-semibold',
    lg: 'text-[13px] px-3 py-1 font-semibold',
  };

  const isCounter = variant === 'counter' || variant === 'counter-sidebar';
  const sizeClasses = isCounter ? '' : sizeMap[size];

  return (
    <span
      className={`inline-flex items-center justify-center rounded-md transition-colors whitespace-nowrap ${variantMap[variant] || variantMap.neutral} ${sizeClasses} ${className}`}
      {...rest}
    >
      {children}
    </span>
  );
}

