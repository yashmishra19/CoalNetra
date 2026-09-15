import { useEffect, useState } from 'react';
import { supabase } from './supabase';

const LIVE_TABLES = ['obligations', 'observations', 'capas', 'grievances'];

// Re-fetch pages after database events, with polling as a fallback for deployments
// where Supabase realtime has not yet been enabled.
export function useLiveRefresh(intervalMs = 30000) {
  const [version, setVersion] = useState(0);

  useEffect(() => {
    const channel = supabase.channel('coalnetra-live-data');
    LIVE_TABLES.forEach((table) => {
      channel.on('postgres_changes', { event: '*', schema: 'public', table }, () => {
        setVersion((current) => current + 1);
      });
    });
    channel.subscribe();
    const timer = window.setInterval(() => setVersion((current) => current + 1), intervalMs);

    return () => {
      window.clearInterval(timer);
      supabase.removeChannel(channel);
    };
  }, [intervalMs]);

  return version;
}
