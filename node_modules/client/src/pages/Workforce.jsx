import React, { useState, useEffect } from 'react';
import PageShell from '../components/layout/PageShell';
import {
  Card,
  Button,
  StatCard,
  DataTable,
  StatusBadge,
  MiniProgressBar,
  ActionListItem,
} from '../components/ui';
import {
  getWorkforceOverview,
} from '../lib/apiWorkforce';
import { MessageSquare, AlertCircle } from 'lucide-react';

export default function Workforce() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getWorkforceOverview().then((res) => {
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

  // Stopped at Gate Columns
  const stoppedColumns = [
    {
      key: 'name',
      label: 'Worker',
      render: (row) => (
        <div>
          <div className="font-semibold text-gray-950">{row.name}</div>
          <div className="text-[11px] text-gray-500 mt-0.5">{row.role}</div>
        </div>
      ),
    },
    {
      key: 'employer',
      label: 'Employer',
      render: (row) => <span className="text-gray-700">{row.employer}</span>,
    },
    {
      key: 'reason',
      label: 'Reason',
      render: (row) => (
        <span className="text-xs font-semibold text-red-700 bg-red-50 px-2 py-0.5 rounded border border-red-200">
          {row.reason}
        </span>
      ),
    },
    {
      key: 'since',
      label: 'Since',
      render: (row) => <span className="font-mono text-gray-500 text-[11px]">{row.since}</span>,
    },
    {
      key: 'action',
      label: '',
      align: 'right',
      render: (row) => {
        if (row.actionType === 'appeal-filed') {
          return <StatusBadge status="Appeal filed" />;
        }
        return (
          <Button variant="secondary" size="xs" className="text-[11px]">
            {row.actionLabel}
          </Button>
        );
      },
    },
  ];

  // Contractor Scorecard Columns
  const scorecardColumns = [
    {
      key: 'contractor',
      label: 'Contractor',
      render: (row) => (
        <span className="font-bold text-gray-900">{row.contractor}</span>
      ),
    },
    {
      key: 'work',
      label: 'Work',
      render: (row) => <span className="text-gray-600">{row.work}</span>,
    },
    {
      key: 'workers',
      label: 'Workers',
      align: 'center',
      render: (row) => (
        <span className="font-mono font-semibold text-gray-900">
          {row.workers}
        </span>
      ),
    },
    {
      key: 'score',
      label: 'Score',
      align: 'center',
      render: (row) => <StatusBadge status={row.score} />,
    },
    {
      key: 'incidents',
      label: 'Incidents',
      align: 'center',
      render: (row) => (
        <span
          className={`font-mono font-bold ${
            row.incidents > 0 ? 'text-red-600' : 'text-gray-600'
          }`}
        >
          {row.incidents}
        </span>
      ),
    },
    {
      key: 'capaClosedOnTime',
      label: 'CAPAs closed on time',
      render: (row) => (
        <MiniProgressBar
          value={row.capaClosedOnTime}
          showText
          width="w-20"
        />
      ),
    },
    {
      key: 'wageCheck',
      label: 'Wage check',
      align: 'center',
      render: (row) => <StatusBadge status={row.wageCheck} />,
    },
    {
      key: 'grievances',
      label: 'Grievances',
      align: 'center',
      render: (row) => (
        <span
          className={`font-mono font-bold ${
            row.grievances > 0 ? 'text-amber-600' : 'text-gray-500'
          }`}
        >
          {row.grievances}
        </span>
      ),
    },
  ];

  // Worker Grievances Columns
  const grievanceColumns = [
    {
      key: 'issue',
      label: 'Issue',
      render: (row) => (
        <div>
          <div className="font-semibold text-gray-950">{row.issue}</div>
          <div className="text-[11px] text-gray-500 mt-0.5">{row.location}</div>
        </div>
      ),
    },
    {
      key: 'language',
      label: 'Language',
      render: (row) => <span className="text-gray-600">{row.language}</span>,
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
            {data.header.syncStatus && (
              <div className="text-[12px] text-status-neutral italic mt-0.5">
                {data.header.syncStatus}
              </div>
            )}
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <Button
              variant="dark-blue"
              size="sm"
              className="text-xs font-semibold bg-[#1b3252] hover:bg-[#14263f] flex items-center gap-1.5"
            >
              <MessageSquare className="w-3.5 h-3.5" />
              Message contractors
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
              subtext={stat.subtext}
            />
          ))}
        </div>

        {/* 2. Two-Column Row: Stopped at Gate & Attendance by Shift */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Stopped at Gate */}
          <div className="lg:col-span-7 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                  <div>
                    <h3 className="text-[13px] font-bold text-gray-900">
                      Stopped at gate today
                    </h3>
                    <span className="text-xs text-gray-400">
                      {data.stoppedAtGate.subtitle}
                    </span>
                  </div>
                </div>

                <DataTable
                  columns={stoppedColumns}
                  data={data.stoppedAtGate.workers}
                  keyField="id"
                />
              </div>

              <div className="mt-3 pt-2 border-t border-gray-100 text-[11px] text-gray-500">
                {data.stoppedAtGate.footerNote}
              </div>
            </Card>
          </div>

          {/* Right: Attendance by Shift */}
          <div className="lg:col-span-5 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div className="space-y-4">
                <div className="pb-2 border-b border-gray-100">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Attendance by shift
                  </h3>
                  <span className="text-xs text-gray-400">
                    Deployment vs approved manpower budget
                  </span>
                </div>

                {/* Shift Bars */}
                <div className="space-y-3">
                  {data.attendanceByShift.shifts.map((shift, idx) => (
                    <div key={idx} className="space-y-1">
                      <div className="flex items-center justify-between text-xs font-semibold">
                        <span className="text-gray-900">{shift.name}</span>
                        <span className="font-mono text-gray-700">
                          {shift.count} / {shift.target} ({shift.percentage}%)
                        </span>
                      </div>
                      <MiniProgressBar
                        value={shift.percentage}
                        color={shift.color}
                        width="w-full"
                        height="h-2"
                      />
                    </div>
                  ))}
                </div>

                {/* Breakdown text */}
                <div className="text-[11px] text-gray-500 pt-1">
                  {data.attendanceByShift.breakdownText}
                </div>

                {/* Proxy Check Callout */}
                <div className="bg-amber-50 border border-amber-200 rounded-md p-2.5 flex items-start gap-2 text-xs text-amber-900">
                  <AlertCircle className="w-4 h-4 text-amber-700 shrink-0 mt-0.5" />
                  <span className="leading-relaxed">
                    {data.attendanceByShift.callout}
                  </span>
                </div>
              </div>
            </Card>
          </div>
        </div>

        {/* 3. Contractor Scorecard Full-Width DataTable */}
        <Card className="p-4 space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-gray-100">
            <div>
              <h3 className="text-[13px] font-bold text-gray-900">
                Contractor scorecard
              </h3>
              <span className="text-xs text-gray-400">
                Safety score based on CAPA turnaround, zero harm, and statutory wage compliance
              </span>
            </div>
          </div>

          <DataTable
            columns={scorecardColumns}
            data={data.contractorScorecard}
            keyField="id"
          />
        </Card>

        {/* 4. Two-Column Row: Wage Checks & Worker Grievances */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Wage Checks for August */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Wage checks for August
                  </h3>
                  <span className="text-xs text-gray-400">
                    Statutory e-transfer audit
                  </span>
                </div>

                <div className="divide-y divide-gray-100">
                  {data.wageChecks.map((item, idx) => (
                    <ActionListItem
                      key={item.id}
                      status={item.status}
                      title={item.title}
                      description={item.description}
                      timeInfo={item.timeInfo}
                      actions={item.actions}
                      isLast={idx === data.wageChecks.length - 1}
                    />
                  ))}
                </div>
              </div>
            </Card>
          </div>

          {/* Right: Worker Grievances */}
          <div className="lg:col-span-6 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Worker grievances
                  </h3>
                  <span className="text-xs text-gray-400">
                    Anonymous voice note & kiosk tickets
                  </span>
                </div>

                <DataTable
                  columns={grievanceColumns}
                  data={data.workerGrievances}
                  keyField="id"
                />
              </div>
            </Card>
          </div>
        </div>
      </div>
    </PageShell>
  );
}
