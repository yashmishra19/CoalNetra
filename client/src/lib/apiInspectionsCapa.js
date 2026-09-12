import { mockInspectionsCapaData } from '../data/mockInspectionsCapa';

export async function getCapaOverview() {
  return Promise.resolve(mockInspectionsCapaData);
}

export async function getOpenCapas(filter = 'all') {
  let list = mockInspectionsCapaData.capaList;
  if (filter === 'overdue') {
    list = list.filter((c) => c.isOverdue || c.due.toLowerCase().includes('overdue'));
  } else if (filter === 'escalated') {
    list = list.filter((c) => c.isEscalated || c.status.toLowerCase().includes('escalated'));
  } else if (filter === 'contractor') {
    list = list.filter((c) => c.isContractor);
  }
  return Promise.resolve(list);
}

export async function getCapaDetail(id = 'CAPA-231') {
  return Promise.resolve(mockInspectionsCapaData.selectedCapaDetail);
}

export async function getTodayInspectionPlan() {
  return Promise.resolve(mockInspectionsCapaData.todayInspectionPlan);
}

export async function getShiftsInspectedHeatmap() {
  return Promise.resolve(mockInspectionsCapaData.shiftsInspectedHeatmap);
}
