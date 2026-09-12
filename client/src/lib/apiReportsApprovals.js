import { mockReportsApprovalsData } from '../data/mockReportsApprovals';

export async function getSignatureQueue() {
  return Promise.resolve(mockReportsApprovalsData.signatureQueue);
}

export async function getReportGeneratorOptions() {
  return Promise.resolve(mockReportsApprovalsData.reportGeneratorOptions);
}

export async function getOtherApprovals(filter = 'all') {
  if (filter === 'all') {
    return Promise.resolve(mockReportsApprovalsData.otherApprovals);
  }
  const filtered = mockReportsApprovalsData.otherApprovals.filter(
    (item) => item.category === filter
  );
  return Promise.resolve(filtered);
}

export async function getSentAndSealedRecords() {
  return Promise.resolve(mockReportsApprovalsData.sentAndSealedRecords);
}

export async function getReportsApprovalsOverview() {
  return Promise.resolve(mockReportsApprovalsData);
}
