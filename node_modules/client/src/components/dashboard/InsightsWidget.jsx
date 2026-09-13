import React from 'react';
import Card from '../ui/Card';
import StatusDot from '../ui/StatusDot';
import { Link } from 'react-router-dom';

export default function InsightsWidget({ insights = [] }) {
  if (!insights || insights.length === 0) return null;

  return (
    <Card className="p-4">
      {/* Header */}
      <div className="flex items-center justify-between pb-3 border-b border-gray-100">
        <h3 className="text-[13px] font-bold text-gray-900">
          What the system noticed
        </h3>
        <Link
          to="/insights"
          className="text-xs text-blue-700 hover:text-blue-900 font-medium hover:underline"
        >
          All insights
        </Link>
      </div>

      {/* 3 Insight Columns / Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 pt-3">
        {insights.map((item) => (
          <div
            key={item.id}
            className="bg-[#fafbfc] border border-gray-200/80 rounded-md p-3 flex flex-col justify-between hover:bg-white hover:shadow-xs transition-all"
          >
            <div>
              {/* Category Pill / Dot */}
              <div className="flex items-center gap-1.5 mb-1.5">
                <StatusDot status={item.status} size="sm" />
                <span className="text-[11px] font-semibold text-gray-700">
                  {item.category}
                </span>
              </div>

              {/* Title */}
              <h4 className="text-xs font-bold text-gray-900 leading-snug">
                {item.title}
              </h4>

              {/* Description */}
              <p className="text-[11px] text-gray-500 mt-1 leading-relaxed">
                {item.description}
              </p>
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}
