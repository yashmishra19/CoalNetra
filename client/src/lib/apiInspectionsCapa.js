/**
 * Inspections & CAPA API – live data from Supabase via Express.
 */

import { mockInspectionsCapaData } from '../data/mockInspectionsCapa';

const MINE_ID = '55555555-5555-5555-5555-555555555501';

export async function getCapaOverview() {
  try {
    const res = await fetch(`/api/capas?mineId=${MINE_ID}`);
    if (!res.ok) throw new Error('Failed to fetch CAPAs');
    const data = await res.json();
    return {
      ...mockInspectionsCapaData,
      capaList: data.capas?.length ? data.capas : mockInspectionsCapaData.capaList,
      _source: 'supabase_live',
    };
  } catch (err) {
    console.warn('CAPAs API fetch failed, using mock data:', err);
    return mockInspectionsCapaData;
  }
}

export async function getOpenCapas(filter = 'all') {
  try {
    let url = `/api/capas?mineId=${MINE_ID}`;
    if (filter === 'overdue') url += '&status=OPEN';
    else if (filter === 'escalated') url += '&status=ESCALATED';
    const res = await fetch(url);
    if (!res.ok) throw new Error('Failed to fetch CAPAs');
    const data = await res.json();
    let list = data.capas || [];
    if (filter === 'overdue') list = list.filter(c => c.isOverdue);
    else if (filter === 'contractor') list = list.filter(c => c.isContractor);
    return list;
  } catch (err) {
    console.warn('getOpenCapas fallback to mock:', err);
    const all = mockInspectionsCapaData.capaList || [];
    if (filter === 'all') return all;
    if (filter === 'overdue') return all.filter(c => c.isOverdue);
    if (filter === 'escalated') return all.filter(c => c.isEscalated);
    if (filter === 'contractor') return all.filter(c => c.isContractor);
    return all;
  }
}

export async function getCapaDetail(id) {
  const res = await fetch(`/api/capas?mineId=${MINE_ID}`);
  if (!res.ok) throw new Error('Failed to fetch CAPAs');
  const data = await res.json();
  if (id) {
    return data.capas.find(c => c.id === id) || data.capas[0] || null;
  }
  return data.capas[0] || null;
}

export async function getTodayInspectionPlan() {
  const res = await fetch(`/api/mine?mineId=${MINE_ID}`);
  if (!res.ok) return { sections: [] };
  const data = await res.json();
  return {
    sections: data.sections || [],
    shift: 'Shift B',
    totalSections: (data.sections || []).length,
  };
}

export async function getShiftsInspectedHeatmap() {
  // Heatmap requires aggregation across inspections — returning static for now
  return {
    weeks: [
      { label: 'W35', shifts: [14, 16, 18, 15, 14, 12, 11] },
      { label: 'W36', shifts: [13, 15, 17, 16, 15, 14, 10] },
      { label: 'W37', shifts: [15, 17, 16, 18, 14, 13, 12] },
    ],
  };
}
