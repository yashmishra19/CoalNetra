import React from 'react';

/**
 * Enhanced MineRiskMapGraphic supporting small (Today widget) and large (Full Risk Map page) modes
 */
export default function MineRiskMapGraphic({
  size = 'small',
  activeTab = 'risk',
  selectedSection,
  onSelectSection,
  className = '',
}) {
  const isLarge = size === 'large';
  const heightClass = isLarge ? 'h-80 md:h-[420px]' : 'h-44';

  return (
    <div className={`relative bg-[#f8fafc] border border-gray-200 rounded-md overflow-hidden p-1 ${className}`}>
      <svg
        viewBox="0 0 600 360"
        className={`w-full ${heightClass} object-contain`}
        xmlns="http://www.w3.org/2000/svg"
      >
        {/* Background Grid */}
        <defs>
          <pattern id="mapGrid" width="24" height="24" patternUnits="userSpaceOnUse">
            <path d="M 24 0 L 0 0 0 24" fill="none" stroke="#e2e8f0" strokeWidth="0.6" />
          </pattern>
          <radialGradient id="redHazardZone" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#ef4444" stopOpacity="0.45" />
            <stop offset="100%" stopColor="#b91c1c" stopOpacity="0.12" />
          </radialGradient>
          <radialGradient id="amberHazardZone" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#f59e0b" stopOpacity="0.4" />
            <stop offset="100%" stopColor="#d97706" stopOpacity="0.1" />
          </radialGradient>
          <radialGradient id="satelliteTerrain" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#334155" stopOpacity="0.25" />
            <stop offset="100%" stopColor="#0f172a" stopOpacity="0.05" />
          </radialGradient>
        </defs>

        <rect width="600" height="360" fill="#f8fafc" />
        <rect width="600" height="360" fill="url(#mapGrid)" />

        {/* Outer Lease Boundary */}
        <rect
          x="20"
          y="20"
          width="560"
          height="320"
          fill="none"
          stroke="#fca5a5"
          strokeWidth="1.2"
          strokeDasharray="6 3"
          rx="4"
        />
        <text x="35" y="38" fill="#ef4444" fontSize="9" fontWeight="bold">
          Statutory Lease Boundary (ML-84)
        </text>

        {/* Topography Pit Benches */}
        <ellipse cx="300" cy="180" rx="190" ry="110" fill="#e2e8f0" stroke="#cbd5e1" strokeWidth="1.5" />
        <ellipse cx="300" cy="180" rx="150" ry="85" fill="#cbd5e1" stroke="#94a3b8" strokeWidth="1.5" />
        <ellipse cx="300" cy="180" rx="110" ry="60" fill="#94a3b8" stroke="#64748b" strokeWidth="1.5" />
        <ellipse cx="295" cy="180" rx="65" ry="35" fill="#475569" stroke="#334155" strokeWidth="1.5" />
        <ellipse cx="295" cy="180" rx="30" ry="16" fill="#1e293b" />
        <text x="295" y="183" fill="#ffffff" fontSize="9" fontWeight="bold" textAnchor="middle">
          Pit-1 Deep Coal Sump
        </text>

        {/* Dump-3 High Hazard Area (Top Right) */}
        <path
          d="M 430 45 Q 540 40 520 125 Q 490 160 400 140 Q 390 80 430 45 Z"
          fill={activeTab === 'satellite' ? 'url(#satelliteTerrain)' : 'url(#redHazardZone)'}
          stroke="#ef4444"
          strokeWidth="1.8"
          strokeDasharray={activeTab === 'satellite' ? 'none' : '4 3'}
        />
        <text x="460" y="85" fill="#991b1b" fontSize="11" fontWeight="bold" textAnchor="middle">
          Dump-3 (Overburden)
        </text>
        <text x="460" y="98" fill="#b91c1c" fontSize="8" textAnchor="middle">
          Radar Alert 4.2mm/day · 118mm rain
        </text>

        {/* Dump-2 Moderate Hazard Area (Bottom Right) */}
        <path
          d="M 425 215 Q 535 220 515 285 Q 470 310 405 285 Q 395 240 425 215 Z"
          fill="url(#amberHazardZone)"
          stroke="#f59e0b"
          strokeWidth="1.4"
        />
        <text x="455" y="255" fill="#92400e" fontSize="10" fontWeight="bold" textAnchor="middle">
          Dump-2
        </text>
        <text x="455" y="267" fill="#b45309" fontSize="7.5" textAnchor="middle">
          Stable (0.4 mm/day)
        </text>

        {/* Haul Road North (Accident & Berm issue) */}
        <path
          d="M 60 75 Q 180 60 330 75 Q 410 80 440 60"
          fill="none"
          stroke="#dc2626"
          strokeWidth="3.5"
          strokeDasharray="6 3"
        />
        <text x="190" y="68" fill="#b91c1c" fontSize="9" fontWeight="bold">
          Haul Road North (Berm CAPA-231)
        </text>

        {/* Haul Road South */}
        <path
          d="M 60 270 Q 200 290 360 260 Q 460 280 540 295"
          fill="none"
          stroke="#64748b"
          strokeWidth="2.8"
          strokeDasharray="4 3"
        />
        <text x="165" y="290" fill="#475569" fontSize="9" fontWeight="600">
          Haul Road South (3 Water Tankers active)
        </text>

        {/* Bench 4 Coal Face Area */}
        <rect x="115" y="155" width="55" height="26" fill="#fef3c7" stroke="#f59e0b" strokeWidth="1.2" rx="3" />
        <text x="142" y="171" fill="#b45309" fontSize="8.5" fontWeight="bold" textAnchor="middle">
          Bench 4
        </text>
        <text x="142" y="179" fill="#92400e" fontSize="6.5" textAnchor="middle">
          Coal Face
        </text>

        {/* Sump-1 Reservoir */}
        <circle cx="245" cy="195" r="14" fill="#38bdf8" fillOpacity="0.8" stroke="#0284c7" strokeWidth="1.2" />
        <text x="245" y="198" fill="#0369a1" fontSize="8" fontWeight="bold" textAnchor="middle">
          Sump-1
        </text>

        {/* AD-2 Sonari Village Boundary Station */}
        <rect x="35" y="215" width="42" height="20" fill="#fee2e2" stroke="#ef4444" strokeWidth="1.2" rx="3" />
        <text x="56" y="227" fill="#991b1b" fontSize="8" fontWeight="bold" textAnchor="middle">
          AD-2
        </text>
        <text x="56" y="233" fill="#b91c1c" fontSize="6" textAnchor="middle">
          Sonari Boundary
        </text>

        {/* Coal Handling Plant (CHP) & Siding */}
        <rect x="35" y="105" width="48" height="22" fill="#eff6ff" stroke="#3b82f6" strokeWidth="1.2" rx="3" />
        <text x="59" y="117" fill="#1e40af" fontSize="8" fontWeight="bold" textAnchor="middle">
          CHP Siding
        </text>
        <text x="59" y="124" fill="#2563eb" fontSize="6" textAnchor="middle">
          Rail Dispatch 81%
        </text>

        {/* Explosives Magazine */}
        <rect x="50" y="30" width="38" height="18" fill="#f1f5f9" stroke="#64748b" strokeWidth="1" rx="2" />
        <text x="69" y="42" fill="#334155" fontSize="7.5" fontWeight="bold" textAnchor="middle">
          Magazine
        </text>

        {/* Workshop Area */}
        <rect x="100" y="30" width="38" height="18" fill="#f1f5f9" stroke="#64748b" strokeWidth="1" rx="2" />
        <text x="119" y="42" fill="#334155" fontSize="7.5" fontWeight="bold" textAnchor="middle">
          Workshop
        </text>

        {/* Compass Rose Indicator */}
        <g transform="translate(45, 315)">
          <circle cx="0" cy="0" r="11" fill="#ffffff" stroke="#cbd5e1" strokeWidth="1" />
          <path d="M 0 -10 L 3 -2 L -3 -2 Z" fill="#dc2626" />
          <path d="M 0 10 L 3 2 L -3 2 Z" fill="#64748b" />
          <text x="0" y="-11" fill="#1e293b" fontSize="7.5" fontWeight="bold" textAnchor="middle">
            N
          </text>
        </g>

        {/* Scale Bar (Large View) */}
        {isLarge && (
          <g transform="translate(85, 320)">
            <line x1="0" y1="0" x2="60" y2="0" stroke="#475569" strokeWidth="2" />
            <line x1="0" y1="-3" x2="0" y2="3" stroke="#475569" strokeWidth="2" />
            <line x1="60" y1="-3" x2="60" y2="3" stroke="#475569" strokeWidth="2" />
            <text x="30" y="-4" fill="#475569" fontSize="8" fontWeight="bold" textAnchor="middle">
              200 m
            </text>
          </g>
        )}

        {/* Risk Score Badges */}
        {/* Dump-3 Pin (81) */}
        <g transform="translate(465, 62)">
          <circle cx="0" cy="0" r="13" fill="#dc2626" stroke="#ffffff" strokeWidth="2" />
          <text x="0" y="4" fill="#ffffff" fontSize="10" fontWeight="black" textAnchor="middle">
            81
          </text>
        </g>

        {/* Haul Road North Pin (74) */}
        <g transform="translate(295, 68)">
          <circle cx="0" cy="0" r="12" fill="#dc2626" stroke="#ffffff" strokeWidth="2" />
          <text x="0" y="4" fill="#ffffff" fontSize="9.5" fontWeight="black" textAnchor="middle">
            74
          </text>
        </g>

        {/* Bench 4 Pin (66) */}
        <g transform="translate(142, 142)">
          <circle cx="0" cy="0" r="11" fill="#d97706" stroke="#ffffff" strokeWidth="2" />
          <text x="0" y="3.5" fill="#ffffff" fontSize="9" fontWeight="black" textAnchor="middle">
            66
          </text>
        </g>

        {/* Sonari Village Boundary Pin (58) */}
        <g transform="translate(56, 205)">
          <circle cx="0" cy="0" r="10" fill="#d97706" stroke="#ffffff" strokeWidth="1.5" />
          <text x="0" y="3" fill="#ffffff" fontSize="8" fontWeight="bold" textAnchor="middle">
            58
          </text>
        </g>

        {/* CHP Siding Pin (52) */}
        <g transform="translate(59, 95)">
          <circle cx="0" cy="0" r="9.5" fill="#d97706" stroke="#ffffff" strokeWidth="1.5" />
          <text x="0" y="3" fill="#ffffff" fontSize="7.5" fontWeight="bold" textAnchor="middle">
            52
          </text>
        </g>

        {/* Open Observations Markers (Visible if tab is 'observations' or in large mode) */}
        {(activeTab === 'observations' || isLarge) && (
          <>
            <circle cx="340" cy="72" r="3.5" fill="#ef4444" stroke="#ffffff" strokeWidth="1" className="animate-pulse" />
            <circle cx="480" cy="115" r="3.5" fill="#ef4444" stroke="#ffffff" strokeWidth="1" className="animate-pulse" />
            <circle cx="150" cy="180" r="3.5" fill="#f59e0b" stroke="#ffffff" strokeWidth="1" />
            <circle cx="50" cy="235" r="3.5" fill="#ef4444" stroke="#ffffff" strokeWidth="1" />
          </>
        )}
      </svg>
    </div>
  );
}
