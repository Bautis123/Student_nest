async function showDetail(type, id) {
  let rows = [];
  let extraContent = '';
  if (type === 'landlord') {
    const landlord = state.data.landlords.find((item) => String(item.id) === String(id));
    if (!landlord) return;
    els.detailTitle.textContent = landlord.full_name || 'Landlord details';
    rows = [
      ['Phone', landlord.phone],
      ['Email', landlord.email],
      ['Status', statusFromApproval(landlord)],
      ['Properties', landlordPropertyCount(landlord.id)],
      ['Joined', formatDate(landlord.created_at)],
      ['Approval history', 'Basic approval state only. Add backend audit fields to store full history.'],
    ];
  }

  if (type === 'property') {
    const property = state.data.properties.find((item) => String(item.id) === String(id));
    if (!property) return;
    els.detailTitle.textContent = property.title || 'Property details';
    rows = [
      ['Landlord', property.landlord_name],
      ['Phone', property.landlord_phone],
      ['School', property.school_name],
      ['Address', property.address],
      ['Rooms', Number(property.room_types || 0)],
      ['Photos', Number(property.photo_count || 0)],
      ['Verified', property.verified_at ? formatDate(property.verified_at) : 'Not verified'],
      ['Listing expiry', formatDate(property.listing_expires_at)],
      ['Expiry countdown', expiryInfo(property).countdown],
      ['Moderation hints', propertyHints(property).join(', ') || 'Ready for review'],
      ['Approval notes', 'Not stored by current backend schema.'],
    ];
    activePhotos = Array.isArray(property.photos) ? property.photos : [];
    extraContent = propertyPhotoGallery(property);
  }

  if (type === 'payment') {
    const payment = state.data.payments.find((item) => String(item.id) === String(id));
    if (!payment) return;
    els.detailTitle.textContent = `Payment ${payment.payment_reference || payment.id}`;
    rows = [
      ['Landlord', payment.landlord_name],
      ['Property', payment.property_title],
      ['Amount', money.format(Number(payment.amount || 0))],
      ['Method', paymentMethodLabel(payment)],
      ['Reference', payment.payment_reference],
      ['Status', payment.status],
      ['Paid at', formatDate(payment.paid_at || payment.created_at)],
      ['Payment expiry', formatDate(payment.expires_at)],
      ['Recorded by', payment.provider ? `Landlord paid in the app (${payment.provider})` : 'Admin (manual record)'],
      ...(payment.provider
        ? [
            ['Plan', payment.plan || '-'],
            ['Paying number', payment.phone || '-'],
            ['Provider reference', payment.provider_reference || '-'],
            ['Failure reason', payment.failure_reason || '-'],
          ]
        : []),
    ];
  }

  if (type === 'log') {
    const log = state.data.logs.find((item) => String(item.id) === String(id));
    if (!log) return;
    els.detailTitle.textContent = actionLabel(log.action);
    rows = [
      ['Time', `${formatDate(log.created_at)} ${new Date(log.created_at).toLocaleTimeString('en-ZM')}`],
      ['Admin', log.admin_name || log.admin_id || 'Admin'],
      ['Action', actionLabel(log.action)],
      ['Entity type', log.entity_type],
      ['Entity ID', log.entity_id],
      ['Status', log.status],
      ['Message', log.message],
      ['IP address', log.ip_address],
      ['User agent', log.user_agent],
      ['Metadata', JSON.stringify(log.metadata || {}, null, 2)],
    ];
  }

  if (type === 'admin') {
    try {
      els.detailTitle.textContent = 'Loading admin profile...';
      els.detailContent.innerHTML = '<div class="loading-state">Loading admin stats...</div>';
      els.detailModal.showModal();

      const result = await api(`/api/admin/admins/${id}/details`);
      const admin = result.admin;
      const stats = result.stats || {};
      els.detailTitle.textContent = admin.full_name || 'Admin profile';

      rows = [
        ['Access level', admin.access_level === 'owner' ? 'Owner / full access' : 'Manager access'],
        ['Phone', admin.phone],
        ['Email', admin.email],
        ['Status', admin.is_approved ? 'Approved' : 'Pending'],
        ['Created', formatDate(admin.created_at)],
        ['Total actions', stats.total_actions || 0],
      ];

      extraContent = `
        <section class="admin-stats-grid">
          <div>
            <h3>Actions</h3>
            ${statList(stats.action_breakdown, 'action')}
          </div>
          <div>
            <h3>Entities</h3>
            ${statList(stats.entity_breakdown, 'entity_type')}
          </div>
        </section>
        <section class="photo-section">
          <h3>Recent activity</h3>
          ${recentAdminActions(stats.recent_actions)}
        </section>
      `;
    } catch (error) {
      els.detailTitle.textContent = 'Admin profile unavailable';
      els.detailContent.innerHTML = `<div class="error-state">${escapeHtml(error.message)}</div>`;
      return;
    }
  }

  els.detailContent.innerHTML = `${detailRows(rows)}${extraContent}`;
  if (!els.detailModal.open) {
    els.detailModal.showModal();
  }
}

