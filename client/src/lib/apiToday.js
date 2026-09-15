/**
 * Today Dashboard – pulls live data from the Express/Supabase backend.
 * The _source field in the response will be 'supabase_live' when live.
 */

import { mockTodayData } from '../data/mockToday';

const API = '/api/today';

export async function getTodayDashboard() {
  try {
    const res = await fetch(API);
    if (!res.ok) throw new Error('Failed to fetch today dashboard');
    return await res.json();
  } catch (err) {
    console.warn('Today API fetch failed, falling back to mock data:', err);
    return mockTodayData;
  }
}

export async function getTodayKPIStats() {
  const data = await getTodayDashboard();
  return data.kpiStats;
}

export async function getWaitingDecisions() {
  const data = await getTodayDashboard();
  return data.decisions;
}

export async function getHighestRiskZones() {
  const data = await getTodayDashboard();
  return data.riskHighest;
}

export async function getDeadlines() {
  const data = await getTodayDashboard();
  return data.deadlines;
}

export async function getInspectionsProgress() {
  const data = await getTodayDashboard();
  return data.inspections;
}

export async function getSystemInsights() {
  const data = await getTodayDashboard();
  return data.insights;
}

export async function getLiveReadings() {
  const data = await getTodayDashboard();
  return data.liveReadings;
}

export async function getFieldActivityFeed() {
  const data = await getTodayDashboard();
  return data.fieldFeed;
}
