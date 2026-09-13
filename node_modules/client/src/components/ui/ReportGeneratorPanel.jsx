import React, { useState } from 'react';
import Card from './Card';
import Select from './Select';
import Checkbox from './Checkbox';
import Button from './Button';
import { FileDown, RefreshCw } from 'lucide-react';

export default function ReportGeneratorPanel({
  reportOptions = [
    'EC half-yearly compliance report',
    'Monthly production & safety return (Form I/II)',
    'DGMS quarterly accident statistics',
    'Consent to Operate (CTO) environmental audit',
    'Contractor wage & statutory dues summary',
  ],
  periodOptions = [
    'April to September 2026',
    'August 2026 (Monthly)',
    'July to September 2026 (Q2)',
    'FY 2025–2026 (Annual)',
  ],
  helperText = 'Uses data synced up to 16:18. 3 field records are still waiting to sync.',
  onGenerate,
  className = '',
}) {
  const [selectedReport, setSelectedReport] = useState(reportOptions[0]);
  const [selectedPeriod, setSelectedPeriod] = useState(periodOptions[0]);
  const [format, setFormat] = useState('PDF'); // 'PDF' | 'Excel'
  const [attachPhotos, setAttachPhotos] = useState(true);
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerate = () => {
    setIsGenerating(true);
    setTimeout(() => {
      setIsGenerating(false);
      if (onGenerate) {
        onGenerate({
          report: selectedReport,
          period: selectedPeriod,
          format,
          attachPhotos,
        });
      } else {
        alert(`Draft generated for "${selectedReport}" (${format})`);
      }
    }, 600);
  };

  return (
    <Card className={`p-4 flex flex-col justify-between h-full ${className}`}>
      <div className="space-y-3.5">
        {/* Header */}
        <div className="pb-2 border-b border-gray-100">
          <h3 className="text-[13px] font-bold text-gray-900">
            Generate a report
          </h3>
          <span className="text-xs text-gray-400">
            Compiled from verified field records
          </span>
        </div>

        {/* Report Dropdown */}
        <Select
          label="Report"
          options={reportOptions}
          value={selectedReport}
          onChange={setSelectedReport}
        />

        {/* Period Dropdown */}
        <Select
          label="Period"
          options={periodOptions}
          value={selectedPeriod}
          onChange={setSelectedPeriod}
        />

        {/* Format Toggle Pair (PDF / Excel) */}
        <div className="space-y-1">
          <label className="block text-[11px] font-semibold text-gray-700">
            Format
          </label>
          <div className="flex items-center gap-1.5 p-0.5 bg-gray-100 rounded border border-gray-200">
            <button
              type="button"
              onClick={() => setFormat('PDF')}
              className={`flex-1 py-1 text-xs rounded font-semibold transition-all ${
                format === 'PDF'
                  ? 'bg-slate-900 text-white shadow-xs'
                  : 'text-gray-700 hover:text-gray-900'
              }`}
            >
              PDF
            </button>
            <button
              type="button"
              onClick={() => setFormat('Excel')}
              className={`flex-1 py-1 text-xs rounded font-semibold transition-all ${
                format === 'Excel'
                  ? 'bg-slate-900 text-white shadow-xs'
                  : 'text-gray-700 hover:text-gray-900'
              }`}
            >
              Excel
            </button>
          </div>
        </div>

        {/* Checkbox */}
        <div className="pt-1">
          <Checkbox
            label="Attach evidence photos"
            subtext="Includes GPS hashes and timestamps"
            checked={attachPhotos}
            onChange={setAttachPhotos}
          />
        </div>
      </div>

      {/* Button & Helper Footer */}
      <div className="pt-4 mt-2 border-t border-gray-100 space-y-2">
        <Button
          variant="dark-blue"
          size="sm"
          onClick={handleGenerate}
          disabled={isGenerating}
          className="w-full text-xs font-semibold py-2 bg-[#1b3252] hover:bg-[#14263f] flex items-center justify-center gap-1.5"
        >
          {isGenerating ? (
            <>
              <RefreshCw className="w-3.5 h-3.5 animate-spin" />
              Compiling statutory return...
            </>
          ) : (
            <>
              <FileDown className="w-3.5 h-3.5" />
              Generate draft
            </>
          )}
        </Button>

        {helperText && (
          <div className="text-[10px] text-gray-400 text-center leading-tight">
            {helperText}
          </div>
        )}
      </div>
    </Card>
  );
}
