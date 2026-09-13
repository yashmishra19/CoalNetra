import React from 'react';
import { ChevronDown } from 'lucide-react';

/**
 * Reusable Select primitive
 * @param {Object} props
 * @param {string} [props.label]
 * @param {Array<{value: string, label: string}>|Array<string>} props.options
 * @param {string} props.value
 * @param {Function} props.onChange
 * @param {string} [props.className]
 */
export default function Select({
  label,
  options = [],
  value,
  onChange,
  className = '',
  ...rest
}) {
  return (
    <div className={`space-y-1 ${className}`}>
      {label && (
        <label className="block text-[11px] font-semibold text-gray-700">
          {label}
        </label>
      )}
      <div className="relative">
        <select
          value={value}
          onChange={(e) => onChange && onChange(e.target.value)}
          className="w-full appearance-none bg-white border border-gray-300 rounded-md py-1.5 pl-2.5 pr-8 text-xs text-gray-900 font-medium focus:outline-none focus:ring-1 focus:ring-slate-900 focus:border-slate-900 cursor-pointer shadow-xs"
          {...rest}
        >
          {options.map((opt, idx) => {
            const val = typeof opt === 'string' ? opt : opt.value;
            const lbl = typeof opt === 'string' ? opt : opt.label;
            return (
              <option key={idx} value={val}>
                {lbl}
              </option>
            );
          })}
        </select>
        <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-500">
          <ChevronDown className="w-3.5 h-3.5" />
        </div>
      </div>
    </div>
  );
}
