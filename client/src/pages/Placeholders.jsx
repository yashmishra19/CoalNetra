import React from 'react';
import PageShell from '../components/layout/PageShell';
import Card from '../components/ui/Card';

export function RiskMap() {
  return (
    <PageShell>
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">Mine Risk Map</h1>
        <p className="text-xs text-gray-500 mt-1">Full spatial mine risk telemetry, slope radar, dump stability, and water sumps.</p>
      </div>
      <Card className="p-8 text-center text-gray-500">
        <p className="text-sm font-semibold text-gray-700">Interactive Full Risk Map Ready for Design</p>
      </Card>
    </PageShell>
  );
}

export function Production() {
  return (
    <PageShell>
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">Production & Environment</h1>
        <p className="text-xs text-gray-500 mt-1">Coal extraction, OB removal, dispatch reconciliation, and environmental sensors.</p>
      </div>
      <Card className="p-8 text-center text-gray-500">
        <p className="text-sm font-semibold text-gray-700">Production & Environment Page Ready for Design</p>
      </Card>
    </PageShell>
  );
}

export function Reports() {
  return (
    <PageShell>
      <div className="mb-6">
        <h1 className="text-xl font-bold text-gray-900">Reports & Approvals</h1>
        <p className="text-xs text-gray-500 mt-1">Pending statutory submissions, manager signatures, and approval queues.</p>
      </div>
      <Card className="p-8 text-center text-gray-500">
        <p className="text-sm font-semibold text-gray-700">Reports & Approvals Page Ready for Design</p>
      </Card>
    </PageShell>
  );
}
