import React from 'react';
import StatusBadge from './StatusBadge';

/**
 * Reusable RankedList component for risk score rankings
 *
 * @param {Object} props
 * @param {Array<{score: number|string, title: string, description?: string, id?: string}>} props.items
 * @param {Function} [props.onSelect]
 * @param {string|number} [props.selectedId]
 * @param {string} [props.className]
 */
export default function RankedList({
  items = [],
  onSelect,
  selectedId,
  className = '',
}) {
  return (
    <div className={`space-y-1.5 ${className}`}>
      {items.map((item, idx) => {
        const isSelected = selectedId && item.id === selectedId;

        return (
          <div
            key={item.id || idx}
            onClick={() => onSelect && onSelect(item)}
            className={`flex items-start gap-2.5 p-2 rounded-md transition-colors ${
              isSelected
                ? 'bg-blue-50/80 border border-blue-200'
                : 'hover:bg-slate-50 border border-transparent'
            } ${onSelect ? 'cursor-pointer' : ''}`}
          >
            {/* Score Number Pill */}
            <div className="shrink-0 pt-0.5">
              <StatusBadge status={item.score} className="w-7 h-5 flex items-center justify-center p-0 text-xs font-bold" />
            </div>

            {/* Title & Description */}
            <div className="min-w-0 flex-1">
              <div className="text-xs font-bold text-gray-900 leading-snug">
                {item.title}
              </div>
              {item.description && (
                <div className="text-[11px] text-gray-500 leading-snug mt-0.5">
                  {item.description}
                </div>
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
