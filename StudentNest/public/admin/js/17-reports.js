// Scam report triage (Reports tab).

const reportEls = {
  body: document.getElementById('reportsBody'),
  search: document.getElementById('reportSearch'),
  status: document.getElementById('reportStatusFilter'),
  navCount: document.getElementById('reportOpenCount'),
};
const reportFilters = { search: '', status: 'open' };
const reportReasonLabels = {
  upfront_payment: 'Asked for payment before viewing',
  fake_listing: 'Fake / not available',
  misleading: 'Misleading details',
  impersonation: 'Impersonating the landlord',
  other: 'Other',
};

function filteredReportedListings() {
  const search = reportFilters.search.toLowerCase();
  return (state.data.reports || []).filter((listing) => {
    const text = `${listing.title} ${listing.address || ''} ${listing.landlord_name || ''} ${(listing.reports || []).map((r) => r.details || '').join(' ')}`.toLowerCase();
    const statusMatches = reportFilters.status === 'all'
      || (reportFilters.status === 'open' && listing.open_count > 0)
      || (reportFilters.status === 'hidden' && listing.flagged_at);
    return text.includes(search) && statusMatches;
  });
}

function renderReports() {
  if (!reportEls.body) return;
  const needingDecision = (state.data.reports || []).filter((listing) => listing.open_count > 0).length;
  if (reportEls.navCount) {
    reportEls.navCount.textContent = needingDecision ? String(needingDecision) : '';
    reportEls.navCount.classList.toggle('hidden', !needingDecision);
  }

  reportEls.body.innerHTML = filteredReportedListings()
    .map((listing) => {
      const open = (listing.reports || []).filter((report) => report.status === 'open');
      const reasonCounts = open.reduce((counts, report) => ({ ...counts, [report.reason]: (counts[report.reason] || 0) + 1 }), {});
      return `
        <tr>
          <td>
            <div class="meta-stack">
              <strong>${escapeHtml(listing.title)}</strong>
              <span>${escapeHtml(listing.address || '')}</span>
              <span>Landlord: ${escapeHtml(listing.landlord_name || '-')} ${escapeHtml(listing.landlord_phone || '')}</span>
            </div>
          </td>
          <td>
            <div class="meta-stack">
              <strong>${listing.open_count} open</strong>
              <span>${listing.distinct_reporters} with a phone number</span>
              ${Object.entries(reasonCounts).map(([reason, count]) => `<span class="hint-list">${escapeHtml(reportReasonLabels[reason] || reason)} × ${count}</span>`).join('')}
            </div>
          </td>
          <td>
            <div class="meta-stack report-details-cell">
              ${open.slice(0, 3).map((report) => `<span>“${escapeHtml(report.details || reportReasonLabels[report.reason])}”${report.reporter_phone ? ` <em>${escapeHtml(report.reporter_phone)}</em>` : ''}</span>`).join('') || '<span>No open reports</span>'}
              ${open.length > 3 ? `<span class="hint-list">+${open.length - 3} more</span>` : ''}
            </div>
          </td>
          <td>
            <div class="meta-stack">
              ${listing.flagged_at ? statusBadge('inactive') + '<span>Hidden from students</span>'
                : listing.is_approved && listing.is_active ? statusBadge('approved') + '<span>Visible to students</span>'
                  : statusBadge('pending') + '<span>Not published</span>'}
            </div>
          </td>
          <td>${formatDate(listing.last_reported_at)}</td>
          <td>
            <div class="row-actions">
              <button class="primary" type="button" data-detail="property" data-id="${listing.property_id}">View listing</button>
              <button type="button" data-report-action="dismiss" data-id="${listing.property_id}" ${listing.open_count ? '' : 'disabled'}>Dismiss</button>
              <button class="danger" type="button" data-report-action="take_down" data-id="${listing.property_id}" ${listing.open_count || listing.flagged_at ? '' : 'disabled'}>Take down</button>
            </div>
          </td>
        </tr>`;
    })
    .join('') || '<tr><td class="empty-state" colspan="6">No reported listings in this view.</td></tr>';
}

reportEls.search?.addEventListener('input', debounce((event) => {
  reportFilters.search = event.target.value;
  renderReports();
}, 150));

reportEls.status?.addEventListener('change', (event) => {
  reportFilters.status = event.target.value;
  renderReports();
});

reportEls.body?.addEventListener('click', async (event) => {
  const button = event.target.closest('[data-report-action]');
  if (!button) return;
  const takeDown = button.dataset.reportAction === 'take_down';
  const note = await confirmAction({
    title: takeDown ? 'Take this listing down?' : 'Dismiss these reports?',
    message: takeDown
      ? 'The listing will be unpublished, lose its verified badge and need re-approval. Open reports are closed as resolved.'
      : 'The reports will be closed as unfounded and the listing will be visible to students again.',
    needsReason: true,
    confirmLabel: takeDown ? 'Take down' : 'Dismiss reports',
  });
  if (note === null) return;
  await runAction(
    () => api(`/api/admin/reports/${button.dataset.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ action: button.dataset.reportAction, note }),
    }),
    takeDown ? 'Listing taken down.' : 'Reports dismissed.',
  );
});
