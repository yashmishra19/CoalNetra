import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

export default function Inspections() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [animatedBars, setAnimatedBars] = useState(false);

  useEffect(() => {
    fetch('/api/regulator/inspections')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load inspections data');
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

  const { header, kpis, proposedPlan, coverageByDiscipline, coverageFootnote, findingsByDefect, findingsFootnote, recentInspections, pageFootnote } = data;

  const getBarColorClass = (color) => {
    if (color === 'critical') return 'bg-status-critical';
    if (color === 'warning') return 'bg-status-warning';
    return 'bg-status-info';
  };

  return (
    <div className="w-full font-sans">
      {/* PAGE HEADER */}
      <div className="mt-2 flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h1 className="text-[26px] font-bold text-brand-primary tracking-tight">
            {header.title}
          </h1>
          <p className="mt-1 text-[14px] text-status-neutral leading-relaxed max-w-[550px]">
            {header.description}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap">
          <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer whitespace-nowrap">
            Record an inspection
          </button>
          <button className="bg-status-info text-white rounded-lg px-4 py-2.5 text-[13px] font-semibold hover:bg-status-info-dark transition cursor-pointer whitespace-nowrap">
            Generate October plan
          </button>
        </div>
      </div>

      {/* KPI ROW */}
      <div className="mt-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        {kpis &&
          kpis.map((kpi) => (
            <div key={kpi.id} className="bg-white border border-page-border rounded-xl p-5 flex flex-col justify-between">
              <div>
                <div className="text-[12px] font-semibold uppercase tracking-wider text-status-neutral">
                  {kpi.label}
                </div>
                <div className="mt-2 flex items-baseline gap-1.5">
                  <span className="text-[30px] font-bold text-brand-primary leading-none">
                    {kpi.value}
                  </span>
                  {kpi.suffix && (
                    <span className="text-[14px] text-status-neutral font-medium">
                      {kpi.suffix}
                    </span>
                  )}
                </div>
              </div>
              <div className="mt-1 text-[12px] text-status-neutral leading-snug">
                {kpi.detail}
              </div>
            </div>
          ))}
      </div>

      {/* PROPOSED PLAN SECTION */}
      <div className="mt-8">
        <div className="flex items-center gap-3 mb-4 flex-wrap">
          <h2 className="text-xl font-semibold text-brand-primary">
            {proposedPlan.title}
          </h2>
          <span className="text-[13px] text-status-neutral italic">
            {proposedPlan.subtitle}
          </span>
        </div>

        {/* Table Container */}
        <div className="bg-white border border-page-border rounded-xl overflow-hidden overflow-x-auto">
          <table className="w-full min-w-[750px] border-collapse">
            <thead>
              <tr className="bg-page-bg border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">DAYS</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">MINE OR CLUSTER</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">DISTRICT</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden md:table-cell">OFFICER</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">DISCIPLINE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden xl:table-cell">WHY</th>
              </tr>
            </thead>
            <tbody>
              {proposedPlan.items &&
                proposedPlan.items.map((item) => (
                  <tr key={item.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors cursor-pointer">
                    <td className="py-3.5 px-5 text-[14px] text-brand-primary font-medium whitespace-nowrap">
                      {item.days}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-info font-medium">
                      {item.mine}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text">
                      {item.district}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text hidden md:table-cell">
                      {item.officer}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text">
                      {item.discipline}
                    </td>
                    <td className="py-3.5 px-5 text-[13px] text-status-neutral-text leading-snug hidden xl:table-cell">
                      {item.why}
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>

        {/* Footnote */}
        <div className="mt-3 px-1 text-[12px] text-status-neutral italic leading-relaxed">
          {proposedPlan.footnote}
        </div>
      </div>

      {/* MIDDLE TWO-COLUMN SECTION */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">

        {/* LEFT — Coverage by discipline */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-6 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Coverage by discipline</h3>
            <span className="text-[13px] text-status-neutral italic">This quarter, against programme</span>
          </div>

          <div className="space-y-5">
            {coverageByDiscipline &&
              coverageByDiscipline.map((item) => {
                const widthPct = animatedBars ? (item.done / item.total) * 100 : 0;
                return (
                  <div key={item.discipline} className="flex items-center gap-4">
                    <div className="w-[100px] sm:w-[130px] flex-shrink-0 text-[14px] text-brand-primary text-right leading-tight">
                      {item.discipline}
                    </div>
                    <div className="flex-1 h-4 bg-page-bg rounded-full overflow-hidden relative">
                      <div
                        className={`h-full rounded-full transition-all duration-700 ease-out ${getBarColorClass(item.color)}`}
                        style={{ width: `${widthPct}%` }}
                      />
                    </div>
                    <div className="flex-shrink-0 w-[50px] text-[14px] font-semibold text-brand-primary text-right">
                      {item.done}/{item.total}
                    </div>
                  </div>
                );
              })}
          </div>

          <p className="mt-5 text-[12px] text-status-neutral leading-relaxed">
            {coverageFootnote}
          </p>
        </div>

        {/* RIGHT — Findings by nature of defect */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-6 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Findings by nature of defect</h3>
            <span className="text-[13px] text-status-neutral italic">This quarter, all mines</span>
          </div>

          <div className="space-y-3.5">
            {findingsByDefect &&
              findingsByDefect.map((item) => {
                const maxCount = 42;
                const widthPct = animatedBars ? (item.count / maxCount) * 100 : 0;
                return (
                  <div key={item.defect} className="flex items-center gap-4">
                    <div className="w-[130px] sm:w-[170px] flex-shrink-0 text-[13px] text-brand-primary text-right leading-tight">
                      {item.defect}
                    </div>
                    <div className="flex-1 h-3.5 bg-page-bg rounded-full overflow-hidden">
                      <div
                        className={`h-full rounded-full transition-all duration-700 ease-out ${getBarColorClass(item.color)}`}
                        style={{ width: `${widthPct}%` }}
                      />
                    </div>
                    <div className="flex-shrink-0 w-[30px] text-[13px] font-semibold text-brand-primary text-right">
                      {item.count}
                    </div>
                  </div>
                );
              })}
          </div>

          <p className="mt-5 text-[12px] text-status-neutral leading-relaxed">
            {findingsFootnote}
          </p>
        </div>
      </div>

      {/* RECENT INSPECTION RECORDS */}
      <div className="mt-8 bg-white border border-page-border rounded-xl overflow-hidden">
        {/* Header */}
        <div className="px-5 pt-5 pb-4 flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Recent inspection records</h3>
            <span className="text-[13px] text-status-neutral italic">
              Findings entered by the officer on site, not supplied by the operator
            </span>
          </div>

          <div className="flex items-center gap-2 border border-page-border rounded-lg px-3 py-1.5 bg-page-bg/50">
            <span className="w-3 h-3 rounded-sm bg-brand-primary flex-shrink-0" />
            <span className="text-[12px] text-status-neutral-text font-medium">Inspector recorded</span>
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full min-w-[750px] border-collapse">
            <thead>
              <tr className="bg-page-bg border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">DATE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">MINE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden sm:table-cell">OFFICER</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden sm:table-cell">DISCIPLINE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-center">FINDINGS</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-center">OPEN</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">ACTION TAKEN</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">REPORT</th>
              </tr>
            </thead>
            <tbody>
              {recentInspections &&
                recentInspections.map((row) => (
                  <tr key={row.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors cursor-pointer">
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text whitespace-nowrap">
                      {row.date}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-info font-medium">
                      {row.mine}
                    </td>
                    <td className="py-3.5 px-5 text-[13px] text-status-neutral-text hidden sm:table-cell">
                      {row.officer}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text hidden sm:table-cell">
                      {row.discipline}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-center font-semibold text-brand-primary">
                      {row.findings}
                    </td>
                    <td className={`py-3.5 px-5 text-[14px] text-center ${row.open > 0 ? 'font-semibold text-brand-primary' : 'text-status-neutral'}`}>
                      {row.open}
                    </td>
                    <td className={`py-3.5 px-5 text-[13px] ${row.actionTone === 'critical' ? 'text-status-critical font-semibold' : 'text-status-neutral-text'}`}>
                      {row.actionTaken}
                    </td>
                    <td className="py-3.5 px-5 text-[14px]">
                      <button className="text-status-info text-[13px] font-medium cursor-pointer hover:text-status-info-dark transition">
                        {row.report}
                      </button>
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* PAGE FOOTER */}
      <div className="mt-8 mb-4 text-center text-[12px] text-status-neutral/60 italic">
        {pageFootnote}
      </div>
    </div>
  );
}
