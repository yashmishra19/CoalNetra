import React from 'react';
import { Camera, CheckCircle2 } from 'lucide-react';

export default function BeforeAfterPhotos({
  before = {
    title: 'Before: Low berm',
    caption: 'Berm height 0.8m (min required 1.5m)',
    timestamp: '9 Sep 22:15',
  },
  after = {
    title: 'After: Berm built to 1.6m',
    caption: 'Verified with laser level & GPS hash',
    timestamp: '11 Sep 14:30',
  },
  className = '',
}) {
  return (
    <div className={`grid grid-cols-2 gap-2.5 ${className}`}>
      <div className="bg-slate-100 border border-slate-200 rounded-md p-2.5 flex flex-col justify-between">
        <div className="h-20 bg-slate-200/80 rounded flex items-center justify-center text-slate-500 relative overflow-hidden">
          <div className="flex flex-col items-center gap-1">
            <Camera className="w-5 h-5 text-slate-400" />
            <span className="text-[10px] font-bold text-slate-600 uppercase tracking-wider">
              Before Photo
            </span>
          </div>
          <span className="absolute bottom-1 right-1.5 text-[9px] font-mono text-slate-500 bg-white/80 px-1 rounded">
            {before.timestamp}
          </span>
        </div>
        <div className="mt-1.5 text-[11px]">
          <div className="font-semibold text-gray-900 leading-tight">
            {before.title}
          </div>
          <div className="text-[10px] text-gray-500 leading-tight mt-0.5">
            {before.caption}
          </div>
        </div>
      </div>

      <div className="bg-emerald-50/60 border border-emerald-200 rounded-md p-2.5 flex flex-col justify-between">
        <div className="h-20 bg-emerald-100/60 rounded flex items-center justify-center text-emerald-700 relative overflow-hidden">
          <div className="flex flex-col items-center gap-1">
            <CheckCircle2 className="w-5 h-5 text-emerald-600" />
            <span className="text-[10px] font-bold text-emerald-800 uppercase tracking-wider">
              After Photo
            </span>
          </div>
          <span className="absolute bottom-1 right-1.5 text-[9px] font-mono text-emerald-700 bg-white/90 px-1 rounded">
            {after.timestamp}
          </span>
        </div>
        <div className="mt-1.5 text-[11px]">
          <div className="font-semibold text-gray-900 leading-tight">
            {after.title}
          </div>
          <div className="text-[10px] text-gray-500 leading-tight mt-0.5">
            {after.caption}
          </div>
        </div>
      </div>
    </div>
  );
}
