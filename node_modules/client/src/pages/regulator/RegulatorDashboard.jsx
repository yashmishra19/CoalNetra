import React, { useEffect, useState } from 'react';
import { AlertTriangle, Loader2, ArrowUp } from 'lucide-react';

export default function RegulatorDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [activeTab, setActiveTab] = useState('directions');
  const [activeDirectionFilter, setActiveDirectionFilter] = useState('overdue');

  useEffect(() => {
    fetch('/api/regulator')
      .then((res) => {
        if (!res.ok) throw new Error('Failed to fetch regulator data');
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
        <span className="text-[14px]">Loading regulator dashboard...</span>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="py-12 text-center text-status-critical text-[14px]">
        {error || 'Unable to load dashboard data.'}
      </div>
    );
  }

  const { alert, kpis, operators, inspectorPriorities, dataReliability, directions, notices, districts, footnote } = data;

  const getInspectedColor = (inspectedStr) => {
    const val = parseInt(inspectedStr.replace('%', ''), 10);
    if (isNaN(val)) return 'text-brand-primary';
    if (val >= 60) return 'text-status-good-dark font-semibold';
    if (val >= 40) return 'text-status-warning-dark font-semibold';
    return 'text-status-critical font-semibold';
  };

  const getReturnsPill = (returnsTone, returnsText) => {
    let colorClasses = 'text-brand-primary bg-page-bg border-page-border';
    if (returnsTone === 'good') colorClasses = 'text-status-good bg-status-good-bg border-status-good-border';
    if (returnsTone === 'critical') colorClasses = 'text-status-critical bg-status-critical-bg border-status-critical-border';
    if (returnsTone === 'warning') colorClasses = 'text-status-warning bg-status-warning-bg border-status-warning-border';
    return (
      <span className={`inline-block px-2.5 py-0.5 rounded-full text-[12px] font-medium border ${colorClasses}`}>
        {returnsText}
      </span>
    );
  };

  const getRankColor = (rank) => {
    if (rank <= 2) return 'bg-status-critical text-white';
    if (rank <= 4) return 'bg-status-warning text-white';
    return 'bg-status-neutral text-white';
  };

  const getScoreColor = (score) => {
    if (score >= 85) return 'text-status-critical';
    if (score >= 75) return 'text-status-warning';
    return 'text-status-neutral';
  };

  const getEvidenceToneColor = (tone) => {
    if (tone === 'good') return { dot: 'bg-status-good', text: 'text-status-good' };
    if (tone === 'warning') return { dot: 'bg-status-warning', text: 'text-status-warning' };
    if (tone === 'critical') return { dot: 'bg-status-critical', text: 'text-status-critical' };
    return { dot: 'bg-status-neutral', text: 'text-status-neutral' };
  };

  const getNextStepStyle = (nextStep) => {
    if (nextStep === 'Consider prohibition') return 'bg-brand-primary text-white border-transparent hover:bg-brand-dark font-semibold';
    if (nextStep === 'Verify on site') return 'bg-status-info text-white border-transparent hover:bg-status-info-dark font-semibold';
    return 'border-page-border text-status-neutral-text hover:bg-page-bg font-medium';
  };

  const getCoverageBg = (coverageStr) => {
    const val = parseInt(coverageStr.replace('%', ''), 10);
    if (isNaN(val)) return 'bg-[#E8D5B5] border-[#D8C4A5]';
    if (val >= 60) return 'bg-[#F0E6D2] border-[#E0D0B5]';
    if (val >= 30) return 'bg-[#E8D5B5] border-[#D8C4A5]';
    return 'bg-[#D4BC96] border-[#C4AA80]';
  };

  // District bubble positions for the stylized geographic layout
  const districtPositions = {
    Chandrapur: 'top-[8%] right-[8%]',
    Yavatmal: 'top-[15%] left-[25%]',
    Nanded: 'top-[50%] right-[8%]',
    Beed: 'top-[40%] left-[35%]',
    Latur: 'bottom-[18%] left-[25%]',
    Osmanabad: 'bottom-[22%] left-[5%]',
  };

  return (
    <div className="w-full">
      {/* ALERT BANNER */}
      {alert && (
        <div className="mt-6 bg-[#FFF8F0] border border-[#F0C6A0] rounded-xl px-6 py-4 flex flex-col md:flex-row items-start md:items-center gap-5">
          {/* Icon */}
          <div className="w-10 h-10 rounded-full bg-status-critical/10 flex items-center justify-center flex-shrink-0">
            <AlertTriangle size={20} className="text-status-critical" />
          </div>

          {/* Middle text */}
          <div className="flex-1 min-w-0">
            <h3 className="text-[15px] font-semibold text-brand-primary">
              {alert.title}
            </h3>
            <p className="mt-1 text-[14px] text-status-neutral-text leading-relaxed">
              {alert.body}
            </p>
          </div>

          {/* Right action & time block */}
          <div className="flex-shrink-0 flex items-center gap-5 flex-wrap sm:flex-nowrap w-full md:w-auto justify-between md:justify-end mt-2 md:mt-0">
            <div className="text-left md:text-right">
              <div className="text-[28px] font-bold text-brand-primary leading-none">
                {alert.responseTime}
              </div>
              <div className="text-[12px] text-status-neutral mt-0.5">
                {alert.responseLabel}
              </div>
            </div>
            <button className="bg-brand-primary text-white rounded-lg px-4 py-2.5 text-[13px] font-semibold hover:bg-brand-dark transition cursor-pointer">
              {alert.cta}
            </button>
          </div>
        </div>
      )}

      {/* KPI ROW */}
      <div className="mt-6 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
        {kpis &&
          kpis.map((kpi) => {
            const isCritical = kpi.tone === 'critical';
            return (
              <div key={kpi.id} className="bg-white border border-page-border rounded-xl p-4 flex flex-col justify-between">
                <div>
                  <div className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral">
                    {kpi.label}
                  </div>
                  <div className="mt-2 flex items-baseline gap-1.5">
                    <span className={`text-[30px] font-bold leading-none ${isCritical ? 'text-status-critical' : 'text-brand-primary'}`}>
                      {kpi.value}
                    </span>
                    {kpi.suffix && (
                      <span className={`text-[14px] font-medium ${isCritical ? 'text-status-critical' : 'text-status-neutral'}`}>
                        {kpi.suffix}
                      </span>
                    )}
                  </div>
                </div>
                <div className="mt-2 text-[12px] text-status-neutral leading-snug">
                  {kpi.detail}
                </div>
              </div>
            );
          })}
      </div>

      {/* OPERATORS TABLE */}
      <div className="mt-8">
        {/* Header row */}
        <div className="flex items-center justify-between mb-4 flex-wrap gap-3">
          <div className="flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">
              Operators in this jurisdiction
            </h3>
            <span className="text-[13px] text-status-neutral italic">
              The comparison only this office can make
            </span>
          </div>

          {/* Tab buttons */}
          <div className="flex items-center gap-2 flex-wrap">
            {[
              { id: 'directions', label: 'Open directions' },
              { id: 'coverage', label: 'Inspection coverage' },
              { id: 'accidents', label: 'Accidents' },
            ].map((tab) => {
              const isActive = activeTab === tab.id;
              return (
                <button
                  key={tab.id}
                  onClick={() => setActiveTab(tab.id)}
                  className={`rounded-full px-4 py-1.5 text-[13px] font-medium border transition cursor-pointer ${
                    isActive
                      ? 'bg-status-info text-white border-status-info'
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
          <table className="w-full min-w-[750px] border-collapse">
            <thead>
              <tr className="bg-page-bg border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left">OPERATOR</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-left">TYPE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">MINES</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">INSPECTED</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">FATAL</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">SERIOUS</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">DIR. OPEN</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-center">OVERDUE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-4 text-right">RETURNS</th>
              </tr>
            </thead>
            <tbody>
              {operators &&
                operators.map((op) => (
                  <tr key={op.id} className="border-t border-page-border hover:bg-page-bg/50 transition-colors cursor-pointer">
                    <td className="py-4 px-4 text-[14px]">
                      <div className="font-medium text-brand-primary">{op.name}</div>
                      <div className="text-[12px] text-status-neutral">{op.subtitle}</div>
                    </td>
                    <td className="py-4 px-4 text-[14px] text-status-neutral">
                      {op.type}
                    </td>
                    <td className="py-4 px-4 text-[14px] text-brand-primary text-center">
                      {op.mines}
                    </td>
                    <td className={`py-4 px-4 text-[14px] text-center ${getInspectedColor(op.inspected)}`}>
                      {op.inspected}
                    </td>
                    <td className={`py-4 px-4 text-[14px] text-center ${op.fatal > 0 ? 'text-status-critical font-semibold' : 'text-status-neutral'}`}>
                      {op.fatal}
                    </td>
                    <td className="py-4 px-4 text-[14px] text-brand-primary text-center">
                      {op.serious}
                    </td>
                    <td className="py-4 px-4 text-[14px] text-brand-primary text-center">
                      {op.dirOpen}
                    </td>
                    <td className={`py-4 px-4 text-[14px] text-center ${op.overdue > 2 ? 'text-status-critical font-semibold' : 'text-brand-primary'}`}>
                      {op.overdue}
                    </td>
                    <td className="py-4 px-4 text-[13px] text-right">
                      {getReturnsPill(op.returnsTone, op.returns)}
                    </td>
                  </tr>
                ))}
            </tbody>
          </table>
        </div>

        {/* Footnote below table */}
        <div className="mt-2 text-[12px] text-status-neutral/70 italic">
          The PSU is inspected most and reports most. The 72 small quarries hold 61% of the mines in this region and receive 18% coverage. Absence of accident reports from them is not evidence of safety.
        </div>
      </div>

      {/* ============================================================ */}
      {/* SECTION 1: Inspector Priorities + Data Reliability            */}
      {/* ============================================================ */}
      <div className="mt-10 grid grid-cols-1 lg:grid-cols-[1fr_1fr] gap-6 items-start">

        {/* LEFT — Where to send inspectors */}
        <div className="bg-white border border-page-border rounded-xl p-5">
          <div className="flex items-center gap-3 mb-5 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Where to send inspectors</h3>
            <span className="text-[13px] text-status-neutral">October, 4 officers, 20 working days</span>
          </div>

          {inspectorPriorities && inspectorPriorities.map((item, idx) => (
            <div
              key={item.rank}
              className={`py-4 ${idx < inspectorPriorities.length - 1 ? 'border-b border-page-border' : ''}`}
            >
              <div className="flex items-start gap-4">
                {/* Rank circle */}
                <div className={`w-8 h-8 rounded-lg flex items-center justify-center text-[14px] font-bold flex-shrink-0 ${getRankColor(item.rank)}`}>
                  {item.rank}
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-2">
                    <span className="text-[15px] font-medium text-brand-primary">{item.name}</span>
                    <span className={`text-[15px] font-bold flex-shrink-0 ${getScoreColor(item.score)}`}>
                      Score {item.score}
                    </span>
                  </div>
                  <div className="mt-0.5 text-[13px] text-status-neutral">{item.subtitle}</div>
                  <div className="mt-1.5 text-[13px] text-status-neutral-text leading-relaxed">{item.note}</div>
                </div>
              </div>
            </div>
          ))}

          {/* Footer */}
          <div className="mt-4 pt-4 border-t border-page-border">
            <p className="text-[12px] text-status-neutral italic leading-relaxed">
              Ranked by risk, interval since last visit and travel clustering. 19 mines are past interval; this plan clears 17 of them.
            </p>
          </div>
        </div>

        {/* RIGHT — Data Reliability */}
        <div className="bg-white border border-page-border rounded-xl p-5">
          <div className="flex items-center gap-2 mb-4 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Can these figures be relied on?</h3>
            <span className="text-[13px] text-status-neutral italic">How every number on this page was established</span>
          </div>

          {/* Stacked Bar */}
          {dataReliability && (
            <>
              <div className="mt-4 h-7 rounded-full overflow-hidden flex w-full">
                {dataReliability.segments.map((segment, idx) => (
                  <div
                    key={segment.label}
                    className="h-full transition-all duration-500"
                    style={{ width: `${segment.value}%`, backgroundColor: segment.color }}
                  />
                ))}
              </div>

              {/* Legend */}
              <div className="mt-4 flex flex-wrap gap-x-5 gap-y-2">
                {dataReliability.segments.map((segment) => (
                  <div key={segment.label} className="flex items-center gap-2 text-[13px]">
                    <span
                      className="w-3 h-3 rounded-sm flex-shrink-0"
                      style={{ backgroundColor: segment.color }}
                    />
                    <span className="text-status-neutral-text">{segment.value}% {segment.label}</span>
                  </div>
                ))}
              </div>

              {/* Explanation */}
              <p className="mt-5 text-[14px] text-status-neutral-text leading-relaxed">
                {dataReliability.explanation}
              </p>

              {/* CTA */}
              <button className="mt-4 border border-page-border rounded-lg px-4 py-2 text-[13px] font-medium text-brand-primary hover:bg-page-bg transition cursor-pointer inline-block">
                {dataReliability.cta}
              </button>
            </>
          )}
        </div>
      </div>

      {/* ============================================================ */}
      {/* SECTION 2: Directions awaiting compliance                    */}
      {/* ============================================================ */}
      <div className="mt-10 bg-white border border-page-border rounded-xl overflow-hidden">
        {/* Header */}
        <div className="px-5 pt-5 pb-4 flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Directions awaiting compliance</h3>
            <span className="text-[13px] text-status-neutral italic">Issued by this office, oldest first</span>
          </div>
          <div className="flex items-center gap-2 flex-wrap">
            {[
              { id: 'overdue', label: 'Overdue (19)' },
              { id: 'allOpen', label: 'All open (63)' },
              { id: 'coal', label: 'Coal (41)' },
              { id: 'other', label: 'Other (22)' },
            ].map((filter) => {
              const isActive = activeDirectionFilter === filter.id;
              return (
                <button
                  key={filter.id}
                  onClick={() => setActiveDirectionFilter(filter.id)}
                  className={`rounded-full px-4 py-1.5 text-[13px] font-medium border transition cursor-pointer ${
                    isActive
                      ? 'bg-brand-primary text-white border-brand-primary'
                      : 'border-page-border text-status-neutral-text hover:bg-page-bg'
                  }`}
                >
                  {filter.label}
                </button>
              );
            })}
          </div>
        </div>

        {/* Table */}
        <div className="overflow-x-auto">
          <table className="w-full min-w-[900px] border-collapse">
            <thead>
              <tr className="border-b border-page-border">
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">DIRECTION</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">MINE AND OPERATOR</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">ISSUED</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">OVERDUE</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">EVIDENCE RECEIVED</th>
                <th className="text-[11px] font-semibold uppercase tracking-wider text-status-neutral py-3 px-5 text-left">NEXT STEP</th>
              </tr>
            </thead>
            <tbody>
              {directions && directions.map((dir, idx) => {
                const evidenceStyle = getEvidenceToneColor(dir.evidenceTone);
                return (
                  <tr
                    key={dir.id}
                    className={`${idx < directions.length - 1 ? 'border-b border-page-border' : ''} hover:bg-page-bg/50 transition-colors`}
                  >
                    <td className="py-4 px-5 text-[14px] max-w-[300px]">
                      <div className="text-brand-primary leading-snug">{dir.direction}</div>
                      {dir.subtitle && (
                        <div className="text-[13px] text-status-neutral italic mt-0.5">{dir.subtitle}</div>
                      )}
                    </td>
                    <td className="py-4 px-5 text-[14px]">
                      <div className="text-brand-primary">{dir.mineOperator}</div>
                      {dir.mineLocation && (
                        <div className="text-[12px] text-status-neutral mt-0.5">{dir.mineLocation}</div>
                      )}
                    </td>
                    <td className="py-4 px-5 text-[14px] text-status-neutral">
                      {dir.issued}
                    </td>
                    <td className={`py-4 px-5 text-[14px] font-semibold ${dir.overdueTone === 'warning' ? 'text-status-warning' : 'text-status-critical'}`}>
                      {dir.overdue}
                    </td>
                    <td className="py-4 px-5 text-[14px]">
                      <div className="flex items-center gap-2">
                        <span className={`w-2 h-2 rounded-full flex-shrink-0 ${evidenceStyle.dot}`} />
                        <span className={`text-[13px] ${evidenceStyle.text}`}>{dir.evidence}</span>
                      </div>
                    </td>
                    <td className="py-4 px-5 text-[14px]">
                      <button
                        className={`rounded-lg px-3 py-1.5 text-[12px] border transition cursor-pointer whitespace-nowrap ${getNextStepStyle(dir.nextStep)}`}
                        onClick={() => {}}
                      >
                        {dir.nextStep}
                      </button>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Footer */}
        <div className="px-5 py-3 border-t border-page-border">
          <p className="text-[12px] text-status-neutral italic">
            Three directions have passed the point where this office would normally move to a prohibition order. Two of them concern the same defect at the same operator.
          </p>
        </div>
      </div>

      {/* ============================================================ */}
      {/* SECTION 3: Notices received + District map                   */}
      {/* ============================================================ */}
      <div className="mt-10 grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">

        {/* LEFT — Notices received */}
        <div className="bg-white border border-page-border rounded-xl p-5">
          <div className="flex items-center gap-2 mb-4 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Notices received</h3>
            <span className="text-[13px] text-status-neutral italic">Against the statutory window</span>
          </div>

          {notices && notices.map((notice, idx) => (
            <div
              key={notice.id}
              className={`py-4 ${idx < notices.length - 1 ? 'border-b border-page-border' : ''}`}
            >
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 sm:gap-4">
                {/* Left info */}
                <div className="flex-1 min-w-0">
                  <div className="text-[15px] font-semibold text-brand-primary">{notice.title}</div>
                  <div className="mt-0.5 text-[13px] text-status-neutral">{notice.source}</div>
                </div>

                {/* Right: time + badge */}
                <div className="flex items-center gap-3 flex-shrink-0">
                  <div className="text-right">
                    <div className="text-[15px] font-bold text-brand-primary">{notice.responseTime}</div>
                    <div className="text-[12px] text-status-neutral">{notice.responseOf}</div>
                  </div>
                  <span
                    className={`rounded px-2.5 py-1 text-[11px] font-bold uppercase tracking-wider ${
                      notice.status === 'inTime'
                        ? 'bg-status-good-bg text-status-good border border-status-good-border'
                        : 'bg-status-critical-bg text-status-critical border border-status-critical-border'
                    }`}
                  >
                    {notice.status === 'inTime' ? 'In time' : 'Late'}
                  </span>
                </div>
              </div>
            </div>
          ))}

          {/* Footer */}
          <div className="mt-4 pt-4 border-t border-page-border">
            <p className="text-[12px] text-status-neutral italic">
              Late notification is itself a contravention and is recorded against the operator.
            </p>
          </div>
        </div>

        {/* RIGHT — Six districts */}
        <div className="bg-white border border-page-border rounded-xl p-5">
          <div className="flex items-center gap-2 mb-4 flex-wrap">
            <h3 className="text-lg font-semibold text-brand-primary">Six districts</h3>
            <span className="text-[13px] text-status-neutral italic cursor-pointer">Click to filter</span>
          </div>

          {/* District map — desktop: positioned bubbles, mobile: grid fallback */}
          {/* Desktop positioned layout */}
          <div className="hidden md:block relative h-[320px]">
            {districts && districts.map((district) => {
              const pos = districtPositions[district.name] || 'top-[50%] left-[50%]';
              return (
                <button
                  key={district.name}
                  className={`absolute ${pos} ${getCoverageBg(district.coverage)} rounded-xl px-4 py-3 cursor-pointer hover:shadow-md transition-all active:scale-95 text-left border`}
                  onClick={() => {}}
                >
                  <div className="text-[13px] font-semibold text-brand-primary whitespace-nowrap">{district.name}</div>
                  <div className="text-[11px] text-status-neutral-text whitespace-nowrap">{district.mines} mines · {district.coverage}</div>
                </button>
              );
            })}

            {/* Compass */}
            <div className="absolute bottom-2 right-2 flex flex-col items-center">
              <ArrowUp size={10} className="text-status-neutral" />
              <span className="text-[11px] font-semibold text-status-neutral">N</span>
            </div>
          </div>

          {/* Mobile grid layout */}
          <div className="md:hidden grid grid-cols-2 gap-3">
            {districts && districts.map((district) => (
              <button
                key={district.name}
                className={`${getCoverageBg(district.coverage)} rounded-xl px-4 py-3 cursor-pointer hover:shadow-md transition-all active:scale-95 text-left border`}
                onClick={() => {}}
              >
                <div className="text-[13px] font-semibold text-brand-primary">{district.name}</div>
                <div className="text-[11px] text-status-neutral-text">{district.mines} mines · {district.coverage}</div>
              </button>
            ))}
          </div>

          {/* Footer / Legend */}
          <div className="mt-3 flex items-center gap-6 text-[12px] text-status-neutral flex-wrap">
            <div className="flex items-center gap-2">
              <span>Shading is inspection coverage, darker is worse</span>
              <span className="w-16 h-2 rounded-full bg-gradient-to-r from-[#F0E6D2] to-[#D4BC96] flex-shrink-0 border border-[#D8C4A5]" />
            </div>
            <span>Coal is concentrated in Chandrapur and Yavatmal</span>
          </div>
        </div>
      </div>

      {/* ============================================================ */}
      {/* SECTION 4: Page footer                                       */}
      {/* ============================================================ */}
      <div className="mt-10 mb-4 text-center">
        <p className="text-[12px] text-status-neutral/60 italic">
          {footnote}
        </p>
      </div>
    </div>
  );
}
