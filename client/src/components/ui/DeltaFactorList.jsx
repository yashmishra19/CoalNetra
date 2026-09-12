import React from 'react';

/**
 * Reusable DeltaFactorList component displaying diverging risk contribution waterfall bars
 * Center line: positive delta grows right (red), negative delta grows left (green)
 *
 * @param {Object} props
 * @param {Array<{label: string, delta: number, description?: string}>} props.factors
 * @param {string} [props.className]
 */
export default function DeltaFactorList({ factors = [], className = '' }) {
  const maxDelta = 20;

  return (
    <div className={`space-y-2.5 text-xs ${className}`}>
      {factors.map((item, idx) => {
        const isPositive = item.delta > 0;
        const absVal = Math.abs(item.delta);
        const widthPct = Math.min(100, (absVal / maxDelta) * 100);

        return (
          <div key={idx} className="flex items-center justify-between gap-3">
            {/* Factor Name */}
            <div className="flex-1 min-w-0">
              <div className="font-semibold text-gray-900 truncate leading-snug">
                {item.label}
              </div>
              {item.description && (
                <div className="text-[10px] text-gray-400 truncate">
                  {item.description}
                </div>
              )}
            </div>

            {/* Diverging Center Bar */}
            <div className="w-28 flex items-center justify-center shrink-0">
              <div className="w-full h-2 bg-gray-100 rounded-full flex relative overflow-hidden">
                {/* Center Divider Line */}
                <div className="absolute left-1/2 top-0 bottom-0 w-0.5 bg-gray-400 z-10" />

                {/* Left Side (Negative / Risk Reducer Green) */}
                <div className="w-1/2 flex justify-end">
                  {!isPositive && (
                    <div
                      className="h-full bg-emerald-500 rounded-l-full"
                      style={{ width: `${widthPct}%` }}
                    />
                  )}
                </div>

                {/* Right Side (Positive / Risk Increaser Red) */}
                <div className="w-1/2 flex justify-start">
                  {isPositive && (
                    <div
                      className="h-full bg-red-500 rounded-r-full"
                      style={{ width: `${widthPct}%` }}
                    />
                  )}
                </div>
              </div>
            </div>

            {/* Signed Numeric Delta */}
            <div className="w-8 text-right font-mono font-bold shrink-0">
              <span className={isPositive ? 'text-red-700' : 'text-emerald-700'}>
                {isPositive ? `+${item.delta}` : item.delta}
              </span>
            </div>
          </div>
        );
      })}
    </div>
  );
}
