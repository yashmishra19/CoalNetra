import React, { useState, useEffect } from 'react';
import PageShell from '../components/layout/PageShell';
import {
  Card,
  Button,
  StatCard,
  DailyCoalBarChart,
  LedgerList,
  ThresholdBar,
  ProgressBar,
  StatusDot,
} from '../components/ui';
import {
  getProductionOverview,
} from '../lib/apiProductionEnvironment';
import { Download, PlusCircle } from 'lucide-react';

export default function Production() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getProductionOverview().then((res) => {
      setData(res);
      setLoading(false);
    });
  }, []);

  if (loading || !data) {
    return (
      <PageShell>
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-xs text-gray-500 animate-pulse">
            Loading Production & Environmental Telemetry...
          </div>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell>
      <div className="space-y-4 pb-12">
        {/* Page Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pt-1">
          <div>
            <h1 className="text-lg font-bold text-gray-950 tracking-tight">
              {data.header.title}
            </h1>
            <p className="text-xs text-gray-500 mt-0.5">
              {data.header.subtitle}
            </p>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            <Button variant="secondary" size="sm" className="text-xs font-medium flex items-center gap-1.5">
              <Download className="w-3.5 h-3.5" />
              Download daily report
            </Button>
            <Button
              variant="dark-blue"
              size="sm"
              className="text-xs font-semibold bg-[#1b3252] hover:bg-[#14263f] flex items-center gap-1.5"
            >
              <PlusCircle className="w-3.5 h-3.5" />
              Record stock survey
            </Button>
          </div>
        </div>

        {/* 1. 6 KPI Stat Cards Grid (3x2) */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3">
          {data.kpiStats.map((stat) => (
            <StatCard
              key={stat.id}
              variant="kpi"
              title={stat.title}
              value={stat.value}
              secondaryValue={stat.secondaryValue}
              status={stat.status}
              accentColor={stat.accentColor}
              subtext={stat.subtext}
            />
          ))}
        </div>

        {/* 2. Two-Column Row: Daily Coal Production & Dispatch Reconciliation */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Daily Coal Production Chart */}
          <div className="lg:col-span-7 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-3">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Daily coal production
                  </h3>
                  <span className="text-xs text-gray-400">
                    14-day rolling extraction trend
                  </span>
                </div>

                <DailyCoalBarChart
                  data={data.dailyProduction.chartData}
                  target={data.dailyProduction.target}
                  threshold={data.dailyProduction.threshold}
                />
              </div>

              <div className="mt-3 pt-2 border-t border-gray-100 text-[11px] text-gray-500">
                {data.dailyProduction.note}
              </div>
            </Card>
          </div>

          {/* Right: Dispatch Reconciliation Ledger */}
          <div className="lg:col-span-5 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-3">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Does dispatch match production?
                  </h3>
                  <span className="text-xs text-gray-400">
                    {data.dispatchReconciliation.subtitle}
                  </span>
                </div>

                <LedgerList
                  items={data.dispatchReconciliation.items}
                  differenceBadge={data.dispatchReconciliation.differenceBadge}
                  toleranceNote={data.dispatchReconciliation.toleranceNote}
                  callout={data.dispatchReconciliation.callout}
                />
              </div>
            </Card>
          </div>
        </div>

        {/* 3. Two-Column Row: Air Quality & Water/Noise/Dust Control */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Air Quality Thresholds */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-3">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Air quality
                  </h3>
                  <span className="text-xs text-gray-400">
                    {data.airQuality.subtitle}
                  </span>
                </div>

                <div className="space-y-3.5 py-1">
                  {data.airQuality.stations.map((st, idx) => (
                    <ThresholdBar
                      key={idx}
                      label={st.label}
                      value={st.value}
                      limit={st.limit}
                      unit={st.unit}
                      subtext={st.subtext}
                    />
                  ))}
                </div>
              </div>

              <div className="mt-4 pt-2 border-t border-gray-100 text-[11px] text-gray-500">
                {data.airQuality.note}
              </div>
            </Card>
          </div>

          {/* Right: Water, Noise and Dust Control */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-3">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Water, noise and dust control
                  </h3>
                  <span className="text-xs text-gray-400">
                    {data.waterNoiseDust.subtitle}
                  </span>
                </div>

                {/* Top Threshold Bars */}
                <div className="space-y-3 pb-3 border-b border-gray-100">
                  {data.waterNoiseDust.thresholds.map((th, idx) => (
                    <ThresholdBar
                      key={idx}
                      label={th.label}
                      value={th.value}
                      limit={th.limit}
                      unit={th.unit}
                      max={th.max}
                    />
                  ))}
                </div>

                {/* Metric Rows */}
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5 pt-3">
                  {data.waterNoiseDust.metrics.map((met, idx) => (
                    <div
                      key={idx}
                      className="flex items-center justify-between p-2 rounded bg-gray-50/70 border border-gray-100 text-xs"
                    >
                      <div className="flex items-center gap-1.5 min-w-0">
                        <StatusDot status={met.status} size="sm" />
                        <span className="text-gray-700 font-medium truncate">
                          {met.label}
                        </span>
                      </div>
                      <span className="font-semibold text-gray-900 shrink-0 text-[11px]">
                        {met.value}
                      </span>
                    </div>
                  ))}
                </div>
              </div>
            </Card>
          </div>
        </div>

        {/* 4. Full-Width Card: Environmental Clearance conditions and land reclamation */}
        <Card className="p-4">
          <div className="pb-2 border-b border-gray-100 mb-3">
            <h3 className="text-[13px] font-bold text-gray-900">
              Environmental Clearance conditions and land reclamation
            </h3>
            <span className="text-xs text-gray-400">
              Half-yearly statutory compliance tracking under MoEFCC guidelines
            </span>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 pt-1">
            {data.ecConditionsAndReclamation.cards.map((card, idx) => (
              <div key={idx} className="space-y-1.5">
                <div className="text-xs font-semibold text-gray-600">
                  {card.title}
                </div>
                <div className="text-2xl font-bold text-gray-950 tracking-tight leading-none">
                  {card.value}
                </div>
                <div className="pt-1">
                  <ProgressBar
                    value={card.progress}
                    color={card.color}
                    height="h-2"
                  />
                </div>
                <div className="text-[11px] text-gray-500 pt-0.5 leading-snug">
                  {card.subtext}
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </PageShell>
  );
}
