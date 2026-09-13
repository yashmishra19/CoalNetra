import React, { useState, useEffect } from 'react';
import PageShell from '../components/layout/PageShell';
import {
  Card,
  Button,
  ActionListItem,
  FilterPillGroup,
  DataTable,
  StatusBadge,
  ReportGeneratorPanel,
} from '../components/ui';
import {
  getReportsApprovalsOverview,
  getOtherApprovals,
} from '../lib/apiReportsApprovals';
import { ShieldCheck, CheckCircle2 } from 'lucide-react';

export default function Reports() {
  const [data, setData] = useState(null);
  const [activeFilter, setActiveFilter] = useState('all');
  const [approvalsList, setApprovalsList] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getReportsApprovalsOverview().then((res) => {
      setData(res);
      setApprovalsList(res.otherApprovals);
      setLoading(false);
    });
  }, []);

  const handleFilterChange = (key) => {
    setActiveFilter(key);
    getOtherApprovals(key).then(setApprovalsList);
  };

  if (loading || !data) {
    return (
      <PageShell>
        <div className="flex items-center justify-center min-h-[400px]">
          <div className="text-xs text-gray-500 animate-pulse">
            Loading Statutory Reports & Signatures...
          </div>
        </div>
      </PageShell>
    );
  }

  // Other Approvals Table Columns
  const approvalColumns = [
    {
      key: 'title',
      label: 'Request',
      render: (row) => (
        <div>
          <div className="font-semibold text-gray-950">{row.title}</div>
          <div className="text-[11px] text-gray-500 mt-0.5">{row.location}</div>
        </div>
      ),
    },
    {
      key: 'from',
      label: 'From',
      render: (row) => <span className="text-gray-800 font-medium">{row.from}</span>,
    },
    {
      key: 'neededBy',
      label: 'Needed by',
      render: (row) => (
        <span className="font-medium text-gray-900 text-xs">
          {row.neededBy}
        </span>
      ),
    },
    {
      key: 'status',
      label: 'Status',
      render: (row) => <StatusBadge status={row.status} />,
    },
    {
      key: 'actions',
      label: '',
      align: 'right',
      render: (row) => {
        if (row.actionType === 'approve-return') {
          return (
            <div className="flex items-center gap-1.5 justify-end">
              <Button variant="dark-blue" size="xs" className="px-2.5 py-1">
                Approve
              </Button>
              <Button variant="secondary" size="xs" className="px-2 py-1">
                Return
              </Button>
            </div>
          );
        }
        if (row.actionType === 'unblock-reject') {
          return (
            <div className="flex items-center gap-1.5 justify-end">
              <Button variant="dark-blue" size="xs" className="px-2.5 py-1">
                Unblock
              </Button>
              <Button variant="secondary" size="xs" className="px-2 py-1">
                Reject
              </Button>
            </div>
          );
        }
        if (row.actionType === 'open-only') {
          return (
            <Button variant="secondary" size="xs" className="px-2.5 py-1">
              Open
            </Button>
          );
        }
        return (
          <Button variant="secondary" size="xs" className="px-2.5 py-1">
            Remind
          </Button>
        );
      },
    },
  ];

  // Sent and Sealed Table Columns
  const sealedColumns = [
    {
      key: 'sent',
      label: 'Sent',
      render: (row) => (
        <span className="font-mono text-gray-600 text-[11px] whitespace-nowrap">
          {row.sent}
        </span>
      ),
    },
    {
      key: 'report',
      label: 'Report',
      render: (row) => (
        <span className="font-bold text-gray-900 leading-snug">
          {row.report}
        </span>
      ),
    },
    {
      key: 'sentTo',
      label: 'Sent to',
      render: (row) => <span className="text-gray-700">{row.sentTo}</span>,
    },
    {
      key: 'signedBy',
      label: 'Signed by',
      render: (row) => <span className="text-gray-800 font-medium">{row.signedBy}</span>,
    },
    {
      key: 'fingerprint',
      label: 'Fingerprint',
      render: (row) => (
        <span className="font-mono text-gray-500 text-[11px] bg-gray-50 px-1.5 py-0.5 rounded border border-gray-200">
          {row.fingerprint}
        </span>
      ),
    },
    {
      key: 'checkStatus',
      label: 'Check',
      align: 'right',
      render: (row) => (
        <div className="flex items-center gap-2 justify-end">
          <StatusBadge status={row.checkStatus} />
          {row.hasAnomaly && (
            <button
              type="button"
              onClick={() => alert('Audit log inspection opened: Revision made on 18 Aug by Sub-inspector.')}
              className="text-red-700 text-xs font-semibold hover:underline cursor-pointer"
            >
              {row.anomalyActionText}
            </button>
          )}
        </div>
      ),
    },
  ];

  return (
    <PageShell>
      <div className="space-y-4 pb-12">
        {/* Page Header */}
        <div className="pt-1">
          <h1 className="text-lg font-bold text-gray-950 tracking-tight">
            {data.header.title}
          </h1>
          <p className="text-xs text-gray-500 mt-0.5 leading-relaxed max-w-3xl">
            {data.header.subtitle}
          </p>
        </div>

        {/* 1. Two-Column Top Row: Signature Queue (Left) & Report Generator (Right) */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-stretch">
          {/* Left: Waiting for your signature */}
          <div className="lg:col-span-7 xl:col-span-7 flex">
            <Card className="p-4 w-full flex flex-col justify-between">
              <div>
                <div className="flex items-center justify-between pb-2 border-b border-gray-100 mb-2">
                  <h3 className="text-[13px] font-bold text-gray-900">
                    Waiting for your signature
                  </h3>
                  <span className="text-xs text-gray-400">
                    {data.signatureQueue.length} reports
                  </span>
                </div>

                <div className="divide-y divide-gray-100">
                  {data.signatureQueue.map((item, idx) => (
                    <ActionListItem
                      key={item.id}
                      status={item.status}
                      title={item.title}
                      description={item.description}
                      timeInfo={item.timeInfo}
                      actions={item.actions}
                      isLast={idx === data.signatureQueue.length - 1}
                    />
                  ))}
                </div>
              </div>
            </Card>
          </div>

          {/* Right: Report Generator Panel */}
          <div className="lg:col-span-5 xl:col-span-5 flex">
            <ReportGeneratorPanel
              reportOptions={data.reportGeneratorOptions.reports}
              periodOptions={data.reportGeneratorOptions.periods}
              helperText={data.reportGeneratorOptions.helperText}
              className="w-full"
            />
          </div>
        </div>

        {/* 2. Other Approvals Card */}
        <Card className="p-4 space-y-3">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-gray-100">
            <div>
              <h3 className="text-[13px] font-bold text-gray-900">
                Other approvals
              </h3>
              <span className="text-xs text-gray-400">
                Permits, plans and appeals
              </span>
            </div>

            <FilterPillGroup
              options={data.otherApprovalsFilters}
              activeKey={activeFilter}
              onChange={handleFilterChange}
            />
          </div>

          <DataTable
            columns={approvalColumns}
            data={approvalsList}
            keyField="id"
          />
        </Card>

        {/* 3. Sent and Sealed Cryptographic Audit Trail */}
        <Card className="p-4 space-y-3">
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-gray-100">
            <div>
              <h3 className="text-[13px] font-bold text-gray-900 flex items-center gap-1.5">
                <ShieldCheck className="w-4 h-4 text-emerald-600" />
                Sent and sealed
              </h3>
              <span className="text-xs text-gray-400">
                Cryptographic SHA-256 signatures locked into the immutable statutory compliance ledger.
              </span>
            </div>

            <Button
              variant="secondary"
              size="xs"
              onClick={() => alert('All cryptographic SHA-256 signatures verified intact against ledger.')}
              className="text-xs flex items-center gap-1 font-medium"
            >
              <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
              Check all records
            </Button>
          </div>

          <DataTable
            columns={sealedColumns}
            data={data.sentAndSealedRecords}
            keyField="id"
          />
        </Card>
      </div>
    </PageShell>
  );
}
