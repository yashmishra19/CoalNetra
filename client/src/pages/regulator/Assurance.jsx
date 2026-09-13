import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

export default function Assurance() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetch('/api/regulator/assurance')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load assurance data');
        return res.json();
      })
      .then((json) => {
        setData(json);
        setLoading(false);
      })
      .catch((err) => {
        console.error(err);
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24 text-status-neutral gap-3">
        <Loader2 className="animate-spin" size={24} />
        <span className="text-[14px]">Loading assurance & reporting data...</span>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="py-12 text-center text-status-critical text-[14px]">
        {error || 'Unable to load assurance & reporting data.'}
      </div>
    );
  }

  const {
    header,
    provenance,
    notReporting,
    integrityCheck,
    whatOfficeReceives,
    returnsFromOffice,
    pageFootnote
  } = data;

  return (
    <div className="w-full">
      {/* PAGE HEADER */}
      <div className="mt-2 flex flex-col sm:flex-row sm:items-start justify-between gap-4">
        <div>
          <h1 className="text-[28px] font-bold text-brand-primary tracking-tight">
            {header.title}
          </h1>
          <p className="mt-1 text-[14px] text-status-neutral leading-relaxed max-w-[600px]">
            {header.description}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap">
          <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer">
            Run integrity check
          </button>
          <button className="bg-brand-primary text-white rounded-lg px-5 py-2.5 text-[13px] font-semibold hover:bg-brand-dark transition cursor-pointer">
            Build monthly return
          </button>
        </div>
      </div>

      {/* TOP SECTION */}
      <div className="mt-6 grid grid-cols-1 xl:grid-cols-[1fr_380px] gap-6 items-start">
        {/* LEFT — Provenance card */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-4">
            <h2 className="text-lg font-semibold text-brand-primary">{provenance.title}</h2>
            <span className="text-[13px] text-status-neutral italic">{provenance.subtitle}</span>
          </div>

          {/* Stacked bar */}
          <div className="h-7 rounded-full overflow-hidden flex mb-4">
            {provenance.segments.map((segment, idx) => (
              <div
                key={idx}
                className={`h-full ${idx === 0 ? 'rounded-l-full' : ''} ${
                  idx === provenance.segments.length - 1 ? 'rounded-r-full' : ''
                }`}
                style={{ width: `${segment.value}%`, backgroundColor: segment.color }}
                title={`${segment.label}: ${segment.value}%`}
              />
            ))}
          </div>

          {/* Legend */}
          <div className="flex flex-wrap gap-x-5 gap-y-2 mb-5">
            {provenance.segments.map((segment, idx) => (
              <div key={idx} className="flex items-center gap-2 text-[13px] text-status-neutral-text">
                <span
                  className="w-3 h-3 rounded-sm flex-shrink-0"
                  style={{ backgroundColor: segment.color }}
                />
                <span>
                  <strong className="font-semibold text-brand-primary">{segment.value}%</strong> {segment.label}
                </span>
              </div>
            ))}
          </div>

          {/* Records table */}
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-page-bg text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
                  <th className="py-2.5 px-4 text-left">KIND OF RECORD</th>
                  <th className="py-2.5 px-4 text-right">THIS MONTH</th>
                  <th className="py-2.5 px-4 text-left">ESTABLISHED BY</th>
                  <th className="py-2.5 px-4 text-left">CAN IT BE CHECKED LATER</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-page-border">
                {provenance.records.map((rec) => (
                  <tr key={rec.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                    <td className="py-3 px-4 text-[14px] text-brand-primary">
                      {rec.kind}
                    </td>
                    <td className="py-3 px-4 text-[14px] text-right font-semibold text-brand-primary">
                      {rec.thisMonth}
                    </td>
                    <td className="py-3 px-4 text-[14px]">
                      <span className={`rounded px-2.5 py-1 text-[12px] font-medium border inline-flex items-center gap-1.5 ${
                        rec.establishedTone === 'info'
                          ? 'bg-status-info-bg text-status-info-text border-status-info-border'
                          : rec.establishedTone === 'warning'
                          ? 'bg-status-warning-bg text-status-warning-text border-status-warning-border'
                          : 'bg-status-critical-bg text-status-critical border-status-critical-border'
                      }`}>
                        <span className={`w-2.5 h-2.5 rounded-sm ${
                          rec.establishedTone === 'info'
                            ? 'bg-status-info'
                            : rec.establishedTone === 'warning'
                            ? 'bg-status-warning'
                            : 'bg-status-critical'
                        }`} />
                        {rec.establishedBy}
                      </span>
                    </td>
                    <td className={`py-3 px-4 text-[14px] ${
                      rec.canBeCheckedTone === 'critical'
                        ? 'text-status-critical font-semibold'
                        : 'text-status-neutral-text'
                    }`}>
                      {rec.canBeChecked}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <p className="mt-4 text-[12px] text-status-neutral italic leading-relaxed">
            {provenance.footnote}
          </p>
        </div>

        {/* RIGHT COLUMN (Not reporting + Integrity check) */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-1 gap-6">
          {/* CARD A — "Not reporting" */}
          <div className="bg-white border border-page-border rounded-xl overflow-hidden">
            <div className="px-5 pt-5 pb-3 flex items-center gap-3">
              <h2 className="text-lg font-semibold text-brand-primary">{notReporting.title}</h2>
              <span className="text-[13px] text-status-neutral italic">{notReporting.subtitle}</span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="bg-page-bg text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
                    <th className="py-2.5 px-5 text-left">MINE</th>
                    <th className="py-2.5 px-5 text-left">OPERATOR</th>
                    <th className="py-2.5 px-5 text-left">MISSING</th>
                    <th className="py-2.5 px-5 text-right">TIMES</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-page-border">
                  {notReporting.items.map((item) => (
                    <tr key={item.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                      <td className="py-3 px-5 text-[14px] text-brand-primary font-medium">
                        {item.mine}
                      </td>
                      <td className="py-3 px-5 text-[13px] text-status-neutral">
                        {item.operator}
                      </td>
                      <td className="py-3 px-5 text-[13px] text-status-neutral-text">
                        {item.missing}
                      </td>
                      <td className="py-3 px-5 text-[13px] text-right font-bold text-status-critical">
                        {item.times}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic">
              {notReporting.footnote}
            </div>
          </div>

          {/* CARD B — "Integrity check" */}
          <div className="bg-white border border-page-border rounded-xl overflow-hidden">
            <div className="px-5 pt-5 pb-3 flex items-center gap-3">
              <h2 className="text-lg font-semibold text-brand-primary">{integrityCheck.title}</h2>
              <span className="text-[13px] text-status-neutral italic">{integrityCheck.subtitle}</span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full">
                <thead>
                  <tr className="bg-page-bg text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
                    <th className="py-2.5 px-5 text-left">RECORD</th>
                    <th className="py-2.5 px-5 text-left">OPERATOR</th>
                    <th className="py-2.5 px-5 text-left">SEALED</th>
                    <th className="py-2.5 px-5 text-left">RESULT</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-page-border">
                  {integrityCheck.items.map((item) => (
                    <tr key={item.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                      <td className="py-3 px-5 text-[14px] text-brand-primary">
                        {item.record}
                      </td>
                      <td className="py-3 px-5 text-[13px] text-status-neutral">
                        {item.operator}
                      </td>
                      <td className="py-3 px-5 text-[13px] text-status-neutral whitespace-nowrap">
                        {item.sealed}
                      </td>
                      <td className="py-3 px-5 text-[13px]">
                        <span className={`rounded-full px-3 py-1 text-[12px] font-medium border whitespace-nowrap inline-block ${
                          item.resultTone === 'good'
                            ? 'bg-status-good-bg text-status-good border-status-good-border'
                            : 'bg-status-critical-bg text-status-critical border-status-critical-border'
                        }`}>
                          {item.result}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic leading-relaxed">
              {integrityCheck.footnote}
            </div>
          </div>
        </div>
      </div>

      {/* BOTTOM SECTION */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
        {/* LEFT — "What this office receives, and what it does not" */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-3">
            <h2 className="text-[17px] font-semibold text-brand-primary">{whatOfficeReceives.title}</h2>
            <span className="text-[13px] text-status-neutral italic">{whatOfficeReceives.subtitle}</span>
          </div>

          <p className="mb-5 text-[13px] text-status-neutral leading-relaxed">
            {whatOfficeReceives.description}
          </p>

          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-page-bg text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
                  <th className="py-2.5 px-4 text-left">CATEGORY</th>
                  <th className="py-2.5 px-4 text-left">RECEIVED</th>
                  <th className="py-2.5 px-4 text-left hidden md:table-cell">WHEN</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-page-border">
                {whatOfficeReceives.categories.map((cat) => (
                  <tr key={cat.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                    <td className="py-3 px-4 text-[14px] text-brand-primary leading-snug">
                      {cat.category}
                    </td>
                    <td className="py-3 px-4 text-[14px]">
                      {cat.receivedTone === null ? (
                        <span className="text-status-neutral-text">{cat.received}</span>
                      ) : (
                        <span className={`rounded px-2.5 py-0.5 text-[12px] font-medium border inline-block ${
                          cat.receivedTone === 'warning'
                            ? 'bg-status-warning-bg text-status-warning-text border-status-warning-border'
                            : 'bg-status-critical-bg text-status-critical border-status-critical-border'
                        }`}>
                          {cat.received}
                        </span>
                      )}
                    </td>
                    <td className="py-3 px-4 text-[13px] text-status-neutral hidden md:table-cell">
                      {cat.when}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <p className="mt-4 text-[12px] text-status-neutral italic leading-relaxed">
            {whatOfficeReceives.footnote}
          </p>
        </div>

        {/* RIGHT — "Returns from this office" */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-3">
            <h2 className="text-lg font-semibold text-brand-primary">{returnsFromOffice.title}</h2>
            <span className="text-[13px] text-status-neutral italic">{returnsFromOffice.subtitle}</span>
          </div>

          <div className="divide-y divide-page-border">
            {returnsFromOffice.items.map((item) => (
              <div key={item.id} className="py-4 border-b border-page-border last:border-b-0 flex flex-col md:flex-row md:items-start justify-between gap-4">
                <div className="flex items-start gap-3 flex-1">
                  {item.dot === 'critical' ? (
                    <span className="w-2.5 h-2.5 rounded-full bg-status-critical flex-shrink-0 mt-1.5" />
                  ) : (
                    <span className="w-2.5 h-2.5 rounded-full bg-status-neutral flex-shrink-0 mt-1.5" />
                  )}
                  <div>
                    <h3 className="text-[15px] font-semibold text-brand-primary leading-snug">
                      {item.title}
                    </h3>
                    <p className="mt-0.5 text-[13px] text-status-neutral leading-relaxed">
                      {item.description}
                    </p>
                  </div>
                </div>

                <div className="flex-shrink-0 flex items-center gap-3 justify-between md:justify-end w-full md:w-auto">
                  <div className="text-right">
                    <div className="text-[15px] font-bold text-brand-primary">{item.dueIn}</div>
                    <div className="text-[12px] text-status-neutral">{item.dueBy}</div>
                  </div>
                  <button className={`rounded-lg px-3.5 py-1.5 text-[12px] font-semibold transition cursor-pointer whitespace-nowrap ${
                    item.actionTone === 'primary'
                      ? 'bg-brand-primary text-white hover:bg-brand-dark'
                      : 'border border-page-border text-status-neutral-text hover:bg-page-bg'
                  }`}>
                    {item.action}
                  </button>
                </div>
              </div>
            ))}
          </div>

          <p className="mt-4 pt-4 border-t border-page-border text-[12px] text-status-neutral italic leading-relaxed">
            {returnsFromOffice.footnote}
          </p>
        </div>
      </div>

      {/* PAGE FOOTER */}
      <div className="mt-8 mb-4 text-center text-[12px] text-status-neutral/60 italic">
        {pageFootnote}
      </div>
    </div>
  );
}
