import React from 'react';
import Card from '../ui/Card';
import ProgressBar from '../ui/ProgressBar';
import StatusDot from '../ui/StatusDot';

export default function InspectionsWidget({ data }) {
  if (!data) return null;

  return (
    <Card className="p-4">
      {/* Header */}
      <div className="text-[13px] font-bold text-gray-900 leading-tight">
        Inspections, {data.shift}
      </div>

      {/* Progress & Big Counter */}
      <div className="mt-2">
        <div className="flex items-baseline gap-1.5 mb-2">
          <span className="text-2xl font-bold text-gray-900 leading-none">
            {data.doneCount}
          </span>
          <span className="text-xs text-gray-500 font-medium">
            of {data.totalCount} sections done
          </span>
        </div>

        <ProgressBar
          value={data.doneCount}
          max={data.totalCount}
          color="warning"
          height="h-2"
          className="bg-gray-100"
        />
      </div>

      {/* Not Yet Inspected Section */}
      <div className="mt-4 pt-3 border-t border-gray-100">
        <div className="text-[11px] font-semibold text-gray-500 mb-2">
          Not yet inspected:
        </div>

        <div className="space-y-2">
          {data.remainingItems.map((item, idx) => (
            <div
              key={idx}
              className="flex items-center justify-between text-xs py-0.5"
            >
              <div className="flex items-center gap-2">
                <StatusDot status={item.status} size="sm" />
                <span className="text-gray-900 font-medium">{item.name}</span>
              </div>
              <span className="text-[11px] text-gray-500">
                due {item.due}
              </span>
            </div>
          ))}
        </div>
      </div>

      {/* Footer Note */}
      {data.footerNote && (
        <div className="mt-4 pt-2.5 border-t border-gray-100 text-[11px] text-gray-500">
          {data.footerNote}
        </div>
      )}
    </Card>
  );
}
