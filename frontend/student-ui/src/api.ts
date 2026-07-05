const rawBase = (import.meta.env.VITE_API_URL as string | undefined) ?? '';

export const API_BASE = rawBase.replace(/\/$/, '');

export function apiUrl(path: string): string {
  const normalized = path.startsWith('/') ? path : `/${path}`;
  return `${API_BASE}${normalized}`;
}
