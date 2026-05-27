function renderStats() {
  const stats = state.data.stats || {};
  const cards = [
    ['Total landlords', stats.total_landlords ?? state.data.landlords.length],
    ['Approved landlords', stats.approved_landlords ?? state.data.landlords.filter((l) => l.is_approved).length],
    ['Pending landlords', stats.pending_landlords ?? state.data.landlords.filter((l) => !l.is_approved).length],
    ['Total properties', stats.total_properties ?? state.data.properties.length],
    ['Approved properties', stats.approved_properties ?? state.data.properties.filter((p) => p.is_approved).length],
    ['Pending properties', stats.pending_properties ?? state.data.properties.filter((p) => !p.is_approved).length],
    ['Rejected/suspended', stats.rejected_properties ?? 0],
    ['Total payments', stats.total_payments ?? state.data.payments.length],
    ['Successful payments', stats.successful_payments ?? state.data.payments.filter((p) => p.status === 'confirmed').length],
    ['Pending/failed', (stats.pending_payments ?? 0) + (stats.failed_payments ?? 0)],
    ['Confirmed revenue', money.format(Number(stats.total_revenue ?? 0))],
  ];

  els.statsGrid.innerHTML = cards
    .map(
      ([label, value]) => `
        <article class="stat-card">
          <div class="stat-label">${label}</div>
          <div class="stat-value">${value}</div>
        </article>
      `,
    )
    .join('');

  els.pendingLandlordsShortcut.textContent = `${stats.pending_landlords ?? 0} pending landlord approvals`;
  els.pendingPropertiesShortcut.textContent = `${stats.pending_properties ?? 0} pending property approvals`;
  els.paymentsShortcut.textContent = `${(stats.pending_payments ?? 0) + (stats.failed_payments ?? 0)} pending or failed payments`;
}

function renderActivity() {
  const landlordEvents = state.data.landlords.slice(0, 3).map((landlord) => ({
    title: `${landlord.full_name || 'Landlord'} ${landlord.is_approved ? 'is approved' : 'awaits approval'}`,
    meta: `Landlord joined ${formatDate(landlord.created_at)}`,
  }));
  const propertyEvents = state.data.properties.slice(0, 3).map((property) => ({
    title: `${property.title || 'Property'} ${property.is_approved ? 'is approved' : 'awaits review'}`,
    meta: `${property.landlord_name || 'Unknown landlord'} Â· ${formatDate(property.updated_at || property.created_at)}`,
  }));
  const paymentEvents = state.data.payments.slice(0, 3).map((payment) => ({
    title: `${money.format(Number(payment.amount || 0))} payment ${payment.status || 'pending'}`,
    meta: `${payment.landlord_name || 'Unknown payer'} Â· ${formatDate(payment.paid_at || payment.created_at)}`,
  }));

  const events = [...landlordEvents, ...propertyEvents, ...paymentEvents].slice(0, 8);
  els.activityList.innerHTML =
    events
      .map(
        (event) => `
          <article class="activity-item">
            <strong>${escapeHtml(event.title)}</strong>
            <span>${escapeHtml(event.meta)}</span>
          </article>
        `,
      )
      .join('') || `
        <div class="empty-state activity-empty">
          <span class="empty-state-icon" aria-hidden="true">
            <svg viewBox="0 0 24 24"><path d="M4 7h16M4 12h16M4 17h10" /></svg>
          </span>
          <strong>No recent activity</strong>
          <span>New landlord, property, and payment activity will appear here.</span>
        </div>
      `;
}

function landlordPropertyCount(landlordId) {
  return state.data.properties.filter((property) => property.landlord_id === landlordId).length;
}

function filteredLandlords() {
  const { search, status } = state.filters.landlords;
  return state.data.landlords.filter((landlord) => {
    const haystack = `${landlord.full_name || ''} ${landlord.phone || ''} ${landlord.email || ''}`.toLowerCase();
    const matchesSearch = haystack.includes(search.toLowerCase());
    const landlordStatus = statusFromApproval(landlord);
    return matchesSearch && (status === 'all' || landlordStatus === status);
  });
}

function renderLandlords() {
  const landlords = filteredLandlords();
  els.landlordsBody.innerHTML =
    landlords
      .map((landlord) => {
        const status = statusFromApproval(landlord);
        return `
          <tr>
            <td>
              <div class="meta-stack">
                <strong>${escapeHtml(landlord.full_name)}</strong>
                <span>ID ${escapeHtml(landlord.id)}</span>
              </div>
            </td>
            <td>
              <div class="meta-stack">
                <strong>${escapeHtml(landlord.phone)}</strong>
                <span>${escapeHtml(landlord.email || 'No email')}</span>
              </div>
            </td>
            <td>${landlordPropertyCount(landlord.id)}</td>
            <td>${statusBadge(status)}</td>
            <td>${formatDate(landlord.created_at)}</td>
            <td>
              <div class="row-actions">
                <button class="primary" type="button" data-detail="landlord" data-id="${landlord.id}">View</button>
                <button type="button" data-landlord-status="${landlord.id}" data-approved="true" ${landlord.is_approved ? 'disabled' : ''}>Approve</button>
                <button class="danger" type="button" data-landlord-status="${landlord.id}" data-approved="false" ${!landlord.is_approved ? 'disabled' : ''}>Suspend</button>
                <button class="danger" type="button" data-delete-landlord="${landlord.id}">Delete</button>
              </div>
            </td>
          </tr>
        `;
      })
      .join('') || '<tr><td class="empty-state" colspan="6">No landlords match this view.</td></tr>';
}

