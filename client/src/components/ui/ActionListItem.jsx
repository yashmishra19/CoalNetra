import React from 'react';
import StatusDot from './StatusDot';
import Button from './Button';

/**
 * Reusable ActionListItem component
 * Pattern: [Status Dot] [Title + Subtitle] ----- [Time/Deadline info] [Action Buttons]
 *
 * @param {Object} props
 * @param {'critical'|'warning'|'good'|'neutral'} [props.status]
 * @param {string|React.ReactNode} props.title
 * @param {string|React.ReactNode} [props.description]
 * @param {Object} [props.timeInfo]
 * @param {string} [props.timeInfo.primary] e.g. "3 h" or "1 day" or "Today"
 * @param {string} [props.timeInfo.secondary] e.g. "by 18:20" or "overdue" or "work starts 20:30"
 * @param {'critical'|'warning'|'neutral'} [props.timeInfo.variant]
 * @param {Array<{label: string, variant?: string, onClick?: Function}>} [props.actions]
 * @param {boolean} [props.isLast]
 * @param {string} [props.className]
 */
export default function ActionListItem({
  status = 'neutral',
  title,
  description,
  timeInfo,
  actions = [],
  isLast = false,
  className = '',
}) {
  const timeVariantClasses = {
    critical: 'text-red-700',
    warning: 'text-amber-800 font-semibold',
    neutral: 'text-gray-800 font-semibold',
  };

  return (
    <div
      className={`flex items-start justify-between py-3 gap-3 transition-colors hover:bg-slate-50/50 ${
        !isLast ? 'border-b border-gray-100' : ''
      } ${className}`}
    >
      {/* Left: Status dot + content */}
      <div className="flex items-start gap-2.5 min-w-0 flex-1">
        <div className="pt-1.5">
          <StatusDot status={status} size="md" />
        </div>
        <div className="min-w-0 flex-1">
          <h4 className="text-[13px] font-semibold text-gray-900 leading-snug">
            {title}
          </h4>
          {description && (
            <p className="text-xs text-gray-500 mt-0.5 leading-relaxed">
              {description}
            </p>
          )}
        </div>
      </div>

      {/* Right: Time Info + Action Buttons */}
      <div className="flex items-center gap-3 shrink-0 self-center">
        {timeInfo && (
          <div className="text-right min-w-[70px]">
            <div
              className={`text-xs font-bold leading-tight ${
                timeVariantClasses[timeInfo.variant || (status === 'critical' ? 'critical' : status === 'warning' ? 'warning' : 'neutral')]
              }`}
            >
              {timeInfo.primary}
            </div>
            {timeInfo.secondary && (
              <div className="text-[10px] text-gray-500 leading-tight">
                {timeInfo.secondary}
              </div>
            )}
          </div>
        )}

        {actions && actions.length > 0 && (
          <div className="flex items-center gap-1.5">
            {actions.map((action, idx) => (
              <Button
                key={idx}
                variant={action.variant || (idx === 0 ? 'dark-blue' : 'secondary')}
                size="xs"
                onClick={action.onClick}
                className="px-2.5 py-1 text-xs"
              >
                {action.label}
              </Button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
