import React from 'react';
import {
  Clock,
  ShieldCheck,
  ClipboardList,
  Map,
  Users,
  BarChart3,
  FileCheck2,
} from 'lucide-react';

export const navItems = [
  {
    key: 'today',
    label: 'Today',
    path: '/',
    icon: Clock,
    badgeKey: 'today',
  },
  {
    key: 'compliance',
    label: 'Compliance',
    path: '/compliance',
    icon: ShieldCheck,
    badgeKey: 'compliance',
  },
  {
    key: 'inspectionsCapa',
    label: 'Inspections & CAPA',
    path: '/inspections-capa',
    icon: ClipboardList,
    badgeKey: 'inspectionsCapa',
  },
  {
    key: 'riskMap',
    label: 'Risk map',
    path: '/risk-map',
    icon: Map,
    badgeKey: 'riskMap',
  },
  {
    key: 'workforce',
    label: 'Workforce',
    path: '/workforce',
    icon: Users,
    badgeKey: 'workforce',
  },
  {
    key: 'production',
    label: 'Production & environment',
    path: '/production-environment',
    icon: BarChart3,
    badgeKey: 'production',
  },
  {
    key: 'reports',
    label: 'Reports & approvals',
    path: '/reports-approvals',
    icon: FileCheck2,
    badgeKey: 'reports',
  },
];
