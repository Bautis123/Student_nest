function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function formatDate(value) {
  if (!value) return '-';
  return new Date(value).toLocaleDateString('en-ZM', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
  });
}

function debounce(callback, delay = 220) {
  let timeout;
  return (...args) => {
    clearTimeout(timeout);
    timeout = setTimeout(() => callback(...args), delay);
  };
}

function authHeaders() {
  return {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${state.token}`,
  };
}

function persistAdminSession() {
  localStorage.setItem('studentNestAdminToken', state.token);
  localStorage.setItem('studentNestAdminUser', JSON.stringify(state.user));
  localStorage.setItem('studentNestAdminLastActive', String(Date.now()));
}

function clearAdminSession() {
  localStorage.removeItem('studentNestAdminToken');
  localStorage.removeItem('studentNestAdminUser');
  localStorage.removeItem('studentNestAdminLastActive');
}

function isAdminSessionIdleExpired() {
  const lastActive = Number(localStorage.getItem('studentNestAdminLastActive') || Date.now());
  return Date.now() - lastActive > ADMIN_IDLE_TIMEOUT_MS;
}

function touchAdminSession() {
  if (!state.token) return;
  localStorage.setItem('studentNestAdminLastActive', String(Date.now()));
}

function resetIdleTimer() {
  clearTimeout(idleTimer);
  if (!state.token) return;
  idleTimer = setTimeout(logout, ADMIN_IDLE_TIMEOUT_MS);
}

function startIdleTracking() {
  ['click', 'keydown', 'pointermove', 'scroll', 'touchstart'].forEach((eventName) => {
    document.addEventListener(eventName, () => {
      touchAdminSession();
      resetIdleTimer();
    }, { passive: true });
  });
  touchAdminSession();
  resetIdleTimer();
}

async function api(path, options = {}) {
  touchAdminSession();
  const response = await fetch(path, {
    ...options,
    headers: {
      ...(state.token ? authHeaders() : { 'Content-Type': 'application/json' }),
      ...(options.headers || {}),
    },
  });

  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(data.message || 'Request failed');
  }
  return data;
}

function showToast(message, type = 'success') {
  els.toast.textContent = message;
  els.toast.className = `toast ${type}`;
  setTimeout(() => els.toast.classList.add('hidden'), 3200);
}

function showLogin() {
  els.dashboardView.classList.add('hidden');
  els.loginView.classList.remove('hidden');
}

function showDashboard() {
  els.loginView.classList.add('hidden');
  els.dashboardView.classList.remove('hidden');
}

function setLoadingRows() {
  const row = '<tr><td class="loading-state" colspan="8">Loading admin data...</td></tr>';
  els.landlordsBody.innerHTML = row;
  els.propertiesBody.innerHTML = row;
  els.paymentsBody.innerHTML = row;
  els.logsBody.innerHTML = '<tr><td class="loading-state" colspan="7">Loading admin logs...</td></tr>';
  els.adminsBody.innerHTML = '<div class="loading-state">Loading admin accounts...</div>';
  els.activityList.innerHTML = '<div class="activity-item">Loading recent activity...</div>';
}

function statusFromApproval(item) {
  return item.is_approved ? 'approved' : 'pending';
}

function statusBadge(status) {
  const label = status.charAt(0).toUpperCase() + status.slice(1);
  return `<span class="badge ${escapeHtml(status)}">${escapeHtml(label)}</span>`;
}

function paymentBadge(status) {
  return statusBadge(status || 'pending');
}

function expiryInfo(property) {
  if (!property.listing_expires_at) {
    return {
      status: 'pending',
      label: 'No expiry set',
      countdown: 'Payment needed',
    };
  }

  const expiresAt = new Date(property.listing_expires_at);
  const diff = expiresAt.getTime() - Date.now();
  if (diff <= 0) {
    return {
      status: 'inactive',
      label: 'Expired',
      countdown: `Expired ${formatDate(property.listing_expires_at)}`,
    };
  }

  const days = Math.floor(diff / (24 * 60 * 60 * 1000));
  const hours = Math.floor((diff / (60 * 60 * 1000)) % 24);
  const isSoon = days < 7;
  return {
    status: isSoon ? 'pending' : 'approved',
    label: isSoon ? 'Expiring soon' : 'Active',
    countdown: days > 0 ? `${days}d ${hours}h left` : `${hours}h left`,
  };
}

function propertyHints(property) {
  const hints = [];
  const roomCount = Number(property.room_types || 0);
  const photoCount = Number(property.photo_count || 0);
  if (photoCount === 0) hints.push('No photos');
  if (roomCount === 0) hints.push('No rooms');
  if (!property.address || !property.latitude || !property.longitude) hints.push('Incomplete address');
  if (!property.nearest_school_id && !property.school_name) hints.push('No school link');
  return hints;
}

