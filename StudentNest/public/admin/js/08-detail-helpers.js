function detailRows(rows) {
  return `<div class="detail-grid">${rows
    .map(
      ([label, value]) => `
        <div class="detail-row">
          <span>${escapeHtml(label)}</span>
          <strong>${escapeHtml(value || '-')}</strong>
        </div>
      `,
    )
    .join('')}</div>`;
}

function propertyPhotoGallery(property) {
  const photos = Array.isArray(property.photos) ? property.photos : [];
  if (photos.length === 0) {
    return `
      <section class="photo-section">
        <h3>Listing photos</h3>
        <div class="empty-photo-state">No photos have been uploaded for this listing.</div>
      </section>
    `;
  }

  return `
    <section class="photo-section">
      <h3>Listing photos</h3>
      <div class="photo-grid">
        ${photos
          .map(
            (photo) => `
              <figure class="photo-tile">
                <button type="button" data-photo-index="${photos.indexOf(photo)}" aria-label="View listing photo full screen">
                  <img src="${escapeHtml(photo.url)}" alt="Listing photo" loading="lazy" />
                </button>
                ${photo.is_cover ? '<figcaption>Cover photo</figcaption>' : ''}
              </figure>
            `,
          )
          .join('')}
      </div>
    </section>
  `;
}

function statList(items, labelKey) {
  if (!items || items.length === 0) {
    return '<div class="empty-state">No activity yet.</div>';
  }

  return `
    <div class="stat-list">
      ${items
        .map(
          (item) => `
            <div class="stat-list-item">
              <strong>${escapeHtml(actionLabel(item[labelKey]))}</strong>
              <span>${escapeHtml(item.count)}</span>
            </div>
          `,
        )
        .join('')}
    </div>
  `;
}

function recentAdminActions(actions) {
  if (!actions || actions.length === 0) {
    return '<div class="empty-state">No recent admin actions.</div>';
  }

  return `
    <div class="activity-list compact-list">
      ${actions
        .map(
          (action) => `
            <article class="activity-item">
              <strong>${escapeHtml(actionLabel(action.action))}</strong>
              <span>${escapeHtml(action.message || action.entity_type || '')} · ${formatDate(action.created_at)}</span>
            </article>
          `,
        )
        .join('')}
    </div>
  `;
}

function adminSummaryCards(stats) {
  const cards = [
    ['Total actions recorded', stats.total_actions || 0],
    ['Payments recorded', stats.payments_recorded || 0],
    ['Listings approved', stats.properties_approved || 0],
    ['Listings rejected', stats.properties_rejected || 0],
    ['Landlords approved', stats.landlords_approved || 0],
    ['Landlords suspended', stats.landlords_suspended || 0],
    ['High-impact actions', stats.destructive_actions || 0],
  ];

  return `
    <section class="stats-grid admin-summary-grid">
      ${cards
        .map(
          ([label, value]) => `
            <article class="stat-card">
              <div class="stat-label">${escapeHtml(label)}</div>
              <div class="stat-value">${escapeHtml(value)}</div>
            </article>
          `,
        )
        .join('')}
    </section>
  `;
}

function dailyActivityList(items) {
  if (!items || items.length === 0) {
    return '<div class="empty-state">No activity in the last 30 days.</div>';
  }

  return `
    <div class="stat-list">
      ${items
        .map(
          (item) => `
            <div class="stat-list-item">
              <strong>${formatDate(item.day)}</strong>
              <span>${escapeHtml(item.count)} action${Number(item.count) === 1 ? '' : 's'}</span>
            </div>
          `,
        )
        .join('')}
    </div>
  `;
}

