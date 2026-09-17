import React from 'react';
import Sidebar from './Sidebar';
import TopBar from './TopBar';

export default function PageShell({ children }) {
  return (
    <div className="min-h-screen bg-page-bg font-sans flex text-brand-primary">
      {/* Fixed Persistent Dark Sidebar */}
      <Sidebar />

      {/* Main Layout Area */}
      <div className="ml-[220px] min-h-screen bg-page-bg flex-1 flex flex-col min-w-0">
        {/* Global Top Bar */}
        <TopBar />

        {/* Page Content Viewport */}
        <main className="flex-1 p-6 overflow-y-auto max-w-[1340px] w-full mx-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

