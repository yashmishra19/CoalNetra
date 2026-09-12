import { mockTodayData } from '../data/mockToday';

/**
 * Data access layer for the Today Dashboard
 * Returns structured data for the Today page.
 * Swapping for real Supabase/backend calls later only requires updating these functions.
 */

export async function getTodayDashboard() {
  return Promise.resolve(mockTodayData);
}

export async function getTodayKPIStats() {
  return Promise.resolve(mockTodayData.kpiStats);
}

export async function getWaitingDecisions() {
  return Promise.resolve(mockTodayData.decisions);
}

export async function getHighestRiskZones() {
  return Promise.resolve(mockTodayData.riskHighest);
}

export async function getDeadlines() {
  return Promise.resolve(mockTodayData.deadlines);
}

export async function getInspectionsProgress() {
  return Promise.resolve(mockTodayData.inspections);
}

export async function getSystemInsights() {
  return Promise.resolve(mockTodayData.insights);
}

export async function getLiveReadings() {
  return Promise.resolve(mockTodayData.liveReadings);
}

export async function getFieldActivityFeed() {
  return Promise.resolve(mockTodayData.fieldFeed);
}
