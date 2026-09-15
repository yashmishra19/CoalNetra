import React, { useState, useEffect } from 'react';
import PageShell from '../components/layout/PageShell';
import {
  Card,
  Button,
  FilterPillGroup,
  DataTable,
  StatusBadge,
  StepPipeline,
  DetailPanel,
  BeforeAfterPhotos,
  Timeline,
  HeatmapGrid,
} from '../components/ui';
import {
  getCapaOverview,
  getOpenCapas,
} from '../lib/apiInspectionsCapa';
import { Upload, Plus } from 'lucide-react';

export default function InspectionsCapa() {
  const [data, setData] = useState(null);
  const [activeFilter, setActiveFilter] = useState('all');
  const [capaList, setCapaList] = useState([]);
  const [selectedCapaId, setSelectedCapaId] = useState('CAPA-231');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getCapaOverview().then((res) => {
      setData(res);
      setCapaList(res.capaList);
      setLoading(false);
    });
  }, []);

  const handleFilterChange = (key) => {
    setActiveFilter(key);
    getOpenCapas(key).then(setCapaList);
  };

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

  // Open CAPAs Table Columns
  const capaColumns = [
    {
      key: 'id',
      label: 'CAPA #',
      render: (row) => (
        <span className="font-bold text-gray-950 font-mono text-xs">
          {row.id}
        </span>
      ),
    },
    {
      key: 'title',
      label: 'Observation',
      render: (row) => (
        <div>
          <div className="font-semibold text-gray-900 leading-snug">{row.title}</div>
          <div className="text-[11px] text-gray-500 mt-0.5">{row.location}</div>
        </div>
      ),
    },
    {
      key: 'severity',
      label: 'Severity',
      render: (row) => <StatusBadge status={row.severity} />,
    },
    {
      key: 'ownerName',
      label: 'Owner',
      render: (row) => (
        <div>
          <div className="font-medium text-gray-900">{row.ownerName}</div>
          <div className="text-[10px] text-gray-400">{row.ownerRole}</div>
        </div>
      ),
    },
    {
      key: 'due',
      label: 'Due',
      render: (row) => (
        <div>
          <div className="font-medium text-gray-900">{row.due}</div>
          <div className="text-[10px] text-gray-400">{row.dueLevel}</div>
        </div>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      align: 'right',
      render: (row) => <StatusBadge status={row.status} />,
    },
  ];

  // Inspection Plan Columns
  const planColumns = [
    {
      key: 'time',
      label: 'Time',
      render: (row) => <span className="font-mono font-bold text-gray-900">{row.time}</span>,
    },
    {
      key: 'section',
      label: 'Section',
      render: (row) => <span className="font-semibold text-gray-900">{row.section}</span>,
    },
    {
      key: 'type',
      label: 'Type',
      render: (row) => <span className="text-gray-600">{row.type}</span>,
    },
    {
      key: 'inspector',
      label: 'Inspector',
      render: (row) => <span className="text-gray-800 font-medium">{row.inspector}</span>,
    },
    {
      key: 'status',
      label: 'Status',
      align: 'right',
      render: (row) => <StatusBadge status={row.status} />,
    },
  ];

  const detail = data?.selectedCapaDetail || {};

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
              <Upload className="w-3.5 h-3.5" />
              Import inspection report (PDF)
            </Button>
            <Button
              variant="dark-blue"
              size="sm"
              className="text-xs font-semibold bg-[#1b3252] hover:bg-[#14263f] flex items-center gap-1.5"
            >
              <Plus className="w-3.5 h-3.5" />
              Create CAPA
            </Button>
          </div>
        </div>

        {/* 1. Step Pipeline (Reported -> Assigned -> Work done -> Verified) */}
        <StepPipeline steps={data.pipelineSteps} />

        {/* 2. Main Two-Column Row: Open CAPAs List (Left) & Detail Panel (Right) */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Open CAPAs Table */}
          <div className="lg:col-span-7 xl:col-span-7 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div className="space-y-3">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-gray-100">
                  <div>
                    <h3 className="text-[13px] font-bold text-gray-900">
                      Open CAPAs
                    </h3>
                    <span className="text-xs text-gray-400">
                      Showing {capaList.length} items
                    </span>
                  </div>

                  <FilterPillGroup
                    options={data.capaFilters}
                    activeKey={activeFilter}
                    onChange={handleFilterChange}
                  />
                </div>

                <DataTable
                  columns={capaColumns}
                  data={capaList}
                  keyField="id"
                  selectedId={selectedCapaId}
                  onRowClick={(row) => setSelectedCapaId(row.id)}
                />
              </div>
            </Card>
          </div>

          {/* Right: CAPA Detail Panel */}
          <div className="lg:col-span-5 xl:col-span-5 flex">
            <DetailPanel
              title={detail.title}
              subtitle={detail.subtitle}
              badge={detail.severity}
              description={detail.description}
              callout={detail.callout}
              footerNote={detail.footerNote}
              footerBadge={detail.footerBadge}
              actions={[
                { label: 'Verify closure', variant: 'dark-blue' },
                { label: 'Reopen with reason', variant: 'secondary' },
              ]}
              className="w-full"
            >
              {/* Before/After Photos */}
              <BeforeAfterPhotos
                before={detail.beforeAfter.before}
                after={detail.beforeAfter.after}
              />

              {/* Event Timeline */}
              <div className="pt-2">
                <div className="text-[11px] font-bold text-gray-700 uppercase tracking-wider mb-2">
                  History
                </div>
                <Timeline events={detail.history} />
              </div>
            </DetailPanel>
          </div>
        </div>

        {/* 3. Bottom Row: Today's Inspection Plan & 7-Day Heatmap Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Inspection Plan */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                  <div>
                    <h3 className="text-[13px] font-bold text-gray-900">
                      Inspection plan for today
                    </h3>
                    <span className="text-xs text-gray-400">
                      18 sections scheduled for Shift B
                    </span>
                  </div>
                </div>

                <DataTable
                  columns={planColumns}
                  data={data.todayInspectionPlan}
                  keyField="section"
                />
              </div>
            </Card>
          </div>

          {/* Right: Shifts Inspected Heatmap */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                  <div>
                    <h3 className="text-[13px] font-bold text-gray-900">
                      Shifts inspected, last 7 days
                    </h3>
                    <span className="text-xs text-gray-400">
                      Target: 3 shifts/day per active mining section
                    </span>
                  </div>
                </div>

                <div className="pt-2">
                  <HeatmapGrid
                    days={data.shiftsInspectedHeatmap.days}
                    rows={data.shiftsInspectedHeatmap.rows}
                  />
                </div>
              </div>

              <div className="mt-3 pt-2 border-t border-gray-100 text-[11px] text-gray-500">
                {data.shiftsInspectedHeatmap.note}
              </div>
            </Card>
          </div>
        </div>
      </div>
    </PageShell>
  );
}
