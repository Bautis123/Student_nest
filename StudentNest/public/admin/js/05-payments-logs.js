function filteredPayments() {
  const { search, status } = state.filters.payments;
  return state.data.payments.filter((payment) => {
    const haystack = `${payment.landlord_name || ''} ${payment.property_title || ''} ${payment.payment_method || ''} ${payment.payment_reference || ''}`.toLowerCase();
    const paymentStatus = payment.status || 'pending';
    return haystack.includes(search.toLowerCase()) && (status === 'all' || paymentStatus === status);
  });
}

function renderPayments() {
  const payments = filteredPayments();
  els.paymentsBody.innerHTML =
    payments
      .map(
        (payment) => `
          <tr>
            <td>${escapeHtml(payment.landlord_name || '-')}</td>
            <td>${escapeHtml(payment.property_title || '-')}</td>
            <td>${money.format(Number(payment.amount || 0))}</td>
            <td>${escapeHtml(paymentMethodLabel(payment))}</td>
            <td>${escapeHtml(payment.payment_reference || '-')}</td>
            <td>${paymentBadge(payment.status)}</td>
            <td>${formatDate(payment.paid_at || payment.created_at)}</td>
            <td>
              <div class="row-actions">
                <button class="primary" type="button" data-detail="payment" data-id="${payment.id}">View</button>
                <button type="button" disabled>Verify</button>
              </div>
            </td>
          </tr>
        `,
      )
      .join('') || '<tr><td class="empty-state" colspan="8">No payments match this view.</td></tr>';
}

function paymentMethodLabel(payment) {
  if (payment.payment_method !== 'mobile_money') {
    if (payment.payment_method === 'bank_transfer') {
      return payment.bank_name ? `Bank transfer · ${payment.bank_name}` : 'Bank transfer';
    }
    return payment.payment_method || '-';
  }
  const providers = {
    mtn: 'MTN Mobile Money',
    airtel: 'Airtel Money',
    zamtel: 'Zamtel Kwacha',
  };
  return providers[payment.mobile_money_provider] || 'Mobile money';
}

function actionLabel(action) {
  return String(action || '')
    .split('_')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function filteredLogs() {
  const { search, action, entityType, status, dateFrom, dateTo } = state.filters.logs;
  return state.data.logs.filter((log) => {
    const haystack = `${log.action || ''} ${log.entity_type || ''} ${log.entity_id || ''} ${log.message || ''} ${log.admin_name || ''} ${JSON.stringify(log.metadata || {})}`.toLowerCase();
    const logDate = log.created_at ? new Date(log.created_at) : null;
    const matchesSearch = haystack.includes(search.toLowerCase());
    const matchesAction = action === 'all' || log.action === action;
    const matchesEntity = entityType === 'all' || log.entity_type === entityType;
    const matchesStatus = status === 'all' || log.status === status;
    const matchesFrom = !dateFrom || (logDate && logDate >= new Date(dateFrom));
    const matchesTo =
      !dateTo ||
      (logDate &&
        logDate < new Date(new Date(dateTo).getTime() + 24 * 60 * 60 * 1000));
    return matchesSearch && matchesAction && matchesEntity && matchesStatus && matchesFrom && matchesTo;
  });
}

function renderLogs() {
  const logs = filteredLogs();
  els.logsBody.innerHTML =
    logs
      .map(
        (log) => `
          <tr>
            <td>
              <div class="meta-stack">
                <strong>${formatDate(log.created_at)}</strong>
                <span>${new Date(log.created_at).toLocaleTimeString('en-ZM', { hour: '2-digit', minute: '2-digit' })}</span>
              </div>
            </td>
            <td>
              <div class="meta-stack">
                <strong>${escapeHtml(log.admin_name || 'Admin')}</strong>
                <span>${escapeHtml(log.admin_phone || log.admin_id || '-')}</span>
              </div>
            </td>
            <td>${escapeHtml(actionLabel(log.action))}</td>
            <td>
              <div class="meta-stack">
                <strong>${escapeHtml(log.entity_type)}</strong>
                <span>${escapeHtml(log.entity_id || '-')}</span>
              </div>
            </td>
            <td>${escapeHtml(log.message || '-')}</td>
            <td>${statusBadge(log.status || 'success')}</td>
            <td>
              <div class="row-actions">
                <button class="primary" type="button" data-detail="log" data-id="${log.id}">View</button>
              </div>
            </td>
          </tr>
        `,
      )
      .join('') || '<tr><td class="empty-state" colspan="7">No logs match this view.</td></tr>';
}

