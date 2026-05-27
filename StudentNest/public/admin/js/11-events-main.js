function logout() {
  state.token = '';
  state.user = null;
  localStorage.removeItem('studentNestAdminToken');
  localStorage.removeItem('studentNestAdminUser');
  showLogin();
}

els.loginForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  els.loginMessage.textContent = '';

  const formData = new FormData(event.currentTarget);
  try {
    const result = await api('/api/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        phone: formData.get('phone'),
        password: formData.get('password'),
      }),
    });

    if (result.user.role !== 'admin') {
      els.loginMessage.textContent = 'This account is not an admin account.';
      return;
    }

    state.token = result.token;
    state.user = result.user;
    localStorage.setItem('studentNestAdminToken', result.token);
    localStorage.setItem('studentNestAdminUser', JSON.stringify(result.user));
    showDashboard();
    setTab('overview');
    await loadDashboard();
    startCountdownTimer();
  } catch (error) {
    els.loginMessage.textContent = error.message;
  }
});

els.loginSubmitButton.addEventListener('click', () => {
  els.loginForm.requestSubmit();
});

els.logoutButton.addEventListener('click', logout);
els.closeDetailButton.addEventListener('click', () => els.detailModal.close());
els.adminMiniProfile.addEventListener('click', async () => {
  if (!els.adminMiniProfile.dataset.adminStats) return;
  await openAdminStatsPage(els.adminMiniProfile.dataset.adminStats);
});
els.editProfileButton.addEventListener('click', () => {
  const admin = state.data.profile || {};
  els.profileNameInput.value = admin.full_name || '';
  els.profileEmailInput.value = admin.email || '';
  els.profileModal.showModal();
});
els.closeProfileModal.addEventListener('click', () => els.profileModal.close());
els.cancelProfileButton.addEventListener('click', () => els.profileModal.close());
els.createAdminButton.addEventListener('click', () => els.adminAccountModal.showModal());
els.closeAdminAccountModal.addEventListener('click', () => els.adminAccountModal.close());
els.cancelAdminAccountButton.addEventListener('click', () => els.adminAccountModal.close());
els.recordPaymentButton.addEventListener('click', openPaymentModal);
els.closePaymentModal.addEventListener('click', () => els.paymentModal.close());
els.cancelPaymentButton.addEventListener('click', () => els.paymentModal.close());
els.paymentLandlordInput.addEventListener('change', populatePaymentForm);
els.paymentMethodInput.addEventListener('change', updatePaymentMethodFields);
els.closePhotoViewer.addEventListener('click', () => els.photoViewer.close());
els.prevPhotoButton.addEventListener('click', () => showPhotoAt(activePhotoIndex - 1));
els.nextPhotoButton.addEventListener('click', () => showPhotoAt(activePhotoIndex + 1));

function showPhotoAt(index) {
  if (activePhotos.length === 0) return;
  activePhotoIndex = (index + activePhotos.length) % activePhotos.length;
  const photo = activePhotos[activePhotoIndex];
  els.photoViewerImage.src = photo.url;
  els.photoViewerCaption.textContent = `Photo ${activePhotoIndex + 1} of ${activePhotos.length}${photo.is_cover ? ' Â· Cover photo' : ''}`;
  if (!els.photoViewer.open) {
    els.photoViewer.showModal();
  }
}

els.landlordSearch.addEventListener('input', debounce((event) => {
  state.filters.landlords.search = event.target.value;
  renderLandlords();
}));
els.landlordStatusFilter.addEventListener('change', (event) => {
  state.filters.landlords.status = event.target.value;
  renderLandlords();
});
els.propertySearch.addEventListener('input', debounce((event) => {
  state.filters.properties.search = event.target.value;
  renderProperties();
}));
els.propertyStatusFilter.addEventListener('change', (event) => {
  state.filters.properties.status = event.target.value;
  renderProperties();
});
els.propertySort.addEventListener('change', (event) => {
  state.filters.properties.sort = event.target.value;
  renderProperties();
});
els.paymentSearch.addEventListener('input', debounce((event) => {
  state.filters.payments.search = event.target.value;
  renderPayments();
}));
els.paymentStatusFilter.addEventListener('change', (event) => {
  state.filters.payments.status = event.target.value;
  renderPayments();
});
els.logSearch.addEventListener('input', debounce((event) => {
  state.filters.logs.search = event.target.value;
  renderLogs();
}));
els.logActionFilter.addEventListener('change', (event) => {
  state.filters.logs.action = event.target.value;
  renderLogs();
});
els.logEntityFilter.addEventListener('change', (event) => {
  state.filters.logs.entityType = event.target.value;
  renderLogs();
});
els.logStatusFilter.addEventListener('change', (event) => {
  state.filters.logs.status = event.target.value;
  renderLogs();
});
els.logDateFrom.addEventListener('change', (event) => {
  state.filters.logs.dateFrom = event.target.value;
  renderLogs();
});
els.logDateTo.addEventListener('change', (event) => {
  state.filters.logs.dateTo = event.target.value;
  renderLogs();
});
els.clearLogFiltersButton.addEventListener('click', () => {
  state.filters.logs = {
    search: '',
    action: 'all',
    entityType: 'all',
    status: 'all',
    dateFrom: '',
    dateTo: '',
  };
  els.logSearch.value = '';
  els.logActionFilter.value = 'all';
  els.logEntityFilter.value = 'all';
  els.logStatusFilter.value = 'all';
  els.logDateFrom.value = '';
  els.logDateTo.value = '';
  renderLogs();
});

