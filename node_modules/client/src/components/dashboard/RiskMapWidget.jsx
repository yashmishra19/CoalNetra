import React from 'react';
import Card from '../ui/Card';
import Badge from '../ui/Badge';
import { Link } from 'react-router-dom';
import MineRiskMapGraphic from '../shared/MineRiskMapGraphic';

export default function RiskMapWidget({ data }) {
  if (!data) return null;

  return (
    <Card className="p-4 flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center justify-between pb-2 border-b border-gray-100">
        <div className="flex items-center gap-1.5">
          <h3 className="text-[13px] font-bold text-gray-900">
            Where risk is highest
          </h3>
          <span className="text-xs text-gray-400">
            . Updated {data.lastUpdated}
          </span>
        </div>
        <Link
          to="/risk-map"
          className="text-xs text-blue-700 hover:text-blue-900 font-medium hover:underline"
        >
          Open risk map
        </Link>
      </div>

      {/* Styled Mine Graphic (SVG Map) */}
      <div className="my-3">
        <MineRiskMapGraphic size="small" />
      </div>

      {/* Ranked Risk List */}
      <div className="space-y-2 mt-auto">
        {data.rankedItems.map((item) => (
          <div
            key={item.rank}
            className="flex items-start gap-2.5 p-1.5 rounded hover:bg-slate-50 transition-colors"
          >
            <Badge
              variant={item.badgeVariant}
              className="w-6 h-6 rounded text-xs font-bold shrink-0 flex items-center justify-center p-0"
            >
              {item.score}
            </Badge>
            <div className="min-w-0 flex-1">
              <div className="text-xs font-bold text-gray-900 leading-snug">
                {item.name}
              </div>
              <div className="text-[11px] text-gray-500 leading-snug mt-0.5">
                {item.detail}
              </div>
            </div>
          </div>
        ))}
      </div>
    </Card>
  );
}
