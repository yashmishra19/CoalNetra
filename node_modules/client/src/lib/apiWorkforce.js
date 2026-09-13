import { mockWorkforceData } from '../data/mockWorkforce';

export async function getWorkforceOverview() {
  return Promise.resolve(mockWorkforceData);
}

export async function getStoppedAtGate() {
  return Promise.resolve(mockWorkforceData.stoppedAtGate);
}

export async function getAttendanceByShift() {
  return Promise.resolve(mockWorkforceData.attendanceByShift);
}

export async function getContractorScorecard() {
  return Promise.resolve(mockWorkforceData.contractorScorecard);
}

export async function getWageChecks() {
  return Promise.resolve(mockWorkforceData.wageChecks);
}

export async function getWorkerGrievances() {
  return Promise.resolve(mockWorkforceData.workerGrievances);
}
