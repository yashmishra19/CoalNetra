import { mockMineContext } from '../data/mockNav';
import { mockReportsApprovalsData } from '../data/mockReportsApprovals';

/**
 * Fetch navigation badge counts dynamically from underlying domain datasets
 */
export async function getNavCounts() {
  const reportsCount = mockReportsApprovalsData.signatureQueue?.length || 4;

  return Promise.resolve({
    today: 0,
    compliance: 8,
    inspectionsCapa: 6,
    riskMap: 0,
    workforce: 0,
    production: 0,
    reports: reportsCount,
    notifications: 10,
  });
}

/**
 * Fetch current mine context
 */
export async function getMineContext() {
  return Promise.resolve(mockMineContext);
}
