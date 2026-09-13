import React from 'react';
import Card from '../ui/Card';
import { Link } from 'react-router-dom';

export default function DeadlinesWidget({ deadlines }) {
  if (!deadlines) return null;

  return (
    <Card className="p-4">
      {/* Header */}
      <div className="flex items-center justify-between pb-3 border-b border-gray-100">
        <div className="flex items-center gap-1.5">
          <h3 className="text-[13px] font-bold text-gray-900">Deadlines</h3>
          <span className="text-xs text-gray-400">
            . Grouped by how soon
          </span>
        </div>
        <Link
          to="/calendar"
          className="text-xs text-blue-700 hover:text-blue-900 font-medium hover:underline"
        >
          Calendar
        </Link>
      </div>

      {/* 3 Columns */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-3">
        {/* Next 24 hours */}
        <div>
          <div className="text-xs font-bold text-gray-900 mb-2.5 flex items-center gap-1.5">
            <span>{deadlines.hours24.title}</span>
            <span className="text-gray-500 font-normal">{deadlines.hours24.count}</span>
          </div>
          <div className="space-y-2.5">
            {deadlines.hours24.items.map((item, i) => (
              <div key={i} className="text-xs">
                <div className="font-medium text-gray-900 leading-snug">
                  {item.title}
                </div>
                <div
                  className={`text-[11px] mt-0.5 font-semibold ${
                    item.isCritical ? 'text-red-600' : 'text-gray-500'
                  }`}
                >
                  {item.due}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Next 7 days */}
        <div>
          <div className="text-xs font-bold text-gray-900 mb-2.5 flex items-center gap-1.5">
            <span>{deadlines.days7.title}</span>
            <span className="text-gray-500 font-normal">{deadlines.days7.count}</span>
          </div>
          <div className="space-y-2.5">
            {deadlines.days7.items.map((item, i) => (
              <div key={i} className="text-xs">
                <div className="font-medium text-gray-900 leading-snug">
                  {item.title}
                </div>
                <div className="text-[11px] text-gray-500 mt-0.5">
                  {item.due}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Next 90 days */}
        <div>
          <div className="text-xs font-bold text-gray-900 mb-2.5 flex items-center gap-1.5">
            <span>{deadlines.days90.title}</span>
            <span className="text-gray-500 font-normal">{deadlines.days90.count}</span>
          </div>
          <div className="space-y-2.5">
            {deadlines.days90.items.map((item, i) => (
              <div key={i} className="text-xs">
                <div className="font-medium text-gray-900 leading-snug">
                  {item.title}
                </div>
                <div className="text-[11px] text-gray-500 mt-0.5">
                  {item.due}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </Card>
  );
}
