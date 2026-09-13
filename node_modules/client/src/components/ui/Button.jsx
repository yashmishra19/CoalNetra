import React from 'react';

/**
 * Reusable Button component
 * @param {Object} props
 * @param {React.ReactNode} props.children
 * @param {'primary'|'secondary'|'outline'|'danger'|'ghost'|'dark-blue'} [props.variant]
 * @param {'xs'|'sm'|'md'|'lg'} [props.size]
 * @param {boolean} [props.disabled]
 * @param {string} [props.className]
 */
export default function Button({
  children,
  variant = 'secondary',
  size = 'sm',
  disabled = false,
  className = '',
  onClick,
  ...rest
}) {
  const variantMap = {
    primary: 'bg-slate-900 text-white hover:bg-slate-800 border border-slate-900 shadow-sm focus:ring-slate-400',
    'dark-blue': 'bg-[#1b3252] text-white hover:bg-[#233f66] border border-[#1b3252] shadow-sm',
    secondary: 'bg-white text-gray-800 border border-gray-300 hover:bg-gray-50 shadow-sm focus:ring-gray-300',
    outline: 'bg-transparent text-gray-700 border border-gray-300 hover:bg-gray-100 focus:ring-gray-300',
    danger: 'bg-red-600 text-white hover:bg-red-700 border border-red-600 shadow-sm focus:ring-red-400',
    ghost: 'bg-transparent text-gray-600 hover:text-gray-900 hover:bg-gray-100',
  };

  const sizeMap = {
    xs: 'text-2xs px-2 py-1 rounded font-medium',
    sm: 'text-xs px-2.5 py-1.5 rounded font-medium',
    md: 'text-sm px-3.5 py-2 rounded-md font-medium',
    lg: 'text-base px-4 py-2.5 rounded-md font-medium',
  };

  return (
    <button
      type="button"
      disabled={disabled}
      onClick={onClick}
      className={`inline-flex items-center justify-center transition-all duration-150 select-none cursor-pointer focus:outline-none focus:ring-2 focus:ring-offset-1 disabled:opacity-50 disabled:cursor-not-allowed ${variantMap[variant] || variantMap.secondary} ${sizeMap[size]} ${className}`}
      {...rest}
    >
      {children}
    </button>
  );
}
