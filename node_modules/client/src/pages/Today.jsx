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

  if (!data) {
    return (
      <PageShell>
        <div className="flex items-center justify-center min-h-[60vh]">
          <div className="text-center">
            <div className="w-8 h-8 border-2 border-page-border border-t-brand-primary rounded-full animate-spin mx-auto mb-3"></div>
            <p className="text-sm text-status-neutral">Loading...</p>
          </div>
        </div>
      </PageShell>
    );
  }

  return (
    <PageShell>
      <div className="space-y-8 pb-12">
        {/* Page Header */}
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pt-1">
          <div>
            <h1 className="text-[26px] font-bold text-brand-primary tracking-tight">
              {data.header.title}
            </h1>
            <p className="text-[14px] text-status-neutral mt-1">
              {data.header.subtitle}
            </p>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <Button variant="secondary" className="text-[13px] font-medium">
              Read Shift A handover
            </Button>
            <Button
              variant="primary"
              className="text-[13px] font-semibold"
            >
              Plan an inspection
            </Button>
          </div>
        </div>

        {/* 1. Alert Banner */}
        {data.alertBanner && (
          <AlertBanner
            title={data.alertBanner.title}
            description={data.alertBanner.description}
            totalWindow={data.alertBanner.totalWindow}
            ctaText={data.alertBanner.ctaText}
          />
        )}

        {/* 2. KPI Stat Cards (3x2 Grid) */}
        <StatCardGrid stats={data.kpiStats} />

        {/* 3. Main Operational Row: Decisions (Left) & Risk Map (Right) */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-stretch">
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
        <div className="pt-2 text-center sm:text-left text-[12px] text-status-neutral italic">
          {data.footerDisclaimer}
        </div>
      </div>
    </PageShell>
  );
}
