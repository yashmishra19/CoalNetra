import React from 'react';
import { ChevronRight } from 'lucide-react';

export default function StepPipeline({ steps = [], className = '' }) {
  return (
    <div className={`bg-white rounded-lg border border-page-border p-4 shadow-sm ${className}`}>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-2 items-center">
        {steps.map((step, idx) => {
          const isLast = idx === steps.length - 1;

          return (
            <div key={idx} className="flex items-center justify-between relative">
              <div className="flex-1 p-2 rounded-md hover:bg-slate-50 transition-colors">
                <div className="flex items-baseline gap-2">
                  <span className="text-2xl font-black text-gray-950 tracking-tight leading-none">
                    {step.count}
                  </span>
                  <span className="text-xs font-bold text-gray-800">
                    {step.label}
                  </span>
                </div>
                {step.description && (
                  <div className="text-[11px] text-gray-500 mt-1 leading-tight">
                    {step.description}
                  </div>
                )}
              </div>

              {!isLast && (
                <div className="hidden md:flex items-center justify-center text-gray-300 px-2 shrink-0">
                  <ChevronRight className="w-5 h-5 text-gray-300 stroke-[2]" />
                </div>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
