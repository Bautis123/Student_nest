if (state.token && state.user?.role === 'admin') {
  showDashboard();
  setTab('overview');
  loadDashboard().catch(logout);
  startCountdownTimer();
} else {
  showLogin();
}
