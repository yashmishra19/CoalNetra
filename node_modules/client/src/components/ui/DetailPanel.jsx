import React from 'react';
import Card from './Card';
import StatusBadge from './StatusBadge';
import Button from './Button';
import { ShieldCheck } from 'lucide-react';

export default function DetailPanel({
  title,
  subtitle,
  badge,
  badgeVariant,
  description,
  callout,
  actions = [],
  footerNote,
  footerBadge = 'Record intact',
  children,
  className = '',
}) {
  return (
    <Card className={`p-4 flex flex-col justify-between h-full bg-white ${className}`}>
      <div className="space-y-4">
        <div className="pb-2.5 border-b border-gray-100">
          <div className="flex items-start justify-between gap-2">
            <div>
              <h3 className="text-sm font-bold text-gray-900 leading-snug">
                {title}
              </h3>
              {subtitle && (
                <div className="text-[11px] text-gray-500 mt-0.5">
                  {subtitle}
                </div>
              )}
            </div>
            {badge && (
              <StatusBadge status={badge} />
            )}
          </div>

          {description && (
            <p className="text-xs text-gray-600 mt-2 leading-relaxed">
              {description}
            </p>
          )}
        </div>

        <div className="space-y-3.5">
          {children}
        </div>

        {callout && (
          <div className="bg-amber-50 border border-amber-200 rounded-md p-2.5 text-xs text-amber-900 leading-relaxed">
            <span className="font-semibold">{callout.title || 'Note'}: </span>
            <span>{callout.message || callout}</span>
          </div>
        )}
      </div>

      <div className="pt-4 mt-4 border-t border-gray-100 space-y-3">
        {actions.length > 0 && (
          <div className="flex items-center gap-2">
            {actions.map((act, idx) => (
              <Button
                key={idx}
                variant={act.variant || (idx === 0 ? 'dark-blue' : 'secondary')}
                size="sm"
                onClick={act.onClick}
                className={`flex-1 text-xs font-semibold ${act.className || ''}`}
              >
                {act.label}
              </Button>
            ))}
          </div>
        )}

        {(footerNote || footerBadge) && (
          <div className="flex items-center justify-between text-[11px] text-gray-500 pt-1">
            <span>{footerNote}</span>
            {footerBadge && (
              <span className="inline-flex items-center gap-1 text-[10px] text-emerald-700 font-semibold bg-emerald-50 px-1.5 py-0.5 rounded border border-emerald-200">
                <ShieldCheck className="w-3 h-3 text-emerald-600" />
                {footerBadge}
              </span>
            )}
          </div>
        )}
      </div>
    </Card>
  );
}
