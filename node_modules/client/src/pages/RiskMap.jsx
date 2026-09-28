import React, { useState, useEffect } from 'react';
import PageShell from '../components/layout/PageShell';
import {
  Card,
  Button,
  FilterPillGroup,
  RankedList,
  DeltaFactorList,
  NoteInput,
  ProgressBar,
} from '../components/ui';
import MineRiskMapGraphic from '../components/shared/MineRiskMapGraphic';
import InsightsWidget from '../components/dashboard/InsightsWidget';
import {
  getRiskMapOverview,
} from '../lib/apiRiskMap';
import { Download, Compass } from 'lucide-react';

export default function RiskMap() {
  const [data, setData] = useState(null);
  const [activeTab, setActiveTab] = useState('risk');
  const [selectedSection, setSelectedSection] = useState('sec-dump3');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getRiskMapOverview().then((res) => {
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
            <Button variant="secondary" size="sm" className="text-xs font-medium flex items-center gap-1.5">
              <Download className="w-3.5 h-3.5" />
              Download map
            </Button>
            <Button
              variant="dark-blue"
              size="sm"
              className="text-xs font-semibold bg-[#1b3252] hover:bg-[#14263f] flex items-center gap-1.5"
            >
              <Compass className="w-3.5 h-3.5" />
              Order an inspection drive
            </Button>
          </div>
        </div>

        {/* 1. Main Top Row: Large Mine Plan Map (Left) & Sections Ranked (Right) */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Large Mine Map */}
          <div className="lg:col-span-8 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-gray-100 mb-3">
                  <div>
                    <h3 className="text-[13px] font-bold text-gray-900">
                      Demo OCP-1 mine plan
                    </h3>
                    <span className="text-xs text-gray-400">
                      Scores updated 16:00
                    </span>
                  </div>

                  <FilterPillGroup
                    options={data.mapViewTabs}
                    activeKey={activeTab}
                    onChange={setActiveTab}
                  />
                </div>

                {/* Extended Large SVG Map */}
                <MineRiskMapGraphic
                  size="large"
                  activeTab={activeTab}
                  selectedSection={selectedSection}
                  onSelectSection={setSelectedSection}
                />
              </div>

              {/* Legend Row */}
              <div className="flex flex-wrap items-center justify-between gap-3 pt-3 mt-2 border-t border-gray-100 text-[11px] text-gray-600">
                <div className="flex items-center gap-1.5">
                  <span className="w-3 h-3 rounded-full bg-red-600" />
                  <span className="font-semibold text-gray-900">Score 70+ (Critical)</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="w-3 h-3 rounded-full bg-amber-500" />
                  <span>Score 40–69 (Warning)</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="w-2.5 h-2.5 rounded-full bg-red-500 animate-pulse border border-white" />
                  <span>Open observation</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="w-4 h-0.5 border-t-2 border-dashed border-red-400" />
                  <span>Lease boundary</span>
                </div>
                <div className="flex items-center gap-1.5">
                  <span className="w-3 h-3 rounded bg-red-100 border border-red-300" />
                  <span>Overburden dump</span>
                </div>
              </div>
            </Card>
          </div>

          {/* Right: Sections Ranked */}
          <div className="lg:col-span-4 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-2">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Sections ranked
                  </h3>
                  <span className="text-xs text-gray-400">
                    Highest risk score first
                  </span>
                </div>

                <RankedList
                  items={data.rankedSections}
                  selectedId={selectedSection}
                  onSelect={(item) => setSelectedSection(item.id)}
                />
              </div>
            </Card>
          </div>
        </div>

        {/* 2. Middle Row: Why Dump-3 Scores 81 (Left) & Risk by Hazard Type (Right) */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Why Dump-3 scores 81 */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-3">
                  <div className="flex items-center justify-between">
                    <h3 className="text-[13px] font-bold text-gray-900">
                      Why {data.dumpScoreBreakdown.sectionName} scores {data.dumpScoreBreakdown.score}
                    </h3>
                    <span className="text-xs font-bold text-red-700 bg-red-50 px-2 py-0.5 rounded border border-red-200">
                      Critical
                    </span>
                  </div>
                  <span className="text-xs text-gray-400">
                    {data.dumpScoreBreakdown.subtitle}
                  </span>
                </div>

                <DeltaFactorList factors={data.dumpScoreBreakdown.factors} />
              </div>

              <NoteInput
                placeholder="Add an operational observation or corrective note for Dump-3..."
                primaryButtonLabel="Save note to audit trail"
                secondaryButtonLabel="Challenge this score"
                onSave={(n) => alert(`Note recorded in immutable audit log: ${n}`)}
                onChallenge={() => alert('Score challenge form opened for Geotech review.')}
              />
            </Card>
          </div>

          {/* Right: Risk by Hazard Type */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="pb-2 border-b border-gray-100 mb-3">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Risk by hazard type
                  </h3>
                  <span className="text-xs text-gray-400">
                    {data.hazardTypeBreakdown.subtitle}
                  </span>
                </div>

                <div className="space-y-3 py-1">
                  {data.hazardTypeBreakdown.items.map((item, idx) => (
                    <div key={idx} className="space-y-1">
                      <div className="flex items-center justify-between text-xs font-semibold">
                        <span className="text-gray-800">{item.label}</span>
                        <span
                          className={`font-mono ${
                            item.color === 'critical'
                              ? 'text-red-700 font-bold'
                              : item.color === 'warning'
                              ? 'text-amber-800 font-bold'
                              : 'text-emerald-700 font-bold'
                          }`}
                        >
                          {item.score}
                        </span>
                      </div>
                      <ProgressBar
                        value={item.score}
                        color={item.color}
                        height="h-2"
                      />
                    </div>
                  ))}
                </div>
              </div>

              <div className="mt-4 pt-2 border-t border-gray-100 text-[11px] text-gray-500">
                {data.hazardTypeBreakdown.note}
              </div>
            </Card>
          </div>
        </div>

        {/* 3. Bottom Row: System Insights (Repeating problems / Likely to be late / Unusual patterns) */}
        <InsightsWidget insights={data.riskInsights} />
      </div>
    </PageShell>
  );
}
