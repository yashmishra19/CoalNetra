import React from 'react';
import Card from '../ui/Card';
import StatusDot from '../ui/StatusDot';

export default function LiveReadingsWidget({ readings = [] }) {
  if (!readings || readings.length === 0) return null;

  return (
    <Card className="p-4">
      {/* Header */}
      <div className="pb-3 border-b border-gray-100">
        <h3 className="text-[13px] font-bold text-gray-900 leading-tight">
          Live readings
        </h3>
      </div>

      {/* Grid of Readings */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-x-6 gap-y-3 pt-3">
        {readings.map((reading) => (
          <div key={reading.id} className="flex items-start gap-2 text-xs">
            <div className="pt-1">
              <StatusDot status={reading.status} size="sm" />
            </div>
            <div>
              <div className="font-semibold text-gray-900 leading-tight">
                {reading.label}
              </div>
              <div className="text-[11px] text-gray-600 mt-0.5 leading-tight">
                <span className="font-medium text-gray-900">{reading.value}</span>
                {reading.note && (
                  <span className="text-gray-500">, {reading.note}</span>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}
