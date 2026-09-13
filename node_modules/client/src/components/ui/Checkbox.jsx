import React from 'react';
import { Check } from 'lucide-react';

/**
 * Reusable Checkbox primitive
 * @param {Object} props
 * @param {string} [props.label]
 * @param {boolean} props.checked
 * @param {Function} props.onChange
 * @param {string} [props.subtext]
 * @param {string} [props.className]
 */
export default function Checkbox({
  label,
  checked = false,
  onChange,
  subtext,
  className = '',
  ...rest
}) {
  return (
    <label className={`inline-flex items-start gap-2 cursor-pointer select-none ${className}`}>
      <div className="relative flex items-center justify-center mt-0.5">
        <input
          type="checkbox"
          checked={checked}
          onChange={(e) => onChange && onChange(e.target.checked)}
          className="sr-only"
          {...rest}
        />
        <div
          className={`w-4 h-4 rounded border transition-colors flex items-center justify-center ${
            checked
              ? 'bg-slate-900 border-slate-900 text-white'
              : 'bg-white border-gray-300 hover:border-gray-400'
          }`}
        >
          {checked && <Check className="w-3 h-3 stroke-[2.5]" />}
        </div>
      </div>

      <div className="text-xs leading-tight">
        {label && <span className="font-medium text-gray-800">{label}</span>}
        {subtext && (
          <div className="text-[11px] text-gray-400 mt-0.5">{subtext}</div>
        )}
      </div>
    </label>
  );
}
