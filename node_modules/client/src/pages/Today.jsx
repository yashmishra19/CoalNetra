import React, { useEffect, useState } from 'react';
import PageShell from '../components/layout/PageShell';
import Button from '../components/ui/Button';
import AlertBanner from '../components/dashboard/AlertBanner';
import StatCardGrid from '../components/dashboard/StatCardGrid';
import DecisionList from '../components/dashboard/DecisionList';
import RiskMapWidget from '../components/dashboard/RiskMapWidget';
import DeadlinesWidget from '../components/dashboard/DeadlinesWidget';
import InspectionsWidget from '../components/dashboard/InspectionsWidget';
import InsightsWidget from '../components/dashboard/InsightsWidget';
import LiveReadingsWidget from '../components/dashboard/LiveReadingsWidget';
import FieldFeedWidget from '../components/dashboard/FieldFeedWidget';
import { getTodayDashboard } from '../lib/apiToday';

export default function Today() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getTodayDashboard().then((res) => {
      setData(res);
      setLoading(false);
    });
  }, []);

  if (loading || !data) {
    return (
      <PageShell>
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-xs text-gray-500 animate-pulse">
            Loading Today's Mine Telemetry...
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
            <Button variant="secondary" size="sm" className="text-xs font-medium">
              Read Shift A handover
            </Button>
            <Button
              variant="dark-blue"
              size="sm"
              className="text-xs font-semibold bg-[#1b3252] hover:bg-[#14263f]"
            >
              Plan an inspection
            </Button>
          </div>
        </div>

        {/* 1. Alert Banner */}
        <AlertBanner
          title={data.alertBanner.title}
          description={data.alertBanner.description}
          totalWindow={data.alertBanner.totalWindow}
          ctaText={data.alertBanner.ctaText}
        />

        {/* 2. KPI Stat Cards (3x2 Grid) */}
        <StatCardGrid stats={data.kpiStats} />

        {/* 3. Main Operational Row: Decisions (Left) & Risk Map (Right) */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          <div className="lg:col-span-7 xl:col-span-8 flex">
            <DecisionList decisions={data.decisions} />
          </div>
          <div className="lg:col-span-5 xl:col-span-4 flex">
            <RiskMapWidget data={data.riskHighest} />
          </div>
        </div>

        {/* 4. Deadlines Section */}
        <DeadlinesWidget deadlines={data.deadlines} />

        {/* 5. Shift Inspections Panel */}
        <InspectionsWidget data={data.inspections} />

        {/* 6. What the system noticed (Insights) */}
        <InsightsWidget insights={data.insights} />

        {/* 7. Live Telemetry Readings */}
        <LiveReadingsWidget readings={data.liveReadings} />

        {/* 8. Latest From The Field */}
        <FieldFeedWidget feed={data.fieldFeed} />

        {/* Footer Disclaimer Note */}
        <div className="pt-2 text-center sm:text-left text-[11px] text-gray-400">
          {data.footerDisclaimer}
        </div>
      </div>
    </PageShell>
  );
}
