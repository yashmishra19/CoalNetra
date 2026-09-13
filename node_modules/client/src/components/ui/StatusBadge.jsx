import React from 'react';

/**
 * Reusable StatusBadge component supporting all mining compliance, CAPA, workforce, regulatory, and signature statuses
 */
export default function StatusBadge({ status, className = '', ...rest }) {
  if (!status) return null;

  const statusStr = String(status).trim();
  const lower = statusStr.toLowerCase();

  let styles = 'bg-gray-100 text-gray-700 border-gray-200';

  if (
    lower.includes('due in') ||
    lower.includes('overdue') ||
    lower === 'not complied' ||
    lower === 'critical' ||
    lower === 'not started' ||
    lower === 'changed after signing'
  ) {
    styles = 'bg-red-50 text-red-700 border-red-200 font-medium';
  } else if (
    lower === 'due soon' ||
    lower === 'at risk' ||
    lower === 'high' ||
    lower === 'with safety officer' ||
    lower === 'waiting for you'
  ) {
    styles = 'bg-amber-50 text-amber-800 border-amber-200 font-medium';
  } else if (lower === 'medium') {
    styles = 'bg-amber-50 text-amber-700 border-amber-200 font-medium';
  } else if (
    lower === 'compliant' ||
    lower === 'on track' ||
    lower.startsWith('done') ||
    lower === 'worker informed' ||
    lower === 'record intact'
  ) {
    styles = 'bg-emerald-50 text-emerald-700 border-emerald-200 font-medium';
  } else if (
    lower === 'to verify' ||
    lower === 'in progress' ||
    lower.includes('certificates checked')
  ) {
    styles = 'bg-blue-50 text-blue-700 border-blue-200 font-medium';
  } else if (
    lower === 'assigned' ||
    lower === 'pending' ||
    lower === 'closed' ||
    lower === 'low'
  ) {
    styles = 'bg-gray-100 text-gray-600 border-gray-200 font-medium';
  } else if (
    lower === 'scheduled' ||
    lower === 'appeal filed' ||
    lower === 'draft'
  ) {
    styles = 'bg-white text-gray-700 border-gray-300 border font-medium';
  }

  // Handle score number pills (e.g. "81", "74", "66")
  const isNumber = !isNaN(Number(statusStr));
  if (isNumber) {
    const num = Number(statusStr);
    if (num >= 85) styles = 'bg-emerald-600 text-white font-bold px-2 py-0.5';
    else if (num >= 70) styles = 'bg-red-600 text-white font-bold px-2 py-0.5';
    else if (num >= 40) styles = 'bg-amber-500 text-white font-bold px-2 py-0.5';
    else styles = 'bg-emerald-600 text-white font-bold px-2 py-0.5';
  }

  return (
    <span
      className={`inline-flex items-center justify-center text-xs px-2 py-0.5 rounded border leading-snug max-w-full text-center ${styles} ${className}`}
      {...rest}
    >
      {statusStr}
    </span>
  );
}
