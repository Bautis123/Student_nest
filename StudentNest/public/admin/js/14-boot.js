if (state.token && state.user?.role === 'admin' && !isAdminSessionIdleExpired()) {
  showDashboard();
  setTab('overview');
  loadDashboard().catch((error) => {
    showToast(error.message || 'Could not refresh admin data.', 'error');
  });
  startCountdownTimer();
  resetIdleTimer();
} else {
  if (state.token) {
    clearAdminSession();
  }
  showLogin();
}

startIdleTracking();
