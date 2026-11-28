function renderAll() {
  renderAdminIdentity();
  renderStats();
  renderActivity();
  renderLandlords();
  renderProperties();
  renderPayments();
  renderLogs();
  renderAdminProfile();
  renderAdmins();
}

async function loadDashboard() {
  state.loading = true;
  setLoadingRows();
  try {
    const [stats, landlords, properties, payments, logs, profile, admins] = await Promise.all([
      api('/api/admin/stats'),
      api('/api/admin/landlords'),
      api('/api/admin/properties'),
      api('/api/admin/payments'),
      api('/api/admin/logs'),
      api('/api/admin/profile'),
      api('/api/admin/admins'),
    ]);

    state.data.stats = stats.stats || {};
    state.data.landlords = landlords.landlords || [];
    state.data.properties = properties.properties || [];
    state.data.payments = payments.payments || [];
    state.data.logs = logs.logs || [];
    state.data.profile = profile.admin || null;
    state.data.admins = admins.admins || [];
    renderAll();
  } catch (error) {
    if (/token|unauthorized|forbidden/i.test(error.message)) {
      logout();
      return;
    }
    els.landlordsBody.innerHTML = `<tr><td class="error-state" colspan="6">${escapeHtml(error.message)}</td></tr>`;
    els.propertiesBody.innerHTML = `<tr><td class="error-state" colspan="6">${escapeHtml(error.message)}</td></tr>`;
    els.paymentsBody.innerHTML = `<tr><td class="error-state" colspan="8">${escapeHtml(error.message)}</td></tr>`;
    els.logsBody.innerHTML = `<tr><td class="error-state" colspan="7">${escapeHtml(error.message)}</td></tr>`;
    showToast(error.message, 'error');
  } finally {
    state.loading = false;
  }
}

function setTab(tab) {
  state.activeTab = tab;
  document.querySelectorAll('[data-tab]').forEach((button) => {
    button.classList.toggle('active', button.dataset.tab === tab);
  });
  document.querySelectorAll('.view').forEach((panel) => {
    panel.classList.toggle('hidden', panel.id !== `${tab}Panel`);
  });
}

/**
 * Ask the admin to confirm. Resolves to null when cancelled; otherwise to the
 * typed reason, or, when `choice` is given, to `{ reason, choice }`.
 * choice: { label, options: [{ value, label }], value }
 */
function confirmAction({ title, message, needsReason = false, confirmLabel = 'Confirm', choice = null }) {
  els.confirmTitle.textContent = title;
  els.confirmMessage.textContent = message;
  els.confirmActionButton.textContent = confirmLabel;
  els.reasonField.classList.toggle('hidden', !needsReason);
  els.reasonInput.value = '';
  els.choiceField.classList.toggle('hidden', !choice);
  if (choice) {
    els.choiceLabel.textContent = choice.label;
    els.choiceInput.innerHTML = choice.options
      .map((option) => `<option value="${escapeHtml(option.value)}">${escapeHtml(option.label)}</option>`)
      .join('');
    els.choiceInput.value = choice.value ?? choice.options[0]?.value ?? '';
  }
  // Closing with Esc keeps the previous returnValue, which would replay an
  // earlier "confirm" for a cancelled action; reset it every time.
  els.confirmModal.returnValue = '';
  els.confirmModal.showModal();

  return new Promise((resolve) => {
    els.confirmModal.addEventListener(
      'close',
      () => {
        if (els.confirmModal.returnValue !== 'confirm') return resolve(null);
        const reason = els.reasonInput.value.trim();
        resolve(choice ? { reason, choice: els.choiceInput.value } : reason);
      },
      { once: true },
    );
  });
}

async function runAction(task, successMessage) {
  if (state.actionBusy) return;
  state.actionBusy = true;
  document.querySelectorAll('.row-actions button').forEach((button) => {
    button.disabled = true;
  });
  try {
    await task();
    await loadDashboard();
    showToast(successMessage);
  } catch (error) {
    showToast(error.message, 'error');
    renderAll();
  } finally {
    state.actionBusy = false;
  }
}

