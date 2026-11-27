function filteredProperties() {
  const { search, status, sort } = state.filters.properties;
  const filtered = state.data.properties.filter((property) => {
    const haystack = `${property.title || ''} ${property.address || ''} ${property.landlord_name || ''} ${property.school_name || ''}`.toLowerCase();
    const matchesSearch = haystack.includes(search.toLowerCase());
    const propertyStatus = !property.is_active ? 'inactive' : statusFromApproval(property);
    return matchesSearch && (status === 'all' || propertyStatus === status);
  });

  return filtered.sort((a, b) => {
    if (sort === 'oldest') return new Date(a.created_at || 0) - new Date(b.created_at || 0);
    if (sort === 'updated') return new Date(b.updated_at || b.created_at || 0) - new Date(a.updated_at || a.created_at || 0);
    return new Date(b.created_at || 0) - new Date(a.created_at || 0);
  });
}

function renderProperties() {
  const properties = filteredProperties();
  els.propertiesBody.innerHTML =
    properties
      .map((property) => {
        const status = !property.is_active ? 'inactive' : statusFromApproval(property);
        const hints = propertyHints(property);
        const expiry = expiryInfo(property);
        return `
          <tr>
            <td>
              <div class="meta-stack">
                <strong>${escapeHtml(property.title)}</strong>
                <span>${escapeHtml(property.address || 'No address')}</span>
              </div>
            </td>
            <td>
              <div class="meta-stack">
                <strong>${escapeHtml(property.landlord_name || '-')}</strong>
                <span>${escapeHtml(property.landlord_phone || '')}</span>
              </div>
            </td>
            <td>
              <div class="meta-stack">
                <strong>${Number(property.room_types || 0)} rooms · ${Number(property.photo_count || 0)} photos</strong>
                <span class="hint-list">${hints.length ? escapeHtml(hints.join(', ')) : 'Ready for review'}</span>
              </div>
            </td>
            <td>
              <div class="meta-stack">
                ${statusBadge(status)}
                ${property.verified_at ? '<span class="badge verified" title="Inspected or ownership checked by an admin">Verified</span>' : ''}
              </div>
            </td>
            <td>
              <div class="meta-stack">
                ${statusBadge(expiry.status)}
                <span>${escapeHtml(expiry.countdown)}</span>
                <span>${escapeHtml(formatDate(property.listing_expires_at))}</span>
              </div>
            </td>
            <td>${formatDate(property.updated_at || property.created_at)}</td>
            <td>
              <div class="row-actions">
                <button class="primary" type="button" data-detail="property" data-id="${property.id}">View</button>
                <button type="button" data-property-status="${property.id}" data-approved="true" ${property.is_approved ? 'disabled' : ''}>Approve</button>
                <button class="danger" type="button" data-property-status="${property.id}" data-approved="false" ${!property.is_approved ? 'disabled' : ''}>Reject</button>
                ${property.verified_at
                  ? `<button type="button" data-property-verify="${property.id}" data-verified="false">Unverify</button>`
                  : `<button type="button" data-property-verify="${property.id}" data-verified="true" ${!property.is_approved ? 'disabled title="Approve before verifying"' : ''}>Verify</button>`}
                <button class="danger" type="button" data-delete-property="${property.id}">Delete</button>
              </div>
            </td>
          </tr>
        `;
      })
      .join('') || '<tr><td class="empty-state" colspan="6">No properties match this view.</td></tr>';
}

function startCountdownTimer() {
  clearInterval(countdownTimer);
  countdownTimer = setInterval(() => {
    if (state.activeTab === 'properties') {
      renderProperties();
    }
  }, 60 * 1000);
}

