const partials = [
  ['loginMount', '/admin/partials/login.html'],
  ['sidebarMount', '/admin/partials/sidebar.html'],
  ['workspaceMount', '/admin/partials/overview.html'],
  ['workspaceMount', '/admin/partials/landlords.html', true],
  ['workspaceMount', '/admin/partials/properties.html', true],
  ['workspaceMount', '/admin/partials/payments.html', true],
  ['workspaceMount', '/admin/partials/roommates.html', true],
  ['workspaceMount', '/admin/partials/reviews.html', true],
  ['workspaceMount', '/admin/partials/reports.html', true],
  ['workspaceMount', '/admin/partials/logs.html', true],
  ['workspaceMount', '/admin/partials/accounts.html', true],
  ['modalMount', '/admin/partials/modals.html'],
  ['modalMount', '/admin/partials/payment-photo-modals.html', true],
];

const scripts = [
  '01-state.js',
  '02-core.js',
  '03-overview-landlords.js',
  '04-properties.js',
  '05-payments-logs.js',
  '06-accounts.js',
  '07-data-actions.js',
  '08-detail-helpers.js',
  '09-admin-stats-page.js',
  '10-details.js',
  '11-events-main.js',
  '12-form-events.js',
  '13-document-actions.js',
  '15-roommates.js', // tab modules must load before boot, which renders every tab
  '16-reviews.js',
  '17-reports.js',
  '14-boot.js',
];

async function loadPartials() {
  for (const [targetId, url, append] of partials) {
    const response = await fetch(url);
    const html = await response.text();
    const target = document.getElementById(targetId);
    if (append) {
      target.insertAdjacentHTML('beforeend', html);
    } else {
      target.innerHTML = html;
    }
  }
}

function loadScript(src) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = `/admin/js/${src}`;
    script.onload = resolve;
    script.onerror = reject;
    document.body.appendChild(script);
  });
}

async function startAdminApp() {
  await loadPartials();
  for (const script of scripts) {
    await loadScript(script);
  }
}

startAdminApp().catch((error) => {
  document.body.innerHTML = `<main class="shell"><div class="error-state">${error.message}</div></main>`;
});
