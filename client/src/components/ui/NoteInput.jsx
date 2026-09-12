import React, { useState } from 'react';
import Button from './Button';

/**
 * Reusable NoteInput component with audit trail submission and challenge actions
 */
export default function NoteInput({
  placeholder = 'Add an operational observation or corrective note for Dump-3...',
  primaryButtonLabel = 'Save note to audit trail',
  secondaryButtonLabel = 'Challenge this score',
  onSave,
  onChallenge,
  className = '',
}) {
  const [note, setNote] = useState('');

  const handleSave = () => {
    if (onSave) onSave(note);
    setNote('');
  };

  return (
    <div className={`space-y-2.5 pt-3 border-t border-gray-100 ${className}`}>
      <textarea
        rows={2}
        value={note}
        onChange={(e) => setNote(e.target.value)}
        placeholder={placeholder}
        className="w-full text-xs p-2.5 rounded-md border border-gray-300 focus:outline-none focus:ring-1 focus:ring-slate-900 focus:border-slate-900 placeholder:text-gray-400 bg-white"
      />

      <div className="flex items-center gap-2">
        <Button
          variant="dark-blue"
          size="xs"
          onClick={handleSave}
          className="text-xs font-semibold px-3 py-1.5 bg-[#1b3252] hover:bg-[#14263f]"
        >
          {primaryButtonLabel}
        </Button>
        <Button
          variant="secondary"
          size="xs"
          onClick={onChallenge}
          className="text-xs font-medium px-3 py-1.5"
        >
          {secondaryButtonLabel}
        </Button>
      </div>
    </div>
  );
}
