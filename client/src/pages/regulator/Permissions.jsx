import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

export default function Permissions() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeFilter, setActiveFilter] = useState('beyondStandard');
  const [animatedBars, setAnimatedBars] = useState(false);

  useEffect(() => {
    fetch('/api/regulator/permissions')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load permissions data');
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

  useEffect(() => {
    if (data) {
      const timer = setTimeout(() => {
        setAnimatedBars(true);
      }, 100);
      return () => clearTimeout(timer);
    }
  }, [data]);

  if (!data) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <div className="text-center">
          <div className="w-8 h-8 border-2 border-page-border border-t-brand-primary rounded-full animate-spin mx-auto mb-3"></div>
          <p className="text-sm text-status-neutral">Loading...</p>
        </div>
      </div>
    );
  }

  const {
    header,
    kpis,
    filterTabs,
    applicationsMeta,
    applications,
    applicationsFootnote,
    byKind,
    byKindFootnote,
    byKindCta,
    applicantView,
    pageFootnote
  } = data;

  return (
    <div className="w-full">
      {/* PAGE HEADER */}
      <div className="mt-2 flex flex-col sm:flex-row sm:items-start justify-between gap-4">
        <div>
          <h1 className="text-[26px] font-bold text-brand-primary tracking-tight">
            {header.title}
          </h1>
          <p className="mt-1 text-[14px] text-status-neutral leading-relaxed max-w-[600px]">
            {header.description}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap">
          <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer">
            Open the permission module
          </button>
          <button className="bg-status-info text-white rounded-lg px-4 py-2.5 text-[13px] font-semibold hover:bg-status-info-dark transition cursor-pointer">
            Dispose selected
          </button>
        </div>
      </div>

      {/* KPI ROW */}
      <div className="mt-8 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {kpis.map((kpi) => (
          <div key={kpi.id} className="bg-white border border-page-border rounded-xl p-5 flex flex-col justify-between">
            <div>
              <div className="text-[12px] font-semibold uppercase tracking-wider text-status-neutral flex items-center">
                {kpi.dot === 'critical' && (
                  <span className="w-2 h-2 rounded-full bg-status-critical inline-block mr-1.5" />
                )}
                {kpi.dot === 'warning' && (
                  <span className="w-2 h-2 rounded-full bg-status-warning inline-block mr-1.5" />
                )}
                {kpi.label}
              </div>
              <div className="mt-2 text-[30px] font-bold text-brand-primary leading-none flex items-baseline">
                <span>{kpi.value}</span>
                {kpi.suffix && (
                  <span className="text-[14px] text-status-neutral font-medium inline ml-1">
                    {kpi.suffix}
                  </span>
                )}
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* APPLICATIONS TABLE */}
      <div className="mt-8 bg-white border border-page-border rounded-xl overflow-hidden">
        <div className="px-5 pt-5 pb-4 flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3">
            <h2 className="text-lg font-semibold text-brand-primary">Applications pending</h2>
            <span className="text-[13px] text-status-neutral italic">{applicationsMeta}</span>
          </div>
          <div className="flex items-center gap-2 flex-wrap">
            {filterTabs.map((tab) => {
              const isActive = activeFilter === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveFilter(tab.id)}
                  className={`rounded-full px-4 py-1.5 text-[13px] font-medium border transition cursor-pointer ${
                    isActive
                      ? 'bg-brand-primary text-white border-brand-primary'
                      : 'border-page-border text-status-neutral-text hover:bg-page-bg'
                  }`}
                >
                  {tab.label}
                </button>
              );
            })}
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="bg-page-bg text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
                <th className="py-3 px-5 text-left">APPLICATION</th>
                <th className="py-3 px-5 text-left">MINE AND OPERATOR</th>
                <th className="py-3 px-5 text-left hidden md:table-cell">KIND</th>
                <th className="py-3 px-5 text-center">AGE</th>
                <th className="py-3 px-5 text-center">STANDARD</th>
                <th className="py-3 px-5 text-left hidden md:table-cell">HELD BY</th>
                <th className="py-3 px-5 text-right"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-page-border">
              {applications.map((app) => (
                <tr key={app.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                  <td className="py-3.5 px-5 text-[14px] text-brand-primary leading-snug">
                    {app.application}
                  </td>
                  <td className="py-3.5 px-5 text-[14px] text-status-neutral-text">
                    {app.mineOperator}
                  </td>
                  <td className="py-3.5 px-5 text-[14px] text-status-neutral-text hidden md:table-cell">
                    {app.kind}
                  </td>
                  <td className={`py-3.5 px-5 text-[14px] text-center font-semibold whitespace-nowrap ${
                    app.ageTone === 'critical'
                      ? 'text-status-critical'
                      : app.ageTone === 'warning'
                      ? 'text-status-warning'
                      : 'text-status-neutral'
                  }`}>
                    {app.age}
                  </td>
                  <td className="py-3.5 px-5 text-[14px] text-center text-status-neutral">
                    {app.standard}
                  </td>
                  <td className="py-3.5 px-5 text-[13px] text-status-neutral-text hidden md:table-cell">
                    {app.heldBy}
                  </td>
                  <td className="py-3.5 px-5 text-right">
                    <button
                      className={`rounded-lg px-4 py-1.5 text-[12px] font-semibold border transition cursor-pointer whitespace-nowrap ${
                        app.actionTone === 'critical'
                          ? 'bg-status-info text-white border-status-info hover:bg-status-info-dark'
                          : 'border-page-border text-status-neutral-text hover:bg-page-bg'
                      }`}
                    >
                      {app.action}
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic leading-relaxed">
          {applicationsFootnote}
        </div>
      </div>

      {/* BOTTOM TWO-COLUMN SECTION */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
        {/* LEFT — "By kind" */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-6">
            <h2 className="text-lg font-semibold text-brand-primary">By kind</h2>
            <span className="text-[13px] text-status-neutral italic">Pending, and how long they take</span>
          </div>

          <div className="space-y-5">
            {byKind.map((item, idx) => {
              const percent = Math.min(100, Math.round((item.count / item.maxCount) * 100));
              const barBg = item.color === 'critical' ? 'bg-status-critical' : 'bg-status-info';
              return (
                <div key={idx} className="flex items-center gap-4">
                  <span className="w-[80px] sm:w-[100px] flex-shrink-0 text-[14px] text-brand-primary text-right">
                    {item.kind}
                  </span>
                  <div className="flex-1 h-3.5 bg-page-bg rounded-full overflow-hidden">
                    <div
                      className={`h-full rounded-full ${barBg} transition-all duration-700`}
                      style={{ width: animatedBars ? `${percent}%` : '0%' }}
                    />
                  </div>
                  <span className="w-[24px] flex-shrink-0 text-right text-[14px] font-semibold text-brand-primary">
                    {item.count}
                  </span>
                </div>
              );
            })}
          </div>

          <p className="mt-5 text-[12px] text-status-neutral leading-relaxed">
            {byKindFootnote}
          </p>

          <button className="mt-4 border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer inline-block">
            {byKindCta}
          </button>
        </div>

        {/* RIGHT — "Applicant's view" */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-3">
            <h2 className="text-lg font-semibold text-brand-primary">{applicantView.title}</h2>
            <span className="text-[13px] text-status-neutral italic">{applicantView.subtitle}</span>
          </div>

          <p className="mb-5 text-[13px] text-status-neutral leading-relaxed">
            {applicantView.description}
          </p>

          <div className="space-y-3">
            {applicantView.items.map((item) => (
              <div key={item.id} className="bg-page-bg rounded-xl p-4 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
                <div>
                  <h3 className="text-[15px] font-semibold text-brand-primary">{item.title}</h3>
                  <div className="mt-0.5 text-[13px] text-status-neutral">{item.filed}</div>
                </div>
                <div className="flex items-center gap-3 flex-shrink-0">
                  <span className="text-[13px] font-medium text-brand-primary">{item.stage}</span>
                  <span className={`rounded-full px-3 py-1 text-[12px] font-medium border whitespace-nowrap ${
                    item.stageTone === 'warning'
                      ? 'bg-status-warning-bg text-status-warning-text border-status-warning-border'
                      : item.stageTone === 'critical'
                      ? 'bg-status-critical-bg text-status-critical border-status-critical-border'
                      : 'border-page-border text-status-neutral-text'
                  }`}>
                    {item.stageLabel}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* PAGE FOOTER */}
      <div className="mt-8 mb-4 text-center text-[12px] text-status-neutral/60 italic">
        {pageFootnote}
      </div>
    </div>
  );
}
