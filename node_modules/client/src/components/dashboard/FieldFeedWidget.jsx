import React from 'react';
import Card from '../ui/Card';
import Badge from '../ui/Badge';

export default function FieldFeedWidget({ feed = [] }) {
  if (!feed || feed.length === 0) return null;

  return (
    <Card className="p-4">
      {/* Header */}
      <div className="flex items-center gap-1.5 pb-3 border-b border-gray-100">
        <h3 className="text-[13px] font-bold text-gray-900 leading-tight">
          Latest from the field
        </h3>
        <span className="text-xs text-gray-400">
          . Geo-tagged and time-stamped
        </span>
      </div>

      {/* Activity Feed List */}
      <div className="divide-y divide-gray-100 pt-1">
        {feed.map((item) => (
          <div
            key={item.id}
            className="py-2.5 flex items-start justify-between gap-4 hover:bg-slate-50/50 transition-colors"
          >
            {/* Left: Timestamp + Activity Details */}
            <div className="flex items-start gap-3 min-w-0 flex-1">
              <span className="text-xs font-bold text-gray-900 shrink-0 min-w-[38px] pt-0.5 font-mono">
                {item.time}
              </span>

              <div className="min-w-0 flex-1 text-xs text-gray-800 leading-relaxed">
                <span className="font-bold text-gray-950 mr-1">{item.author}</span>
                <span>{item.action}</span>
                {item.detail && (
                  <div className="text-[11px] text-gray-500 mt-0.5 leading-normal">
                    {item.detail}
                  </div>
                )}
              </div>
            </div>

            {/* Right: Verification / Location Pill */}
            <div className="shrink-0 self-center">
              <Badge variant={item.tagVariant || 'gps-verified'}>
                {item.tag}
              </Badge>
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}
