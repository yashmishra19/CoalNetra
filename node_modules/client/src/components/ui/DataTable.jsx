import React from 'react';

export default function DataTable({
  columns = [],
  data = [],
  keyField = 'id',
  onRowClick,
  selectedId,
  className = '',
  emptyMessage = 'No records found',
}) {
  return (
    <div className={`w-full bg-white border border-page-border rounded-xl overflow-hidden overflow-x-auto ${className}`}>
      <table className="w-full text-left border-collapse">
        <thead>
          <tr className="bg-page-bg border-b border-page-border">
            {columns.map((col) => (
              <th
                key={col.key}
                className={`py-3 px-5 text-[11px] font-semibold uppercase tracking-wider text-status-neutral ${
                  col.align === 'right'
                    ? 'text-right'
                    : col.align === 'center'
                    ? 'text-center'
                    : 'text-left'
                } ${col.width || ''}`}
              >
                {col.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {data.length === 0 ? (
            <tr>
              <td
                colSpan={columns.length}
                className="py-6 px-5 text-center text-[14px] text-status-neutral italic"
              >
                {emptyMessage}
              </td>
            </tr>
          ) : (
            data.map((row, idx) => {
              const rowKey = row[keyField] || idx;
              const isSelected = selectedId !== undefined && row[keyField] === selectedId;

              return (
                <tr
                  key={rowKey}
                  onClick={() => onRowClick && onRowClick(row)}
                  className={`border-t border-page-border transition-colors hover:bg-page-bg/50 ${
                    isSelected ? 'bg-status-info-bg font-medium' : ''
                  } ${onRowClick ? 'cursor-pointer' : ''}`}
                >
                  {columns.map((col) => {
                    return (
                      <td
                        key={col.key}
                        className={`py-3.5 px-5 text-[14px] align-middle ${
                          col.align === 'right'
                            ? 'text-right'
                            : col.align === 'center'
                            ? 'text-center'
                            : 'text-left'
                        }`}
                      >
                        {col.render ? (
                          col.render(row, idx)
                        ) : (
                          <div className="text-brand-primary leading-snug">
                            {row[col.key]}
                          </div>
                        )}
                      </td>
                    );
                  })}
                </tr>
              );
            })
          )}
        </tbody>
      </table>
    </div>
  );
}

