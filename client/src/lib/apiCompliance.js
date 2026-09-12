import { mockComplianceData } from '../data/mockCompliance';

export async function getComplianceOverview() {
  return Promise.resolve(mockComplianceData);
}

export async function getObligations(filter = 'all') {
  if (filter === 'all') {
    return Promise.resolve(mockComplianceData.obligations);
  }
  const filtered = mockComplianceData.obligations.filter(
    (item) => item.category === filter
  );
  return Promise.resolve(filtered);
}

export async function getLicencesAndClearances() {
  return Promise.resolve(mockComplianceData.licences);
}

export async function getRegulatorDirections() {
  return Promise.resolve(mockComplianceData.regulatorDirections);
}
