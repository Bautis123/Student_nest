// Tenant review moderation (Reviews tab).

const reviewEls = {
  body: document.getElementById('reviewsBody'),
  search: document.getElementById('reviewSearch'),
  status: document.getElementById('reviewStatusFilter'),
  navCount: document.getElementById('reviewPendingCount'),
};
const reviewFilters = { search: '', status: 'pending' };
const reviewStatusLabels = { pending: 'Waiting', approved: 'Published', rejected: 'Rejected' };
const reviewRatingLabels = {
  rating_overall: 'Overall',
  rating_landlord: 'Landlord',
  rating_utilities: 'Water & power',
  rating_security: 'Security',
  rating_value: 'Value',
};

const reviewMonth = (value) => (value
  ? new Date(value).toLocaleDateString('en-GB', { month: 'short', year: 'numeric', timeZone: 'Africa/Lusaka' })
  : 'now');

function filteredReviews() {
  const search = reviewFilters.search.toLowerCase();
  return (state.data.reviews || []).filter((review) => {
    const haystack = `${review.property_title || ''} ${review.reviewer_name} ${review.phone} ${review.comment}`.toLowerCase();
    return haystack.includes(search) && (reviewFilters.status === 'all' || review.status === reviewFilters.status);
  });
}

function renderReviews() {
  if (!reviewEls.body) return;
  const pending = (state.data.reviews || []).filter((review) => review.status === 'pending').length;
  if (reviewEls.navCount) {
    reviewEls.navCount.textContent = pending ? String(pending) : '';
    reviewEls.navCount.classList.toggle('hidden', !pending);
  }

  reviewEls.body.innerHTML = filteredReviews()
    .map((review) => `
      <tr>
        <td>
          <div class="meta-stack">
            <strong>${escapeHtml(review.property_title || '-')}</strong>
            <span>Landlord: ${escapeHtml(review.landlord_name || '-')}</span>
            <span>${escapeHtml(review.landlord_phone || '')}</span>
          </div>
        </td>
        <td>
          <div class="meta-stack">
            <strong>${escapeHtml(review.reviewer_name)}</strong>
            <span>${escapeHtml(review.phone)}</span>
            <span>Stayed ${escapeHtml(reviewMonth(review.stay_from))} – ${escapeHtml(reviewMonth(review.stay_to))}</span>
          </div>
        </td>
        <td>
          <div class="meta-stack">
            ${Object.entries(reviewRatingLabels)
              .map(([key, label]) => `<span>${escapeHtml(label)}: <strong>${'★'.repeat(Number(review[key]))}${'☆'.repeat(5 - Number(review[key]))}</strong></span>`)
              .join('')}
          </div>
        </td>
        <td>
          <div class="meta-stack review-comment-cell">
            <span>${escapeHtml(review.comment)}</span>
            ${review.landlord_reply ? `<span class="hint-list">Landlord replied: ${escapeHtml(review.landlord_reply)}</span>` : ''}
            ${review.review_note ? `<span class="hint-list">Note: ${escapeHtml(review.review_note)}</span>` : ''}
          </div>
        </td>
        <td>${statusBadge(review.status)}<div class="meta-stack"><span>${escapeHtml(reviewStatusLabels[review.status] || review.status)}</span></div></td>
        <td>${formatDate(review.created_at)}</td>
        <td>
          <div class="row-actions">
            <button class="primary" type="button" data-review-decision="approved" data-id="${review.id}" ${review.status === 'approved' ? 'disabled' : ''}>Approve</button>
            <button class="danger" type="button" data-review-decision="rejected" data-id="${review.id}" ${review.status === 'rejected' ? 'disabled' : ''}>Reject</button>
          </div>
        </td>
      </tr>`)
    .join('') || '<tr><td class="empty-state" colspan="7">No reviews in this view.</td></tr>';
}

reviewEls.search?.addEventListener('input', debounce((event) => {
  reviewFilters.search = event.target.value;
  renderReviews();
}, 150));

reviewEls.status?.addEventListener('change', (event) => {
  reviewFilters.status = event.target.value;
  renderReviews();
});

reviewEls.body?.addEventListener('click', async (event) => {
  const button = event.target.closest('[data-review-decision]');
  if (!button) return;
  const approve = button.dataset.reviewDecision === 'approved';
  const note = await confirmAction({
    title: approve ? 'Publish this review?' : 'Reject this review?',
    message: approve
      ? 'Only publish once you are satisfied the reviewer stayed here. It will appear on the home page and count towards its rating.'
      : 'The review will not be shown. Add a reason for your records.',
    needsReason: true,
    confirmLabel: approve ? 'Publish' : 'Reject',
  });
  if (note === null) return;
  await runAction(
    () => api(`/api/admin/reviews/${button.dataset.id}`, {
      method: 'PATCH',
      body: JSON.stringify({ status: button.dataset.reviewDecision, note }),
    }),
    approve ? 'Review published.' : 'Review rejected.',
  );
});
