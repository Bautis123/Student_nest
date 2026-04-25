async function openAdminStatsPage(id) {
  try {
    setTab('adminStats');
    els.adminStatsTitle.textContent = 'Loading admin stats...';
    els.adminStatsSubtitle.textContent = 'Preparing checks and balances.';
    els.adminStatsPage.innerHTML = '<div class="loading-state">Loading admin stats...</div>';

    const result = await api(`/api/admin/admins/${id}/details`);
    const admin = result.admin;
    const stats = result.stats || {};

    els.adminStatsTitle.textContent = admin.full_name || 'Admin stats';
    els.adminStatsSubtitle.textContent = `${admin.access_level === 'owner' ? 'Owner / full access' : 'Manager access'} Â· ${admin.phone || admin.email || 'Admin account'}`;
    els.adminStatsPage.innerHTML = `
      <section class="profile-hero admin-stats-hero">
        <div class="admin-avatar large">${escapeHtml(adminInitials(admin))}</div>
        <div>
          <h3>${escapeHtml(admin.full_name || 'Admin')}</h3>
          <p class="muted">${escapeHtml(admin.email || admin.phone || '-')}</p>
          <div class="admin-card-badges">
            ${statusBadge(admin.access_level === 'owner' ? 'owner' : 'manager')}
            ${statusBadge(admin.is_approved ? 'approved' : 'pending')}
          </div>
        </div>
      </section>
      ${adminSummaryCards(stats)}
      <section class="admin-stats-grid">
        <div class="panel-lite">
          <h3>Action breakdown</h3>
          ${statList(stats.action_breakdown, 'action')}
        </div>
        <div class="panel-lite">
          <h3>Entity breakdown</h3>
          ${statList(stats.entity_breakdown, 'entity_type')}
        </div>
        <div class="panel-lite">
          <h3>Last 30 days</h3>
          ${dailyActivityList(stats.daily_activity)}
        </div>
        <div class="panel-lite">
          <h3>Recent activity</h3>
          ${recentAdminActions(stats.recent_actions)}
        </div>
      </section>
    `;
  } catch (error) {
    els.adminStatsTitle.textContent = 'Admin stats unavailable';
    els.adminStatsSubtitle.textContent = '';
    els.adminStatsPage.innerHTML = `<div class="error-state">${escapeHtml(error.message)}</div>`;
  }
}

