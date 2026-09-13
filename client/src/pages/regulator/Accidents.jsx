import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

export default function Accidents() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [animatedBars, setAnimatedBars] = useState(false);

  useEffect(() => {
    fetch('/api/regulator/accidents')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load accidents data');
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
        <span className="text-[14px]">Loading accidents & inquiries data...</span>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="py-12 text-center text-status-critical text-[14px]">
        {error || 'Unable to load accidents data.'}
      </div>
    );
  }

  const { header, kpis, notifications, causes, causesFootnote, inquiryRecommendations, pageFootnote } = data;

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
          <h1 className="text-[28px] font-bold text-brand-primary tracking-tight">
            {header.title}
          </h1>
          <p className="mt-1 text-[14px] text-status-neutral leading-relaxed max-w-[600px]">
            {header.description}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap">
          <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer whitespace-nowrap">
            Push to national portal
          </button>
          <button className="bg-status-critical text-white rounded-lg px-5 py-2.5 text-[13px] font-semibold hover:bg-status-critical-dark transition cursor-pointer whitespace-nowrap">
            Open a court of inquiry
          </button>
        </div>
      </div>

      {/* KPI ROW */}
      <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-3">
        {kpis &&
          kpis.map((kpi) => (
            <div key={kpi.id} className="bg-white border border-page-border rounded-xl p-4 flex flex-col justify-between">
              <div>
                <div className={`h-1 rounded-full w-12 mb-3 ${getBarColorClass(kpi.barColor)}`} />
                <div className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
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
              {kpi.detail && (
                <div className="mt-2 text-[12px] text-status-neutral leading-snug">
                  {kpi.detail}
                </div>
              )}
            </div>
          ))}
      </div>

      {/* NOTIFICATIONS TABLE */}
      <div className="mt-8 bg-white border border-page-border rounded-xl overflow-hidden">
        <div className="px-5 pt-5 pb-4 flex items-center gap-3 flex-wrap">
          <h2 className="text-lg font-semibold text-brand-primary">
            {notifications.title}
          </h2>
          <span className="text-[13px] text-status-neutral italic">
            {notifications.subtitle}
          </span>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full min-w-[800px] border-collapse">
            <thead>
              <tr className="bg-page-bg border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">EVENT</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">MINE AND OPERATOR</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">OCCURRED</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden md:table-cell">PHONED</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left hidden md:table-cell">WRITTEN NOTICE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">WINDOW</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">INQUIRY</th>
              </tr>
            </thead>
            <tbody>
              {notifications.items.map((row) => {
                let windowStyle = 'bg-status-good-bg text-status-good border-status-good-border';
                if (row.windowTone === 'critical') windowStyle = 'bg-status-critical-bg text-status-critical border-status-critical-border';

                return (
                  <tr key={row.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors">
                    <td className="py-3.5 px-5 text-[14px] text-brand-primary font-medium">
                      {row.event}
                    </td>
                    <td className="py-3.5 px-5 text-[14px] text-status-neutral-text">
                      {row.mineOperator}
                    </td>
                    <td className="py-3.5 px-5 text-[13px] text-status-neutral whitespace-nowrap">
                      {row.occurred}
                    </td>
                    <td className="py-3.5 px-5 text-[13px] hidden md:table-cell">
                      {row.phonedNote ? (
                        <span className="rounded px-2.5 py-0.5 text-[12px] font-medium bg-status-critical-bg text-status-critical border border-status-critical-border inline-block">
                          {row.phonedNote}
                        </span>
                      ) : (
                        <span className="text-status-neutral whitespace-nowrap">{row.phoned}</span>
                      )}
                    </td>
                    <td className="py-3.5 px-5 text-[13px] text-status-neutral whitespace-nowrap hidden md:table-cell">
                      {row.writtenNotice}
                    </td>
                    <td className="py-3.5 px-5 text-[14px]">
                      <span className={`rounded-full px-3 py-1 text-[12px] font-semibold border whitespace-nowrap inline-block ${windowStyle}`}>
                        {row.window}
                      </span>
                    </td>
                    <td className="py-3.5 px-5 text-[13px]">
                      {row.inquiryTone === 'warning' ? (
                        <span className="bg-status-warning-bg text-status-warning-text border border-status-warning-border rounded px-2.5 py-1 font-medium inline-block whitespace-nowrap">
                          {row.inquiry}
                        </span>
                      ) : row.inquiryTone === 'info' ? (
                        <span className="text-status-info font-medium whitespace-nowrap">
                          {row.inquiry}
                        </span>
                      ) : (
                        <span className="text-status-neutral whitespace-nowrap">
                          {row.inquiry}
                        </span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic leading-relaxed">
          {notifications.footnote}
        </div>
      </div>

      {/* BOTTOM TWO-COLUMN SECTION */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">

        {/* LEFT — Causes, this region */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-6 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Causes, this region</h3>
            <span className="text-[13px] text-status-neutral italic">Fatal and serious, 2026</span>
          </div>

          <div className="space-y-4">
            {causes &&
              causes.map((item) => {
                const widthPct = animatedBars ? (item.count / item.maxCount) * 100 : 0;
                return (
                  <div key={item.label} className="flex items-center gap-4">
                    <div className="w-[130px] sm:w-[170px] flex-shrink-0 text-[14px] text-brand-primary text-right leading-tight">
                      {item.label}
                    </div>
                    <div className="flex-1 h-3.5 bg-page-bg rounded-full overflow-hidden">
                      <div
                        className={`h-full rounded-full transition-all duration-700 ease-out ${getBarColorClass(item.color)}`}
                        style={{ width: `${widthPct}%` }}
                      />
                    </div>
                    <div className="w-[24px] flex-shrink-0 text-right text-[14px] font-semibold text-brand-primary">
                      {item.count}
                    </div>
                  </div>
                );
              })}
          </div>

          <p className="mt-5 text-[12px] text-status-neutral leading-relaxed">
            {causesFootnote}
          </p>
        </div>

        {/* RIGHT — Inquiry recommendations */}
        <div className="bg-white border border-page-border rounded-xl overflow-hidden">
          <div className="px-5 pt-5 pb-3 flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">
              {inquiryRecommendations.title}
            </h3>
            <span className="text-[13px] text-status-neutral italic">
              {inquiryRecommendations.subtitle}
            </span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[450px] border-collapse">
              <thead>
                <tr className="bg-transparent border-b border-page-border">
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">FROM</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-center hidden sm:table-cell">MADE</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-center">OPEN</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-right">OLDEST</th>
                </tr>
              </thead>
              <tbody>
                {inquiryRecommendations.items.map((ir) => {
                  let oldestStyle = 'text-status-neutral';
                  if (ir.oldestTone === 'critical') oldestStyle = 'text-status-critical';
                  if (ir.oldestTone === 'warning') oldestStyle = 'text-status-warning';

                  return (
                    <tr key={ir.id} className="border-t border-page-border">
                      <td className="py-3.5 px-5 text-[14px] text-brand-primary">
                        {ir.from}
                      </td>
                      <td className="py-3.5 px-5 text-[14px] text-center text-brand-primary font-medium hidden sm:table-cell">
                        {ir.made}
                      </td>
                      <td className={`py-3.5 px-5 text-[14px] text-center ${ir.open > 0 ? 'text-brand-primary font-semibold' : 'text-status-neutral'}`}>
                        {ir.open}
                      </td>
                      <td className={`py-3.5 px-5 text-[14px] text-right font-bold whitespace-nowrap ${oldestStyle}`}>
                        {ir.oldest}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>

          <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic leading-relaxed">
            {inquiryRecommendations.footnote}
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
