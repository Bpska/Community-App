/* ─── Admin Panel — React API Client ────────────────────────────────────────── */

const API_BASE = 'http://72.61.169.195:3002/api';
export const MEDIA_BASE = 'http://72.61.169.195:3002';

let logoutHandler = null;

export function registerLogoutHandler(handler) {
  logoutHandler = handler;
}

export function getToken() {
  return localStorage.getItem('admin_token');
}

export function setToken(token) {
  localStorage.setItem('admin_token', token);
}

export function clearToken() {
  localStorage.removeItem('admin_token');
  localStorage.removeItem('admin_user');
}

export function isLoggedIn() {
  return !!getToken();
}

export function getAdminUser() {
  try {
    return JSON.parse(localStorage.getItem('admin_user') || '{}');
  } catch (e) {
    return {};
  }
}

async function apiFetch(path, options = {}) {
  const token = getToken();
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
    ...(options.headers || {}),
  };

  const res = await fetch(`${API_BASE}${path}`, {
    ...options,
    headers,
  });

  if (res.status === 401) {
    clearToken();
    if (logoutHandler) {
      logoutHandler();
    }
    throw new Error('Session expired. Please log in again.');
  }

  if (!res.ok) {
    const err = await res.json().catch(() => ({ error: res.statusText }));
    throw new Error(err.error || err.message || `Error ${res.status}`);
  }

  return res.json();
}

// ── Auth ──
export async function adminLogin(username, password) {
  const data = await apiFetch('/admin/login', {
    method: 'POST',
    body: JSON.stringify({ username, password }),
  });
  setToken(data.token);
  localStorage.setItem('admin_user', JSON.stringify(data.admin || {}));
  return data;
}

// ── Dashboard ──
export async function fetchStats() {
  return apiFetch('/admin/stats');
}

// ── Users ──
export async function fetchUsers(params = {}) {
  const q = new URLSearchParams(params).toString();
  return apiFetch(`/admin/users${q ? '?' + q : ''}`);
}

export async function suspendUser(userId) {
  return apiFetch(`/admin/users/${userId}/suspend`, { method: 'POST' });
}

export async function activateUser(userId) {
  return apiFetch(`/admin/users/${userId}/activate`, { method: 'POST' });
}

export async function deleteUser(userId) {
  return apiFetch(`/admin/users/${userId}`, { method: 'DELETE' });
}

export async function fetchUserCommunities(userId) {
  return apiFetch(`/admin/users/${userId}/communities`);
}

// ── Communities ──
export async function fetchCommunities(params = {}) {
  const q = new URLSearchParams(params).toString();
  return apiFetch(`/admin/communities${q ? '?' + q : ''}`);
}

export async function toggleCommunityStatus(communityId, isActive) {
  return apiFetch(`/admin/communities/${communityId}/status`, {
    method: 'POST',
    body: JSON.stringify({ isActive }),
  });
}

export async function deleteCommunity(communityId) {
  return apiFetch(`/admin/communities/${communityId}`, { method: 'DELETE' });
}

export async function fetchCommunityMembers(communityId) {
  return apiFetch(`/admin/communities/${communityId}/members`);
}

// ── Messages ──
export async function fetchMessages(params = {}) {
  const q = new URLSearchParams(params).toString();
  return apiFetch(`/admin/messages${q ? '?' + q : ''}`);
}

export async function deleteMessage(messageId) {
  return apiFetch(`/admin/messages/${messageId}`, { method: 'DELETE' });
}
