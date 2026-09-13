import React from 'react';
import Card from '../ui/Card';
import ActionListItem from '../ui/ActionListItem';
import { Link } from 'react-router-dom';

export default function DecisionList({ decisions }) {
  if (!decisions) return null;

  return (
    <Card className="p-4 flex flex-col h-full">
      {/* Header */}
      <div className="flex items-center justify-between pb-2 border-b border-gray-100">
        <div className="flex items-center gap-1.5">
          <h3 className="text-[13px] font-bold text-gray-900">
            Waiting for your decision
          </h3>
          <span className="text-xs text-gray-400">
            {decisions.count} items
          </span>
        </div>
        <Link
          to="/reports-approvals"
          className="text-xs text-blue-700 hover:text-blue-900 font-medium hover:underline"
        >
          See all
        </Link>
      </div>

      {/* List Items */}
      <div className="flex-1 divide-y divide-gray-100">
        {decisions.items.map((item, idx) => (
          <ActionListItem
            key={item.id}
            status={item.status}
            title={item.title}
            description={item.description}
            timeInfo={item.timeInfo}
            actions={item.actions}
            isLast={idx === decisions.items.length - 1}
          />
        ))}
      </div>

      {/* Footer Note */}
      {decisions.footerNote && (
        <div className="pt-3 mt-2 border-t border-gray-100 text-[11px] text-gray-500">
          <Link
            to="/reports-approvals"
            className="text-gray-600 hover:text-blue-700 hover:underline"
          >
            {decisions.footerNote}
          </Link>
        </div>
      )}
    </Card>
  );
}
