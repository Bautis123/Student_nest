function adminInitials(admin) {
  return String(admin?.full_name || 'Admin')
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part.charAt(0).toUpperCase())
    .join('') || 'A';
}

function renderAdminIdentity() {
  const admin = state.data.profile || state.user || {};
  els.adminMiniProfile.innerHTML = `
    <div class="admin-avatar">${escapeHtml(adminInitials(admin))}</div>
    <div>
      <strong>${escapeHtml(admin.full_name || 'Admin')}</strong>
      <span>${escapeHtml(admin.phone || admin.email || 'Signed in')}</span>
    </div>
  `;
  els.adminMiniProfile.dataset.adminStats = admin.id || '';
  els.adminWelcomeText.textContent = `Welcome back${admin.full_name ? `, ${admin.full_name}` : ''}. Review platform health, approvals, listings, payments, and audit history.`;
}

function renderAdminProfile() {
  const admin = state.data.profile;
  if (!admin) {
    els.adminProfileCard.innerHTML = '<div class="empty-state">Profile not loaded.</div>';
    return;
  }

  els.adminProfileCard.innerHTML = `
    <div class="profile-hero">
      <div class="admin-avatar large">${escapeHtml(adminInitials(admin))}</div>
      <div>
        <h3>${escapeHtml(admin.full_name || 'Admin')}</h3>
        <p class="muted">${escapeHtml(admin.role || 'admin')}</p>
      </div>
    </div>
    <div class="detail-grid">
      <div class="detail-row"><span>Phone</span><strong>${escapeHtml(admin.phone || '-')}</strong></div>
      <div class="detail-row"><span>Email</span><strong>${escapeHtml(admin.email || '-')}</strong></div>
      <div class="detail-row"><span>Admin ID</span><strong>${escapeHtml(admin.id)}</strong></div>
      <div class="detail-row"><span>Created</span><strong>${formatDate(admin.created_at)}</strong></div>
    </div>
  `;
}

function renderAdmins() {
  const currentAdminId = state.data.profile?.id || state.user?.id;
  const canManageAdmins = state.data.profile?.access_level === 'owner';
  els.adminsBody.innerHTML =
    state.data.admins
      .map((admin) => {
        const isCurrentAdmin = String(admin.id) === String(currentAdminId);
        const isOwnerAdmin = admin.access_level === 'owner';
        return `
          <button class="admin-account-card" type="button" data-admin-stats="${admin.id}" ${!canManageAdmins && !isCurrentAdmin ? 'disabled' : ''}>
            <div class="admin-avatar">${escapeHtml(adminInitials(admin))}</div>
            <div class="meta-stack admin-account-main">
              <strong>${escapeHtml(admin.full_name || 'Admin')}</strong>
              <span>${isCurrentAdmin ? 'You' : 'Admin account'}</span>
            </div>
            <div class="meta-stack admin-contact">
              <strong>${escapeHtml(admin.phone || '-')}</strong>
              <span>${escapeHtml(admin.email || 'No email')}</span>
            </div>
            <div class="admin-card-badges">
              ${statusBadge(admin.access_level === 'owner' ? 'owner' : 'manager')}
              ${statusBadge(admin.is_approved ? 'approved' : 'pending')}
              <span class="muted small">Created ${formatDate(admin.created_at)}</span>
            </div>
            <div class="row-actions admin-card-actions">
              ${
                canManageAdmins && !isCurrentAdmin
                  ? `<span data-admin-access="${admin.id}" data-access="${isOwnerAdmin ? 'manager' : 'owner'}">${isOwnerAdmin ? 'Make manager' : 'Give full access'}</span>`
                  : ''
              }
              ${
                canManageAdmins && !isOwnerAdmin
                  ? `<span class="danger" data-delete-admin="${admin.id}">Delete</span>`
                  : ''
              }
            </div>
          </button>
        `;
      })
      .join('') || '<div class="empty-state">No admin accounts found.</div>';
}

function updatePaymentMethodFields() {
  const method = els.paymentMethodInput.value;
  const isMobileMoney = method === 'mobile_money';
  const isBankTransfer = method === 'bank_transfer';
  const needsReference = method !== 'cash';

  els.mobileProviderField.classList.toggle('hidden', !isMobileMoney);
  els.bankNameField.classList.toggle('hidden', !isBankTransfer);
  els.paymentReferenceField.classList.toggle('hidden', !needsReference);
  els.paymentReferenceInput.required = needsReference;

  if (isMobileMoney) {
    els.paymentReferenceInput.placeholder = 'MTN/Airtel/Zamtel transaction reference';
  } else if (isBankTransfer) {
    els.paymentReferenceInput.placeholder = 'Bank deposit or transfer reference';
  } else {
    els.paymentReferenceInput.value = '';
  }
}

function populatePaymentForm() {
  const previousPropertyId = els.paymentPropertyInput.value;
  els.paymentLandlordInput.innerHTML = state.data.landlords
    .map(
      (landlord) =>
        `<option value="${landlord.id}">${escapeHtml(landlord.full_name)} · ${escapeHtml(landlord.phone)}</option>`,
    )
    .join('');

  const selectedLandlordId = els.paymentLandlordInput.value;
  const properties = state.data.properties.filter((property) => {
    if (!selectedLandlordId) return true;
    return String(property.landlord_id) === String(selectedLandlordId);
  });

  els.paymentPropertyInput.innerHTML = properties
    .map(
      (property) =>
        `<option value="${property.id}">${escapeHtml(property.title)} · ${escapeHtml(property.address || 'No address')}</option>`,
    )
    .join('');

  if (properties.some((property) => String(property.id) === previousPropertyId)) {
    els.paymentPropertyInput.value = previousPropertyId;
  }
}

function openPaymentModal() {
  populatePaymentForm();
  updatePaymentMethodFields();
  if (!els.paymentLandlordInput.value || !els.paymentPropertyInput.value) {
    showToast('Add a landlord and property before recording a payment.', 'error');
    return;
  }
  els.paymentModal.showModal();
}

