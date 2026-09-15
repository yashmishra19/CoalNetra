import React, { useState, useEffect } from 'react';
import PageShell from '../components/layout/PageShell';
import {
  Card,
  Button,
  StatCard,
  FilterPillGroup,
  DataTable,
  StatusBadge,
  MiniProgressBar,
  CalendarMonth,
} from '../components/ui';
import {
  getComplianceOverview,
  getObligations,
} from '../lib/apiCompliance';
import { Upload, Plus, FileText } from 'lucide-react';

export default function Compliance() {
  const [data, setData] = useState(null);
  const [activeFilter, setActiveFilter] = useState('all');
  const [obligations, setObligations] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getComplianceOverview().then((res) => {
      setData(res);
      setObligations(res.obligations);
      setLoading(false);
    });
  }, []);

  const handleFilterChange = (key) => {
    setActiveFilter(key);
    getObligations(key).then(setObligations);
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

  // Column definitions for Obligation Register
  const obligationColumns = [
    {
      key: 'title',
      label: 'Obligation',
      render: (row) => (
        <div>
          <div className="font-semibold text-gray-950">{row.title}</div>
          <div className="text-[11px] text-gray-500 mt-0.5">{row.location}</div>
        </div>
      ),
    },
    {
      key: 'legalRef',
      label: 'Legal Reference',
      render: (row) => (
        <div>
          <div className="font-medium text-gray-900">{row.legalRef}</div>
          <div className="text-[10px] text-gray-400">{row.legalAct}</div>
        </div>
      ),
    },
    {
      key: 'frequency',
      label: 'How often',
      render: (row) => <span className="text-gray-700">{row.frequency}</span>,
    },
    {
      key: 'owner',
      label: 'Owner',
      render: (row) => <span className="text-gray-800 font-medium">{row.owner}</span>,
    },
    {
      key: 'due',
      label: 'Due',
      render: (row) => <span className="font-medium text-gray-900">{row.due}</span>,
    },
    {
      key: 'status',
      label: 'Status',
      align: 'right',
      render: (row) => <StatusBadge status={row.status} />,
    },
  ];

  // Column definitions for Regulator Directions
  const directionColumns = [
    {
      key: 'direction',
      label: 'Direction',
      render: (row) => (
        <div className="font-semibold text-gray-900 max-w-sm leading-snug">
          {row.direction}
        </div>
      ),
    },
    {
      key: 'issuedBy',
      label: 'Issued by',
      render: (row) => <span className="text-gray-700">{row.issuedBy}</span>,
    },
    {
      key: 'issuedDate',
      label: 'Issued date',
      render: (row) => <span className="text-gray-500 font-mono text-[11px]">{row.issuedDate}</span>,
    },
    {
      key: 'dueDate',
      label: 'Due date',
      render: (row) => <span className="text-gray-900 font-medium text-[11px]">{row.dueDate}</span>,
    },
    {
      key: 'progress',
      label: 'Progress',
      render: (row) => (
        <MiniProgressBar
          value={row.progress}
          color={row.progressColor}
          showText
          width="w-20"
        />
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (row) => <StatusBadge status={row.status} />,
    },
    {
      key: 'action',
      label: '',
      align: 'right',
      render: () => (
        <Button variant="secondary" size="xs" className="text-[11px]">
          Add evidence
        </Button>
      ),
    },
  ];

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
              Upload clearance or licence letter
            </Button>
            <Button
              variant="dark-blue"
              size="sm"
              className="text-xs font-semibold bg-[#1b3252] hover:bg-[#14263f] flex items-center gap-1.5"
            >
              <Plus className="w-3.5 h-3.5" />
              Add obligation
            </Button>
          </div>
        </div>

        {/* 1. Stat Cards Row (5 Simple Cards) */}
        <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3">
          {data.statCards.map((stat) => (
            <StatCard
              key={stat.id}
              variant="simple"
              title={stat.title}
              value={stat.value}
              secondaryValue={stat.secondaryValue}
              status={stat.status}
              progress={stat.progress}
              subtext={stat.subtext}
            />
          ))}
        </div>

        {/* 2. Obligation Register Card */}
        <Card className="p-4 space-y-3">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-gray-100">
            <div>
              <h3 className="text-[13px] font-bold text-gray-900">
                Obligation register
              </h3>
              <span className="text-xs text-gray-400">
                Showing {obligations.length} of 142 obligations
              </span>
            </div>

            <FilterPillGroup
              options={data.obligationFilters}
              activeKey={activeFilter}
              onChange={handleFilterChange}
            />
          </div>

          <DataTable
            columns={obligationColumns}
            data={obligations}
            keyField="id"
          />
        </Card>

        {/* 3. Two-Column Row: Calendar & Licences */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Calendar Month */}
          <div className="lg:col-span-6 flex">
            <CalendarMonth className="w-full" month="September 2026" />
          </div>

          {/* Licences and Clearances List */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                <h3 className="text-[13px] font-bold text-gray-900">
                  Licences and clearances
                </h3>
                <span className="text-xs text-gray-400">6 statutory clearances</span>
              </div>

              <div className="divide-y divide-gray-100 py-1 flex-1">
                {data.licences.map((lic, idx) => (
                  <div key={idx} className="py-2.5 flex items-center justify-between gap-3 text-xs">
                    <div className="min-w-0 flex-1">
                      <div className="font-semibold text-gray-900 leading-snug truncate">
                        {lic.name}
                      </div>
                      <div className="mt-1">
                        <MiniProgressBar
                          value={lic.progress}
                          color={lic.color}
                          width="w-28"
                        />
                      </div>
                    </div>

                    <div className="shrink-0 text-right">
                      <span className="inline-block text-xs font-semibold text-gray-700 bg-gray-100 px-2 py-0.5 rounded border border-gray-200">
                        {lic.remainingText}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </Card>
          </div>
        </div>

        {/* 4. Directions From Regulators */}
        <Card className="p-4 space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-gray-100">
            <div>
              <h3 className="text-[13px] font-bold text-gray-900">
                Directions from regulators
              </h3>
              <span className="text-xs text-gray-400">DGMS, SPCB, and MoEFCC orders</span>
            </div>

            <Button variant="secondary" size="xs" className="text-xs flex items-center gap-1">
              <FileText className="w-3.5 h-3.5" />
              Upload inspection report
            </Button>
          </div>

          <DataTable
            columns={directionColumns}
            data={data.regulatorDirections}
            keyField="id"
          />
        </Card>
      </div>
    </PageShell>
  );
}
