import React from 'react';

/**
 * Reusable Button component
 * @param {Object} props
 * @param {React.ReactNode} props.children
 * @param {'primary'|'secondary'|'outline'|'danger'|'action'|'ghost'|'dark-blue'} [props.variant]
 * @param {'xs'|'sm'|'md'|'lg'} [props.size]
 * @param {boolean} [props.disabled]
 * @param {string} [props.className]
 */
export default function Button({
  children,
  variant = 'primary',
  size,
  disabled = false,
  className = '',
  onClick,
  ...rest
}) {
  const variantMap = {
    primary: 'bg-brand-primary text-white font-semibold hover:bg-brand-dark',
    'dark-blue': 'bg-brand-primary text-white font-semibold hover:bg-brand-dark',
    secondary: 'border border-page-border font-medium text-brand-primary hover:bg-page-bg bg-white',
    outline: 'border border-page-border font-medium text-brand-primary hover:bg-page-bg bg-transparent',
    danger: 'bg-status-critical text-white font-semibold hover:bg-status-critical-dark',
    action: 'bg-status-info text-white font-semibold hover:bg-status-info-dark',
    ghost: 'bg-transparent text-status-neutral hover:text-brand-primary hover:bg-page-bg font-medium',
  };

  const sizeMap = {
    xs: 'text-[11px] px-2.5 py-1 rounded-md',
    sm: 'text-[12px] px-3 py-1.5 rounded-lg',
    md: 'text-[13px] px-4 py-2 rounded-lg',
    lg: 'text-[14px] px-5 py-2.5 rounded-lg',
  };

  const defaultPaddingSize = size ? sizeMap[size] : 'px-4 py-2.5 text-[13px] rounded-lg';

  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      className={`inline-flex items-center justify-center transition duration-150 select-none cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed ${variantMap[variant] || variantMap.primary} ${defaultPaddingSize} ${className}`}
      {...rest}
    >
      {children}
    </button>
  );
}

