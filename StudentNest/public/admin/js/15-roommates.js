// Roommate request moderation (Roommates tab).

const roommateEls = {
  body: document.getElementById('roommatesBody'),
  search: document.getElementById('roommateSearch'),
  status: document.getElementById('roommateStatusFilter'),
  navCount: document.getElementById('roommatePendingCount'),
};
const roommateFilters = { search: '', status: 'pending' };
const roommateShareLabels = { female: 'Shares with women', male: 'Shares with men', any: 'Open to anyone' };
const roommateGenderLabels = { female: 'Woman', male: 'Man', unspecified: 'Prefers not to say' };
const roommateStatusLabels = { pending: 'Waiting', approved: 'Live', rejected: 'Rejected', expired: 'Expired' };

function roommateStatus(post) {
  if (post.status === 'approved' && post.expires_at && new Date(post.expires_at).getTime() <= Date.now()) return 'expired';
  return post.status;
}

function filteredRoommatePosts() {
  const search = roommateFilters.search.toLowerCase();
  return (state.data.roommates || []).filter((post) => {
    const haystack = `${post.display_name} ${post.school_name || ''} ${post.phone} ${post.about || ''}`.toLowerCase();
    const status = roommateStatus(post);
    return haystack.includes(search) && (roommateFilters.status === 'all' || status === roommateFilters.status);
  });
}

function renderRoommates() {
  if (!roommateEls.body) return;
  const pending = (state.data.roommates || []).filter((post) => post.status === 'pending').length;
  if (roommateEls.navCount) {
    roommateEls.navCount.textContent = pending ? String(pending) : '';
    roommateEls.navCount.classList.toggle('hidden', !pending);
  }

  roommateEls.body.innerHTML = filteredRoommatePosts()
    .map((post) => {
      const status = roommateStatus(post);
      const reasons = Array.isArray(post.report_reasons) ? post.report_reasons : [];
      return `
        <tr>
          <td>
            <div class="meta-stack">
              <strong>${escapeHtml(post.display_name)}</strong>
              <span>${escapeHtml(roommateGenderLabels[post.gender] || post.gender)} · ${escapeHtml(roommateShareLabels[post.share_with] || post.share_with)}</span>
              <span>${escapeHtml(post.phone)}</span>
            </div>
          </td>
          <td>
            <div class="meta-stack">
              <strong>${escapeHtml(post.school_name || '-')}</strong>
              <span>Up to ${money.format(Number(post.budget_max || 0))} / month</span>
              ${post.move_in ? `<span>Move in ${escapeHtml(formatDate(post.move_in))}</span>` : ''}
            </div>
          </td>
          <td><div class="meta-stack roommate-about-cell"><span>${escapeHtml(post.about || '—')}</span>${post.review_note ? `<span class="hint-list">Note: ${escapeHtml(post.review_note)}</span>` : ''}</div></td>
          <td>
            <div class="meta-stack">
              ${statusBadge(status)}
              <span>${escapeHtml(roommateStatusLabels[status])}${status === 'approved' && post.expires_at ? ` until ${escapeHtml(formatDate(post.expires_at))}` : ''}</span>
              <span>${Number(post.contact_views || 0)} contact views</span>
            </div>
          </td>
          <td>
            <div class="meta-stack">
              <strong>${Number(post.report_count || 0)}</strong>
              ${reasons.slice(0, 2).map((reason) => `<span class="hint-list">“${escapeHtml(reason)}”</span>`).join('')}
            </div>
          </td>
          <td>${formatDate(post.created_at)}</td>
          <td>
            <div class="row-actions">
              <button class="primary" type="button" data-roommate-decision="approved" data-id="${post.id}" ${status === 'approved' ? 'disabled' : ''}>${status === 'expired' ? 'Re-approve' : 'Approve'}</button>
              <button class="danger" type="button" data-roommate-decision="rejected" data-id="${post.id}" ${status === 'rejected' ? 'disabled' : ''}>Reject</button>
            </div>
          </td>
        </tr>`;
    })
    .join('') || '<tr><td class="empty-state" colspan="7">No roommate requests in this view.</td></tr>';
}

roommateEls.search?.addEventListener('input', debounce((event) => {
  roommateFilters.search = event.target.value;
  renderRoommates();
}, 150));

roommateEls.status?.addEventListener('change', (event) => {
  roommateFilters.status = event.target.value;
  renderRoommates();
});

roommateEls.body?.addEventListener('click', async (event) => {
  const button = event.target.closest('[data-roommate-decision]');
  if (!button) return;
  const approve = button.dataset.roommateDecision === 'approved';
  const note = await confirmAction({
    title: approve ? 'Approve roommate request?' : 'Reject roommate request?',
    message: approve
      ? 'Students will be able to see this request for 30 days and reveal the WhatsApp number.'
      : 'The request will be hidden. The student sees your note on their private page.',
    needsReason: true,
    confirmLabel: approve ? 'Approve' : 'Reject',
  });
  if (note === null) return;
  await runAction(
    () => api(`/api/admin/roommates/${button.dataset.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: button.dataset.roommateDecision, note }),
    }),
    approve ? 'Roommate request approved.' : 'Roommate request rejected.',
  );
});
