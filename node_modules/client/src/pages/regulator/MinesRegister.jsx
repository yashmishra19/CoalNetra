import React, { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';

export default function MinesRegister() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeFilter, setActiveFilter] = useState('attention');
  const [animatedBars, setAnimatedBars] = useState(false);

  useEffect(() => {
    fetch('/api/regulator/mines-register')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to load mines register data');
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

  const { header, kpis, filterTabs, registerMeta, mines, registerFootnote, composition, compositionFootnote, certificates, certificatesFootnote, pageFootnote } = data;

  return (
    <div className="w-full font-sans">
      {/* PAGE HEADER */}
      <div className="mt-2 flex flex-col md:flex-row md:items-start justify-between gap-4">
        <div>
          <h1 className="text-[26px] font-bold text-brand-primary tracking-tight">
            {header.title}
          </h1>
          <p className="mt-1 text-[14px] text-status-neutral leading-relaxed max-w-[600px]">
            {header.description}
          </p>
        </div>
        <div className="flex items-center gap-3 flex-wrap sm:flex-nowrap">
          <button className="border border-page-border rounded-lg px-4 py-2.5 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer whitespace-nowrap">
            Add an unregistered mine
          </button>
          <button className="bg-brand-primary text-white rounded-lg px-4 py-2.5 text-[13px] font-semibold hover:bg-brand-dark transition cursor-pointer whitespace-nowrap">
            Export register
          </button>
        </div>
      </div>

      {/* KPI ROW */}
      <div className="mt-8 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-4">
        {kpis &&
          kpis.map((kpi) => (
            <div key={kpi.id} className="bg-white border border-page-border rounded-xl p-5 flex flex-col justify-between">
              <div>
                <div className="text-[12px] font-semibold uppercase tracking-wider text-status-neutral flex items-center">
                  {kpi.dot === 'critical' && (
                    <span className="w-2 h-2 rounded-full inline-block mr-1.5 bg-status-critical" />
                  )}
                  {kpi.label}
                </div>
                <div className="mt-2 text-[30px] font-bold text-brand-primary leading-none">
                  {kpi.value}
                </div>
              </div>
            </div>
          ))}
      </div>

      {/* REGISTER TABLE SECTION */}
      <div className="mt-8">
        {/* Header row */}
        <div className="flex items-center justify-between flex-wrap gap-3 mb-4">
          <div className="flex items-center gap-3 flex-wrap">
            <h2 className="text-lg font-semibold text-brand-primary">Register</h2>
            <span className="text-[13px] text-status-neutral italic">
              {registerMeta}
            </span>
          </div>

          {/* Filter Pills */}
          <div className="flex items-center gap-2 flex-wrap">
            {filterTabs &&
              filterTabs.map((tab) => {
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

        {/* Table Container */}
        <div className="bg-white border border-page-border rounded-xl overflow-hidden overflow-x-auto">
          <table className="w-full min-w-[700px] border-collapse">
            <thead>
              <tr className="bg-page-bg border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left">MINE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left hidden lg:table-cell">OPERATOR</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left">DISTRICT</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left">TYPE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left hidden xl:table-cell">GASSINESS</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left">MANAGER</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-right">PERSONS</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-right">LAST SEEN</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">STANDING</th>
              </tr>
            </thead>
            <tbody>
              {mines &&
                mines.map((m) => {
                  let lastSeenStyle = 'text-status-neutral-text';
                  if (m.lastSeenTone === 'critical') lastSeenStyle = 'text-status-critical font-medium';
                  if (m.lastSeenTone === 'warning') lastSeenStyle = 'text-status-warning font-medium';

                  let standingStyle = 'bg-status-good-bg text-status-good border border-status-good-border';
                  if (m.standingTone === 'critical') standingStyle = 'bg-status-critical-bg text-status-critical border border-status-critical-border';
                  if (m.standingTone === 'warning') standingStyle = 'bg-status-warning-bg text-status-warning-text border border-status-warning-border';

                  return (
                    <tr key={m.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors cursor-pointer">
                      <td className="py-3.5 px-4 text-[14px]">
                        <div className="font-semibold text-brand-primary">{m.name}</div>
                        {m.subtitle && (
                          <div className="text-[12px] text-status-neutral mt-0.5">{m.subtitle}</div>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-[14px] text-status-neutral-text hidden lg:table-cell">
                        {m.operator}
                      </td>
                      <td className="py-3.5 px-4 text-[14px] text-status-neutral-text">
                        {m.district}
                      </td>
                      <td className="py-3.5 px-4 text-[14px] text-status-neutral-text">
                        {m.type}
                      </td>
                      <td className={`py-3.5 px-4 text-[14px] hidden xl:table-cell ${m.gassiness === 'Degree II' ? 'text-brand-primary font-medium' : 'text-status-neutral-text'}`}>
                        {m.gassiness}
                      </td>
                      <td className="py-3.5 px-4 text-[14px]">
                        {m.managerNote ? (
                          <span className="rounded px-2.5 py-0.5 text-[12px] font-medium bg-status-critical-bg text-status-critical border border-status-critical-border inline-block">
                            {m.managerNote}
                          </span>
                        ) : (
                          <span className="text-status-neutral-text text-[13px]">{m.manager}</span>
                        )}
                      </td>
                      <td className="py-3.5 px-4 text-[14px] text-brand-primary text-right font-medium">
                        {m.persons}
                      </td>
                      <td className={`py-3.5 px-4 text-[14px] text-right ${lastSeenStyle}`}>
                        {m.lastSeen}
                      </td>
                      <td className="py-3.5 px-4 text-[14px] text-center">
                        <span className={`rounded-full px-3 py-1 text-[12px] font-semibold text-center inline-block whitespace-nowrap ${standingStyle}`}>
                          {m.standing}
                        </span>
                      </td>
                    </tr>
                  );
                })}
            </tbody>
          </table>
        </div>

        {/* Table Footnote */}
        <div className="mt-3 px-1 text-[12px] text-status-neutral leading-relaxed">
          {registerFootnote}
        </div>
      </div>

      {/* BOTTOM TWO-COLUMN SECTION */}
      <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">

        {/* LEFT — Composition of the region */}
        <div className="bg-white border border-page-border rounded-xl p-6">
          <div className="flex items-center gap-3 mb-6 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Composition of the region</h3>
            <span className="text-[13px] text-status-neutral italic">Mines by type and persons employed</span>
          </div>

          <div className="space-y-4">
            {composition &&
              composition.map((item) => {
                const widthPct = animatedBars ? (item.count / item.maxCount) * 100 : 0;
                return (
                  <div key={item.type} className="flex items-center gap-4">
                    <div className="w-[120px] md:w-[160px] flex-shrink-0 text-[14px] text-brand-primary text-right">
                      {item.type}
                    </div>
                    <div className="flex-1 h-4 bg-page-bg rounded-full overflow-hidden">
                      <div
                        className="h-full rounded-full transition-all duration-700 ease-out bg-brand-primary"
                        style={{ width: `${widthPct}%` }}
                      />
                    </div>
                    <div className="flex-shrink-0 w-8 text-[14px] font-semibold text-brand-primary text-right">
                      {item.count}
                    </div>
                  </div>
                );
              })}
          </div>

          <p className="mt-5 text-[12px] text-status-neutral leading-relaxed">
            {compositionFootnote}
          </p>
        </div>

        {/* RIGHT — Certificates and appointments */}
        <div className="bg-white border border-page-border rounded-xl overflow-hidden">
          <div className="px-5 pt-5 pb-3 flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Certificates and appointments</h3>
            <span className="text-[13px] text-status-neutral italic">Statutory posts recorded against mines</span>
          </div>

          <div className="overflow-x-auto">
            <table className="w-full min-w-[450px] border-collapse">
              <thead>
                <tr className="bg-transparent border-b border-page-border">
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">POST</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-center">REQUIRED</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-center hidden sm:table-cell">RECORDED</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-center">GAP</th>
                  <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-2.5 px-5 text-left">STANDING</th>
                </tr>
              </thead>
              <tbody>
                {certificates &&
                  certificates.map((c) => {
                    let standingStyle = 'bg-status-good-bg text-status-good border border-status-good-border';
                    if (c.standingTone === 'critical') standingStyle = 'bg-status-critical text-white';
                    if (c.standingTone === 'warning') standingStyle = 'bg-status-warning-bg text-status-warning-text border border-status-warning-border';

                    return (
                      <tr key={c.id} className="border-t border-page-border">
                        <td className="py-3.5 px-5 text-[14px] text-brand-primary">
                          {c.post}
                        </td>
                        <td className="py-3.5 px-5 text-[14px] text-center text-brand-primary font-medium">
                          {c.required}
                        </td>
                        <td className="py-3.5 px-5 text-[14px] text-center text-brand-primary hidden sm:table-cell">
                          {c.recorded}
                        </td>
                        <td className={`py-3.5 px-5 text-[14px] text-center ${c.gap > 0 ? 'text-status-critical font-bold' : 'text-status-neutral'}`}>
                          {c.gap}
                        </td>
                        <td className="py-3.5 px-5 text-[14px]">
                          <span className={`rounded-full px-3 py-1 text-[12px] font-semibold text-center inline-block whitespace-nowrap ${standingStyle}`}>
                            {c.standing}
                          </span>
                        </td>
                      </tr>
                    );
                  })}
              </tbody>
            </table>
          </div>

          <div className="px-5 py-3 border-t border-page-border text-[12px] text-status-neutral italic">
            {certificatesFootnote}
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
