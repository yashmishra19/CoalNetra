import React from 'react';
import { CheckCircle2, AlertTriangle } from 'lucide-react';

/**
 * Reusable LedgerList component for reconciliation between production, dispatch, and physical survey
 */
export default function LedgerList({
  items = [],
  toleranceNote = 'Within the 2% tolerance',
  differenceBadge = 'Difference 0.8%',
  callout,
  className = '',
}) {
  return (
    <div className={`space-y-3 ${className}`}>
      {/* Ledger Rows */}
      <div className="space-y-1.5 text-xs">
        {items.map((item, idx) => {
          if (item.isDivider) {
            return <div key={idx} className="my-2 border-t border-gray-200" />;
          }

          const isSubtotal = item.isSubtotal || item.type === 'subtotal';
          const isAdd = item.type === 'add';
          const isSubtract = item.type === 'subtract';

          return (
            <div
              key={idx}
              className={`flex items-center justify-between py-1 px-1.5 rounded transition-colors ${
                isSubtotal
                  ? 'bg-slate-50 font-bold text-gray-950 border border-slate-200'
                  : 'text-gray-700 hover:bg-gray-50'
              }`}
            >
              <span className={isSubtotal ? 'font-bold' : 'font-medium'}>
                {item.label}
              </span>

              <span
                className={`font-mono ${
                  isSubtotal
                    ? 'font-bold text-gray-950'
                    : isAdd
                    ? 'text-emerald-700 font-semibold'
                    : isSubtract
                    ? 'text-red-700 font-semibold'
                    : 'text-gray-900'
                }`}
              >
                {isAdd ? '+ ' : isSubtract ? '− ' : ''}
                {item.value}
              </span>
            </div>
          );
        })}
      </div>

      {/* Difference / Tolerance Badge Bar */}
      {(differenceBadge || toleranceNote) && (
        <div className="flex items-center justify-between p-2 rounded bg-emerald-50 border border-emerald-200 text-xs">
          <div className="flex items-center gap-1.5 text-emerald-800 font-semibold">
            <CheckCircle2 className="w-4 h-4 text-emerald-600" />
            <span>{differenceBadge}</span>
          </div>
          <span className="text-[11px] text-emerald-700 font-medium">
            {toleranceNote}
          </span>
        </div>
      )}

      {/* Warning Callout Box */}
      {callout && (
        <div className="bg-amber-50 border border-amber-200 rounded-md p-2.5 flex items-start gap-2 text-xs text-amber-900 leading-relaxed">
          <AlertTriangle className="w-4 h-4 text-amber-700 shrink-0 mt-0.5" />
          <span>{callout}</span>
        </div>
      )}
    </div>
  );
}
