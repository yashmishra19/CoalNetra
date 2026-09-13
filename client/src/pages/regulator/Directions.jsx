import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

export default function Directions() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeFilter, setActiveFilter] = useState('pastDate');
  const [animatedBars, setAnimatedBars] = useState(false);

  useEffect(() => {
    fetch('/api/regulator/directions')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load directions data');
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

  if (loading) {
    return (
      <div className="flex items-center justify-center py-24 text-status-neutral gap-3">
        <Loader2 className="animate-spin" size={24} />
        <span className="text-[14px]">Loading directions data...</span>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="py-12 text-center text-status-critical text-[14px]">
        {error || 'Unable to load directions data.'}
      </div>
    );
  }

  const { header, kpis, focusedDirection, prohibitionOrders, complianceOutcomes, allOpenDirections, pageFootnote } = data;

  const getEvidenceBg = (tone) => {
    if (tone === 'good') return 'bg-status-good';
    if (tone === 'warning') return 'bg-status-warning';
    if (tone === 'critical') return 'bg-status-critical';
    return 'bg-status-neutral';
  };

  const getEvidenceText = (tone) => {
    if (tone === 'good') return 'text-status-good';
    if (tone === 'warning') return 'text-status-warning';
    if (tone === 'critical') return 'text-status-critical';
    return 'text-status-neutral-text';
  };

  const getBarColorClass = (color) => {
    if (color === 'info') return 'bg-status-info';
    if (color === 'warning') return 'bg-status-warning';
    if (color === 'critical') return 'bg-status-critical';
    return 'bg-brand-primary';
  };

  return (
    <div className="w-full font-sans">
      {/* PAGE HEADER */}
      <div className="mt-2 flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h1 className="text-[28px] font-bold text-brand-primary tracking-tight">
            {header.title}
          </h1>
          <p className="mt-1 text-[14px] text-status-neutral leading-relaxed max-w-[600px]">
            {header.description}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap">
          <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer whitespace-nowrap">
            Issue an improvement notice
          </button>
          <button className="border-2 border-status-critical rounded-lg px-4 py-2.5 text-[13px] font-semibold text-status-critical hover:bg-status-critical hover:text-white transition cursor-pointer whitespace-nowrap">
            Issue a prohibition order
          </button>
        </div>
      </div>

      {/* KPI ROW */}
      <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {kpis &&
          kpis.map((kpi) => (
            <div key={kpi.id} className="bg-white border border-page-border rounded-xl p-5 flex flex-col justify-between">
              <div className="flex items-baseline">
                <span className="text-[36px] font-bold text-brand-primary leading-none">
                  {kpi.value}
                </span>
                {kpi.suffix && (
                  <span className="text-[16px] text-status-neutral font-medium ml-1">
                    {kpi.suffix}
                  </span>
                )}
              </div>
              <div className="mt-2 text-[13px] text-status-neutral leading-snug">
                {kpi.dot === 'critical' && (
                  <span className="w-2 h-2 rounded-full bg-status-critical inline-block mr-1.5 relative -top-[1px]" />
                )}
                {kpi.label}
              </div>
            </div>
          ))}
      </div>

      {/* MIDDLE SECTION */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-[1fr_400px] gap-6 items-start">

        {/* LEFT — Focused direction detail */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">
              {focusedDirection.title}
            </h3>
            <span className="rounded-full bg-status-critical text-white text-[12px] font-semibold px-3 py-1">
              {focusedDirection.badge}
            </span>
          </div>

          <p className="mt-3 text-[14px] text-status-neutral-text leading-relaxed">
            {focusedDirection.description}
          </p>

          {/* Enforcement Ladder */}
          <div className="mt-5 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-0 rounded-lg overflow-hidden border border-page-border">
            {focusedDirection.steps.map((step, idx) => {
              const isActive = step.active;
              return (
                <div
                  key={step.number}
                  className={`py-3 px-4 transition-colors ${
                    idx < focusedDirection.steps.length - 1 ? 'border-b lg:border-b-0 lg:border-r border-page-border' : ''
                  } ${isActive ? 'bg-brand-primary text-white shadow-sm' : 'bg-white'}`}
                >
                  <div className={`text-[10px] font-bold uppercase tracking-widest ${isActive ? 'text-white/80' : 'text-status-neutral'}`}>
                    STEP {step.number}
                  </div>
                  <div className={`text-[13px] font-medium mt-1 ${isActive ? 'text-white' : 'text-status-neutral-text'}`}>
                    {step.label}
                  </div>
                </div>
              );
            })}
          </div>

          <p className="mt-4 text-[13px] text-status-neutral leading-relaxed">
            {focusedDirection.stepsNote}
          </p>

          {/* Compliance Table */}
          <div className="mt-5 bg-white border border-page-border rounded-xl overflow-hidden overflow-x-auto">
            <table className="w-full min-w-[500px] border-collapse">
              <thead>
                <tr className="bg-page-bg border-b border-page-border">
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-4 text-left">MINE</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-4 text-left">DUE</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-4 text-left">EVIDENCE RECEIVED</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-4 text-center">STATUS</th>
                </tr>
              </thead>
              <tbody>
                {focusedDirection.complianceTable.map((row) => {
                  let statusStyle = 'bg-status-good-bg text-status-good border-status-good-border';
                  if (row.statusTone === 'critical') statusStyle = 'bg-status-critical-bg text-status-critical border-status-critical-border';
                  if (row.statusTone === 'warning') statusStyle = 'bg-status-warning-bg text-status-warning-text border-status-warning-border';

                  return (
                    <tr key={row.id} className="border-t border-page-border">
                      <td className="py-3 px-4 text-[14px] text-brand-primary font-medium">
                        {row.mine}
                      </td>
                      <td className="py-3 px-4 text-[14px] text-status-neutral">
                        {row.due}
                      </td>
                      <td className="py-3 px-4 text-[14px]">
                        <div className="flex items-center gap-2">
                          {row.evidenceIcon && (
                            <span className={`w-2.5 h-2.5 rounded-sm inline-block flex-shrink-0 ${getEvidenceBg(row.evidenceTone)}`} />
                          )}
                          <span className={`text-[13px] ${getEvidenceText(row.evidenceTone)}`}>
                            {row.evidence}
                          </span>
                        </div>
                      </td>
                      <td className="py-3 px-4 text-[14px] text-center">
                        <span className={`rounded-full px-3 py-1 text-[12px] font-medium border inline-block whitespace-nowrap ${statusStyle}`}>
                          {row.status}
                        </span>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          <p className="mt-4 text-[12px] text-status-neutral italic leading-relaxed">
            {focusedDirection.footnote}
          </p>
        </div>

        {/* RIGHT COLUMN */}
        <div className="flex flex-col gap-6">

          {/* CARD A — Prohibition orders in force */}
          <div className="bg-white border border-page-border rounded-xl overflow-hidden">
            <div className="px-5 pt-5 pb-3 flex items-center gap-3 flex-wrap">
              <h3 className="text-lg font-semibold text-brand-primary">
                {prohibitionOrders.title}
              </h3>
              <span className="text-[13px] text-status-neutral italic">
                {prohibitionOrders.subtitle}
              </span>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full min-w-[360px] border-collapse">
                <thead>
                  <tr className="border-b border-page-border">
                    <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">MINE</th>
                    <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">SCOPE</th>
                    <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">FROM</th>
                    <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-center">DAYS</th>
                    <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">GROUND</th>
                  </tr>
                </thead>
                <tbody>
                  {prohibitionOrders.items.map((po) => {
                    let daysStyle = 'text-brand-primary font-bold';
                    if (po.days > 60) daysStyle = 'text-status-critical font-bold';
                    else if (po.days > 30) daysStyle = 'text-status-warning font-bold';

                    return (
                      <tr key={po.id} className="border-t border-page-border">
                        <td className="py-3 px-5 text-[14px] text-brand-primary font-medium whitespace-nowrap">
                          {po.mine}
                        </td>
                        <td className="py-3 px-5 text-[13px] text-status-neutral whitespace-nowrap">
                          {po.scope}
                        </td>
                        <td className="py-3 px-5 text-[13px] text-status-neutral whitespace-nowrap">
                          {po.from}
                        </td>
                        <td className={`py-3 px-5 text-[13px] text-center ${daysStyle}`}>
                          {po.days}
                        </td>
                        <td className="py-3 px-5 text-[13px] text-status-neutral-text leading-snug">
                          {po.ground}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>

            <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic">
              {prohibitionOrders.footnote}
            </div>
          </div>

          {/* CARD B — What happens after a direction */}
          <div className="bg-white border border-page-border rounded-xl p-5">
            <div className="flex items-center gap-3 mb-5 flex-wrap">
              <h3 className="text-[17px] font-semibold text-brand-primary">
                {complianceOutcomes.title}
              </h3>
              <span className="text-[13px] text-status-neutral italic">
                {complianceOutcomes.subtitle}
              </span>
            </div>

            <div className="space-y-4">
              {complianceOutcomes.items.map((item) => {
                const widthPct = animatedBars ? item.value : 0;
                return (
                  <div key={item.label} className="flex items-center gap-4">
                    <div className="flex-1 text-[14px] text-brand-primary">
                      {item.label}
                    </div>
                    <div className="w-[140px] sm:w-[180px] h-3 bg-page-bg rounded-full overflow-hidden flex-shrink-0">
                      <div
                        className={`h-full rounded-full transition-all duration-700 ease-out ${getBarColorClass(item.color)}`}
                        style={{ width: `${widthPct}%`, minWidth: item.value > 0 ? '8px' : '0px' }}
                      />
                    </div>
                    <div className="w-[40px] text-right flex-shrink-0 text-[14px] font-medium text-brand-primary">
                      {item.value}%
                    </div>
                  </div>
                );
              })}
            </div>

            <p className="mt-4 text-[12px] text-status-neutral leading-relaxed">
              {complianceOutcomes.footnote}
            </p>
          </div>

        </div>
      </div>

      {/* ALL OPEN DIRECTIONS TABLE */}
      <div className="mt-8 bg-white border border-page-border rounded-xl overflow-hidden">
        {/* Header */}
        <div className="px-5 pt-5 pb-4 flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">
              {allOpenDirections.title}
            </h3>
            <span className="text-[13px] text-status-neutral">
              {allOpenDirections.meta}
            </span>
          </div>

          {/* Filter Pills */}
          <div className="flex items-center gap-2 flex-wrap">
            {allOpenDirections.filterTabs.map((tab) => {
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

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full min-w-[850px] border-collapse">
            <thead>
              <tr className="bg-page-bg border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">DIRECTION</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">MINE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden sm:table-cell">OPERATOR</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">ISSUED</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">PAST DATE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">EVIDENCE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">REPEAT</th>
                <th className="py-3 px-5"></th>
              </tr>
            </thead>
            <tbody>
              {allOpenDirections.items.map((item) => {
                let pastDateStyle = 'text-status-neutral-text font-semibold whitespace-nowrap';
                if (item.pastDateTone === 'critical') pastDateStyle = 'text-status-critical font-semibold whitespace-nowrap';
                if (item.pastDateTone === 'warning') pastDateStyle = 'text-status-warning font-semibold whitespace-nowrap';

                let actionBtnStyle = 'border-page-border text-status-neutral-text hover:bg-page-bg';
                if (item.actionTone === 'critical') actionBtnStyle = 'bg-brand-primary text-white border-brand-primary hover:bg-brand-dark';
                if (item.actionTone === 'good') actionBtnStyle = 'bg-status-good text-white border-status-good hover:bg-status-good-dark';

                return (
                  <tr key={item.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                    <td className="py-3.5 px-5 text-[14px] text-brand-primary leading-snug max-w-[300px]">
                      {item.direction}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text">
                      {item.mine}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text hidden sm:table-cell">
                      {item.operator}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral whitespace-nowrap">
                      {item.issued}
                    </td>
                    <td className={`py-3.5 px-5 text-[14px] ${pastDateStyle}`}>
                      {item.pastDate}
                    </td>
                    <td className="py-3.5 px-5 text-[14px]">
                      <div className="flex items-center gap-2">
                        {item.evidenceIcon && (
                          <span className={`w-2.5 h-2.5 rounded-sm inline-block flex-shrink-0 ${getEvidenceBg(item.evidenceTone)}`} />
                        )}
                        <span className={`text-[13px] ${getEvidenceText(item.evidenceTone)}`}>
                          {item.evidence}
                        </span>
                      </div>
                    </td>
                    <td className="py-3.5 px-5 text-[14px]">
                      {item.repeatTone === 'critical' ? (
                        <span className="text-[12px] font-semibold text-status-critical bg-status-critical-bg border border-status-critical-border rounded px-2 py-0.5 inline-block">
                          {item.repeat}
                        </span>
                      ) : (
                        <span className="text-[13px] text-status-neutral">{item.repeat}</span>
                      )}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-right">
                      <button
                        className={`rounded-lg px-3.5 py-1.5 text-[12px] font-semibold border transition cursor-pointer whitespace-nowrap ${actionBtnStyle}`}
                        onClick={() => {}}
                      >
                        {item.action}
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Footer */}
        <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic leading-relaxed">
          {allOpenDirections.footnote}
        </div>
      </div>

      {/* PAGE FOOTER */}
      <div className="mt-8 mb-4 text-center text-[12px] text-status-neutral/60 italic">
        {pageFootnote}
      </div>
    </div>
  );
}
