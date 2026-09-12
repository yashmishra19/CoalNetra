import { mockRiskMapData } from '../data/mockRiskMap';

export async function getRiskMapOverview() {
  return Promise.resolve(mockRiskMapData);
}

export async function getRiskMapSections() {
  return Promise.resolve(mockRiskMapData.rankedSections);
}

export async function getDumpScoreBreakdown(sectionId = 'Dump-3') {
  return Promise.resolve(mockRiskMapData.dumpScoreBreakdown);
}

export async function getRiskByHazardType() {
  return Promise.resolve(mockRiskMapData.hazardTypeBreakdown);
}

export async function getRiskInsights() {
  return Promise.resolve(mockRiskMapData.riskInsights);
}
