/**
 * Date, time, duration, and number formatting utilities
 */

export function formatDate(dateString, format = 'short') {
  if (!dateString) return '';
  const d = new Date(dateString);
  if (isNaN(d.getTime())) return dateString;
  
  if (format === 'short') {
    // e.g. "12 Sep"
    return d.toLocaleDateString('en-GB', { day: 'numeric', month: 'short' });
  }
  if (format === 'full') {
    // e.g. "Thu 12 Sep 2024, 16:20"
    return d.toLocaleDateString('en-GB', {
      weekday: 'short',
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      hour12: false
    });
  }
  return d.toLocaleDateString();
}

export function formatTime(timeString) {
  if (!timeString) return '';
  return timeString;
}

export function formatNumber(num) {
  if (num === null || num === undefined) return '';
  return new Intl.NumberFormat('en-IN').format(num);
}
