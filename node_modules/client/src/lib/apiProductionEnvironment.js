import { mockProductionEnvironmentData } from '../data/mockProductionEnvironment';

export async function getProductionOverview() {
  return Promise.resolve(mockProductionEnvironmentData);
}

export async function getDailyCoalProduction() {
  return Promise.resolve(mockProductionEnvironmentData.dailyProduction);
}

export async function getDispatchReconciliation() {
  return Promise.resolve(mockProductionEnvironmentData.dispatchReconciliation);
}

export async function getAirQuality() {
  return Promise.resolve(mockProductionEnvironmentData.airQuality);
}

export async function getWaterNoiseDust() {
  return Promise.resolve(mockProductionEnvironmentData.waterNoiseDust);
}

export async function getEcConditions() {
  return Promise.resolve(mockProductionEnvironmentData.ecConditionsAndReclamation);
}
