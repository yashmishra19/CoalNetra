import React, { useState, useEffect } from 'react';
import Button from '../ui/Button';

export default function AlertBanner({
  title = 'Serious accident notice is due to DGMS',
  description = 'Dumper operator injured on Haul Road North, 9 Sep at 22:02. Regional Inspector informed by phone at 23:31. The written notice draft is ready for your signature.',
  initialSeconds = 5 * 3600 + 17 * 60 + 17, // 05:17:17
  totalWindow = '24 hours',
  ctaText = 'Review and sign notice',
  onCtaClick,
}) {
  const [secondsLeft, setSecondsLeft] = useState(initialSeconds);

  useEffect(() => {
    const timer = setInterval(() => {
      setSecondsLeft((prev) => (prev > 0 ? prev - 1 : 0));
    }, 1000);
    return () => clearInterval(timer);
  }, []);

  const formatTimer = (totalSec) => {
    const hrs = Math.floor(totalSec / 3600);
    const mins = Math.floor((totalSec % 3600) / 60);
    const secs = totalSec % 60;
    return `${String(hrs).padStart(2, '0')}:${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  return (
    <div className="bg-white rounded-lg border border-gray-200 shadow-sm overflow-hidden flex items-stretch">
      {/* Left Hazard Stripes Border */}
      <div className="w-2.5 hazard-stripes shrink-0" />

      {/* Main Banner Content */}
      <div className="flex-1 p-3.5 flex flex-col md:flex-row md:items-center justify-between gap-4">
        {/* Text Details */}
        <div className="max-w-2xl">
          <h3 className="text-[13px] font-bold text-gray-900 leading-snug">
            {title}
          </h3>
          <p className="text-xs text-gray-600 mt-0.5 leading-relaxed">
            {description}
          </p>
        </div>

        {/* Right: Countdown & CTA Button */}
        <div className="flex items-center gap-4 shrink-0">
          <div className="text-right">
            <div className="text-xl font-extrabold text-red-600 tracking-tight font-mono leading-none">
              {formatTimer(secondsLeft)}
            </div>
            <div className="text-[10px] text-gray-500 font-medium leading-none mt-1">
              left of {totalWindow}
            </div>
          </div>

          <Button
            variant="dark-blue"
            size="sm"
            onClick={onCtaClick}
            className="px-3.5 py-2 font-semibold text-xs whitespace-nowrap bg-[#1e3a5f] hover:bg-[#172c47]"
          >
            {ctaText}
          </Button>
        </div>
      </div>
    </div>
  );
}
