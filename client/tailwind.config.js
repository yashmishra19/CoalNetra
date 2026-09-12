/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        sidebar: {
          dark: '#0f1115',
          panel: '#151821',
          hover: '#1c202c',
          active: '#222736',
          border: '#252a3a',
          text: '#9ca3af',
          'text-bright': '#f3f4f6',
        },
        page: {
          bg: '#f3f4f6',
          surface: '#ffffff',
          border: '#e5e7eb',
        },
        status: {
          critical: {
            DEFAULT: '#dc2626',
            bg: '#fef2f2',
            border: '#fecaca',
            text: '#991b1b',
            dark: '#b91c1c'
          },
          warning: {
            DEFAULT: '#d97706',
            bg: '#fffbeb',
            border: '#fde68a',
            text: '#92400e',
            dark: '#b45309'
          },
          good: {
            DEFAULT: '#16a34a',
            bg: '#f0fdf4',
            border: '#bbf7d0',
            text: '#166534',
            dark: '#15803d'
          },
          info: {
            DEFAULT: '#2563eb',
            bg: '#eff6ff',
            border: '#bfdbfe',
            text: '#1e40af',
            dark: '#1d4ed8'
          },
          neutral: {
            DEFAULT: '#6b7280',
            bg: '#f3f4f6',
            border: '#e5e7eb',
            text: '#374151',
          }
        },
        brand: {
          primary: '#1e293b',
          accent: '#2563eb',
          dark: '#0f172a',
        }
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', 'sans-serif'],
      },
      fontSize: {
        '2xs': '0.6875rem', // 11px
      }
    },
  },
  plugins: [],
}
