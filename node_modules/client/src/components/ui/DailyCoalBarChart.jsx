import React from 'react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
  ReferenceLine,
  Cell,
} from 'recharts';

export default function DailyCoalBarChart({
  data = [],
  target = 45,
  threshold = 42,
  className = '',
}) {
  const formatYAxis = (val) => `${val}k`;

  return (
    <div className={`w-full ${className}`}>
      <div className="h-56 w-full">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 15, right: 10, left: -20, bottom: 5 }}>
            <XAxis
              dataKey="date"
              tick={{ fontSize: 10, fill: '#64748b' }}
              axisLine={{ stroke: '#cbd5e1' }}
              tickLine={false}
            />
            <YAxis
              tick={{ fontSize: 10, fill: '#64748b' }}
              axisLine={{ stroke: '#cbd5e1' }}
              tickLine={false}
              domain={[0, 60]}
              tickFormatter={formatYAxis}
            />
            <Tooltip
              formatter={(value) => [`${value} kt`, 'Production']}
              labelStyle={{ fontSize: 11, fontWeight: 'bold' }}
              contentStyle={{
                backgroundColor: '#ffffff',
                border: '1px solid #e2e8f0',
                borderRadius: '6px',
                fontSize: '11px',
              }}
            />
            <ReferenceLine
              y={target}
              stroke="#dc2626"
              strokeDasharray="3 3"
              label={{
                value: `Target ${target}k t`,
                position: 'top',
                fill: '#dc2626',
                fontSize: 10,
                fontWeight: 600,
              }}
            />
            <Bar dataKey="tonnes" radius={[3, 3, 0, 0]}>
              {data.map((entry, index) => {
                let fill = '#1e3a8a'; // on target deep blue
                if (entry.tonnes < threshold) {
                  fill = '#d97706'; // below threshold amber
                }
                if (entry.isToday) {
                  fill = '#3b82f6'; // today active blue
                }
                return <Cell key={`cell-${index}`} fill={fill} />;
              })}
            </Bar>
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Legend */}
      <div className="flex items-center justify-center gap-6 pt-2 text-[11px] text-gray-600">
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-sm bg-[#1e3a8a]" />
          <span>On target (≥ 42k t)</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-sm bg-[#d97706]" />
          <span>Below 42k t</span>
        </div>
        <div className="flex items-center gap-1.5">
          <span className="w-2.5 h-2.5 rounded-sm bg-[#3b82f6]" />
          <span>Today (Shift B in progress)</span>
        </div>
      </div>
    </div>
  );
}
