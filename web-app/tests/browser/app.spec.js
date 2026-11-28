import { test, expect } from '@playwright/test';

const home = { id: 'home-1', title: 'Garden View Student Lodge', address: 'Kalundu, Lusaka', nearest_school_id: 'unza', school_name: 'UNZA', min_price: '950', distance_from_school: '1.2', available_spaces_count: 4, total_rooms_count: 2, available_rooms_count: 2, is_approved: true, is_active: true, is_verified: true, landlord_name: 'Jane Banda', landlord_phone: '0971234567', latitude: -15.39, longitude: 28.33, amenities: { wifi: true }, rooms: [{ id: 'room-1', room_type: 'Double sharing', price_per_month: 950, students_per_room: 2, total_rooms: 2, available_rooms: 2 }], photos: [] };
test.beforeEach(async ({ page }) => {
  await page.route('https://fonts.googleapis.com/**', route => route.abort());
  await page.route('**/api/**', async route => {
    const path = new URL(route.request().url()).pathname;
    let data = {};
    if (path === '/api/properties/schools') data = { schools: [{ id: 'unza', name: 'UNZA' }, { id: 'cbu', name: 'Copperbelt University' }] };
    else if (path === '/api/auth/login') data = { token: 'test-session', user: { id: 'landlord', full_name: 'Jane Banda', role: 'landlord' } };
    else if (path === '/api/auth/register') data = { message: 'Await approval', user: { is_approved: false } };
    else if (path === '/api/properties/landlord/my-properties') data = { properties: [home] };
    else if (path.includes('/properties/landlord/my-properties/')) data = { property: home };
    else if (path === '/api/properties/home-1') data = { property: home };
    else if (path === '/api/properties') data = route.request().method() === 'POST' ? { property: home } : { properties: [home, { ...home, id: 'home-2', title: 'Riverside Student House', address: 'Riverside, Kitwe', nearest_school_id: 'cbu', school_name: 'Copperbelt University', min_price: '600', is_verified: false }] };
    await route.fulfill({ json: data });
  });
});

test('students can search, filter, save and open a real detail route', async ({ page }) => {
  await page.goto('/');
  await expect(page.getByRole('heading', { name: /Big dreams/ })).toBeVisible();
  await expect(page.locator('.property-card')).toHaveCount(2);
  await page.getByRole('combobox', { name: 'Campus', exact: true }).selectOption('unza');
  await expect(page.locator('.property-card')).toHaveCount(1);
  await page.getByRole('button', { name: 'Save Garden View Student Lodge', exact: true }).click();
  await page.goto('/saved');
  await expect(page.locator('.property-card')).toHaveCount(1);
  await page.getByRole('link', { name: 'Garden View Student Lodge', exact: true }).click();
  await expect(page.getByRole('heading', { name: home.title })).toBeVisible();
  await expect(page.getByRole('link', { name: 'Chat on WhatsApp' })).toHaveAttribute('href', 'https://wa.me/260971234567');
  await expect(page.getByRole('heading', { name: 'Double sharing' })).toBeVisible();
  await page.reload();
  await expect(page.getByRole('heading', { name: home.title })).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
});

test('verified homes show a badge and can be filtered', async ({ page }) => {
  await page.goto('/');
  await expect(page.locator('.property-card .verified-badge')).toHaveCount(1);
  await page.getByRole('button', { name: 'Filters' }).click();
  await page.getByRole('checkbox', { name: 'Verified homes only' }).check();
  await expect(page.locator('.property-card')).toHaveCount(1);
  await expect(page).toHaveURL(/verified=1/);
  await page.getByRole('link', { name: 'Garden View Student Lodge', exact: true }).click();
  await expect(page.locator('.verified-note')).toContainText('inspected this home');
});

test('map view pins homes and leads to travel times on the home page', async ({ page }) => {
  await page.route('https://*.tile.openstreetmap.org/**', route => route.abort()); // keep tests offline
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/');
  await expect(page.locator('.property-card').first()).toContainText('~20 min walk to campus');
  await page.getByRole('button', { name: 'Map', exact: true }).click();
  await expect(page).toHaveURL(/view=map/);
  await expect(page.locator('.map-pin')).toHaveCount(2);
  await page.getByRole('combobox', { name: 'Campus', exact: true }).selectOption('unza');
  await expect(page.locator('.map-pin')).toHaveCount(1);
  await page.locator('.map-pin').first().click();
  await page.locator('.map-popup').getByRole('link', { name: /View home/ }).click();
  await expect(page.getByRole('heading', { name: 'Getting to UNZA' })).toBeVisible();
  await expect(page.locator('.travel-grid')).toContainText('~20 min');
  await expect(page.locator('.detail-map')).toBeVisible();
  await page.getByRole('link', { name: 'All homes' }).click();
  await page.getByRole('button', { name: 'List', exact: true }).click();
  await expect(page.locator('.property-card')).toHaveCount(2);
  expect(errors).toEqual([]);
});

test('students browse roommate requests, reveal WhatsApp and post their own', async ({ page }) => {
  const post = { id: 'rm-1', display_name: 'Chanda', share_with: 'any', school_name: 'UNZA', budget_max: '750.00', about: 'Final-year engineering student.', tags: ['early_riser', 'cooks'] };
  const token = 'a'.repeat(43);
  let created;
  await page.route('**/api/roommates**', async route => {
    const url = new URL(route.request().url());
    if (url.pathname === '/api/roommates' && route.request().method() === 'POST') { created = route.request().postDataJSON(); return route.fulfill({ status: 201, json: { post: { id: 'rm-2', status: 'pending' }, manage_token: token } }); }
    if (url.pathname === '/api/roommates') return route.fulfill({ json: { posts: [post] } });
    if (url.pathname.endsWith('/contact')) return route.fulfill({ json: { phone: '0961234567', whatsapp: 'https://wa.me/260961234567' } });
    return route.fulfill({ status: 404, json: { message: 'Not found' } });
  });
  await page.goto('/roommates');
  await expect(page.getByRole('heading', { name: 'Chanda' })).toBeVisible();
  await expect(page.getByText('0961234567')).toHaveCount(0);
  await page.getByRole('button', { name: 'Show WhatsApp' }).click();
  await expect(page.getByRole('link', { name: /WhatsApp 0961234567/ })).toHaveAttribute('href', 'https://wa.me/260961234567');

  await page.getByRole('link', { name: 'Post a request' }).click();
  await page.getByLabel('First name').fill('Bwalya');
  await page.getByLabel('Campus').selectOption('unza');
  await page.getByLabel('I am').selectOption('female');
  await page.getByLabel('I’d share with').selectOption('female');
  await page.getByLabel('Budget (K/month)').fill('850');
  await page.getByText('Quiet', { exact: true }).click();
  await page.getByLabel('WhatsApp number').fill('0771234560');
  await page.getByRole('button', { name: 'Send for review' }).click();
  await expect(page.getByRole('heading', { name: 'Request sent for review' })).toBeVisible();
  await expect(page.locator('.manage-link code')).toContainText(`/roommates/manage/${token}`);
  expect(created).toMatchObject({ display_name: 'Bwalya', school_id: 'unza', gender: 'female', share_with: 'female', budget_max: 850, tags: ['quiet'], phone: '0771234560' });
});

test('the private manage page keeps the saved campus even though campuses load later', async ({ page }) => {
  const token = 'b'.repeat(43);
  await page.route('**/api/properties/schools', async route => { await new Promise(r => setTimeout(r, 600)); return route.fulfill({ json: { schools: [{ id: 'cbu', name: 'Copperbelt University' }, { id: 'unza', name: 'UNZA' }] } }); });
  await page.route(`**/api/roommates/manage/${token}`, route => route.fulfill({ json: { post: { id: 'rm-3', display_name: 'Bwalya', gender: 'female', share_with: 'female', school_id: 'unza', budget_max: '850.00', tags: ['quiet'], phone: '0771234560', status: 'pending' } } }));
  await page.goto(`/roommates/manage/${token}`);
  await expect(page.getByRole('heading', { name: 'Hi Bwalya.' })).toBeVisible();
  await expect(page.getByText('Waiting for review')).toBeVisible();
  await expect(page.getByLabel('Campus').locator('option', { hasText: 'UNZA' })).toBeAttached();
  await expect(page.getByLabel('Campus')).toHaveValue('unza');
});

test('students see tenant reviews and can submit their own', async ({ page }) => {
  const summary = { count: 2, rating_overall: 4.5, rating_landlord: 5, rating_utilities: 4, rating_security: 4, rating_value: 4.5 };
  const reviews = [{ id: 'rv-1', reviewer_name: 'Mutale', stay_from: '2025-01-01', stay_to: '2025-12-01', rating_overall: 4, comment: 'Water was reliable and the landlord fixed things quickly.', landlord_reply: 'Thank you Mutale!' }];
  let submitted;
  await page.route('**/api/properties', route => route.fulfill({ json: { properties: [{ ...home, rating_average: 4.5, review_count: 2 }] } }));
  await page.route('**/api/reviews**', async route => {
    if (route.request().method() === 'POST') { submitted = route.request().postDataJSON(); return route.fulfill({ status: 201, json: { review: { id: 'rv-2', status: 'pending' }, message: 'Thank you! Our team will confirm your stay before your review appears.' } }); }
    return route.fulfill({ json: { reviews, summary } });
  });
  await page.goto('/');
  await expect(page.locator('.property-card .rating-pill')).toContainText('4.5');
  await page.goto('/homes/home-1');
  await expect(page.getByRole('heading', { name: 'What past tenants say' })).toBeVisible();
  await expect(page.locator('.review-score strong')).toHaveText('4.5');
  await expect(page.getByRole('img', { name: '4.5 out of 5 stars' })).toBeVisible();
  await expect(page.locator('.landlord-reply')).toContainText('Thank you Mutale!');

  await page.getByRole('button', { name: 'Write a review' }).click();
  for (const [legend, stars] of [['Overall', 4], ['Landlord', 5], ['Water & power', 3], ['Security', 4], ['Value for money', 4]]) {
    await page.getByRole('group', { name: legend }).getByRole('radio', { name: `${stars} star${stars === 1 ? '' : 's'}`, exact: true }).check();
  }
  await page.getByLabel('Moved in').fill('2025-01');
  await page.getByLabel('I still live here').check();
  await page.getByLabel('Your review').fill('Quiet, safe and close to campus. Power cuts are rare.');
  await page.getByLabel('Phone (private)').fill('0971110001');
  await page.getByRole('button', { name: 'Submit review' }).click();
  await expect(page.getByRole('heading', { name: 'Thanks for your review' })).toBeVisible();
  expect(submitted).toMatchObject({ property_id: 'home-1', rating_overall: 4, rating_landlord: 5, rating_utilities: 3, rating_security: 4, rating_value: 4, stay_from: '2025-01', stay_to: null, phone: '0971110001' });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= document.documentElement.clientWidth)).toBe(true);
});

test('students see safety tips and can report a suspicious listing', async ({ page }) => {
  let reported;
  await page.route('**/api/properties/home-1/report', route => { reported = route.request().postDataJSON(); return route.fulfill({ status: 201, json: { message: 'Thank you. Our team will review this listing. Never pay anyone before you have viewed a room in person.' } }); });
  await page.goto('/homes/home-1');
  await expect(page.getByText('Never pay a deposit or rent before you have viewed the room in person.')).toBeVisible();
  await page.getByRole('button', { name: 'Report this listing' }).click();
  await page.getByLabel('The home doesn’t exist or isn’t available').check();
  await page.getByLabel('Details (optional)').fill('Address is an empty plot.');
  await page.getByRole('button', { name: 'Send report' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Our team will review this listing' })).toBeVisible();
  expect(reported).toEqual({ reason: 'fake_listing', details: 'Address is an empty plot.' });
});

test('students book a viewing and get a pre-written WhatsApp message', async ({ page }) => {
  let booked;
  await page.route('**/api/viewings', route => {
    booked = route.request().postDataJSON();
    return route.fulfill({ status: 201, json: { request: { id: 'v1', status: 'pending', preferred_date: booked.preferred_date, preferred_time: booked.preferred_time }, landlord_name: 'Jane Banda', whatsapp_link: 'https://wa.me/260971234567?text=Hi%20Jane' } });
  });
  await page.goto('/homes/home-1');
  await page.getByRole('button', { name: 'Book a viewing' }).click();
  await page.getByLabel('Your name').fill('Mwila');
  await page.getByLabel('Your WhatsApp number').fill('0971200001');
  const day = await page.getByLabel('Day').inputValue();
  await page.getByText('Evening', { exact: true }).click();
  await page.getByLabel('Message (optional)').fill('Is the twin room still free?');
  await page.getByRole('button', { name: 'Send request' }).click();
  await expect(page.getByText('Viewing request sent')).toBeVisible();
  await expect(page.getByRole('link', { name: 'Send request on WhatsApp' })).toHaveAttribute('href', 'https://wa.me/260971234567?text=Hi%20Jane');
  expect(booked).toEqual({ property_id: 'home-1', student_name: 'Mwila', student_phone: '0971200001', preferred_date: day, preferred_time: 'evening', message: 'Is the twin room still free?' });
});

test('landlords see viewing requests and confirm them', async ({ page }) => {
  let answer;
  const request = { id: 'v1', property_title: 'Garden View Student Lodge', student_name: 'Chanda', student_phone: '0961200004', when: 'Sat 28 Nov, morning (8am–12pm)', message: 'Can I bring my mother?', status: 'pending', reply_link: 'https://wa.me/260961200004' };
  await page.route('**/api/viewings/**', route => {
    if (route.request().method() === 'PATCH') { answer = route.request().postDataJSON(); return route.fulfill({ json: { request: { ...request, status: 'confirmed' } } }); }
    return route.fulfill({ json: { requests: answer ? [{ ...request, status: 'confirmed', reply_link: 'https://wa.me/260961200004?text=confirmed' }] : [request] } });
  });
  await signIn(page);
  await expect(page.getByRole('heading', { name: /Viewing requests/ })).toContainText('1 new');
  await expect(page.getByText('Sat 28 Nov, morning (8am–12pm)')).toBeVisible();
  await page.getByLabel('Note to student (optional)').fill('Ask for Jane at the gate');
  await page.getByRole('button', { name: 'Confirm' }).click();
  await expect(page.getByRole('link', { name: 'Send confirmation on WhatsApp' })).toHaveAttribute('href', /text=confirmed/);
  expect(answer).toEqual({ status: 'confirmed', note: 'Ask for Jane at the gate' });
});

test('empty results and API failures are actionable', async ({ page }) => {
  await page.goto('/?q=not-a-home');
  await expect(page.getByRole('heading', { name: 'No homes found just yet' })).toBeVisible();
  await page.getByRole('button', { name: 'Reset search' }).click();
  await expect(page.locator('.property-card')).toHaveCount(2);
  await page.route('**/api/properties', route => route.fulfill({ status: 503, json: { message: 'Temporarily unavailable' } }));
  await page.reload();
  await expect(page.getByRole('alert')).toContainText('Temporarily unavailable');
  await expect(page.getByRole('button', { name: 'Try again' })).toBeVisible();
});

test('registration explains approval and protected pages require login', async ({ page }) => {
  await page.goto('/landlord/new');
  await expect(page).toHaveURL(/\/login/);
  await page.getByRole('link', { name: 'Create an account', exact: true }).click();
  await page.getByLabel('Full name').fill('Jane Banda');
  await page.getByLabel('Phone number').fill('0971234567');
  await page.getByLabel('Password').fill('strong-password');
  await page.getByRole('button', { name: 'Create account', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'You’re on the list.' })).toBeVisible();
  await expect(page.getByText(/Once approved, sign in/)).toBeVisible();
});

async function signIn(page) {
  await page.goto('/login');
  await page.getByLabel('Phone number').fill('0971234567');
  await page.getByLabel('Password').fill('strong-password');
  await page.getByRole('button', { name: 'Sign in', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Hello, Jane.' })).toBeVisible();
}

test('landlord creates a property, updates availability and uploads browser files', async ({ page }) => {
  await signIn(page);
  await page.getByRole('link', { name: 'Add a property' }).click();
  await page.getByLabel('Property name').fill('New Home');
  await page.getByLabel('Street address / area').fill('Kalundu');
  await page.getByLabel('Latitude').fill('-15.39');
  await page.getByLabel('Longitude').fill('28.33');
  const created = page.waitForRequest(request => request.url().endsWith('/api/properties') && request.method() === 'POST');
  await page.getByRole('button', { name: 'Save and add rooms' }).click();
  expect((await created).postDataJSON()).toMatchObject({ title: 'New Home', latitude: -15.39, longitude: 28.33 });
  await expect(page.getByRole('heading', { name: 'Manage your property' })).toBeVisible();
  await page.getByLabel('Available rooms — Double sharing').fill('1');
  const availability = page.waitForRequest(request => request.url().includes('/rooms/room-1') && request.method() === 'PATCH');
  await page.getByRole('button', { name: 'Update', exact: true }).click();
  expect((await availability).postDataJSON()).toEqual({ available_rooms: 1 });
  await expect(page.getByLabel('Choose photos')).toBeVisible();
  await page.getByLabel('Choose photos').setInputFiles({ name: 'room.png', mimeType: 'image/png', buffer: Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j5ioAAAAASUVORK5CYII=', 'base64') });
  const uploaded = page.waitForRequest(request => request.url().endsWith('/api/photos/home-1'));
  await page.getByRole('button', { name: 'Upload photos' }).click();
  const request = await uploaded;
  expect(request.headers()['content-type']).toContain('multipart/form-data');
  expect(request.headers().authorization).toBe('Bearer test-session');
  await expect(page.getByRole('heading', { name: 'Manage your property' })).toBeVisible();
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
});

test('landlord pays the listing fee by mobile money and sees it confirmed', async ({ page }) => {
  const plans = [{ id: 'basic', name: 'Basic', amount: 300, months: 12, description: 'Visible for 12 months.' }, { id: 'premium', name: 'Premium', amount: 750, months: 12, description: 'Featured for 12 months.' }];
  const pending = { id: 'pay-1', status: 'pending', amount: '750.00', phone: '0961111111', mobile_money_provider: 'mtn', plan: 'premium' };
  let checks = 0;
  await page.route('**/api/payments/**', async route => {
    const path = new URL(route.request().url()).pathname;
    if (path.endsWith('/plans')) return route.fulfill({ json: { enabled: true, plans } });
    if (path.endsWith('/mine')) return route.fulfill({ json: { payments: [] } });
    if (path.endsWith('/listing')) return route.fulfill({ status: 201, json: { payment: pending } });
    checks += 1; // the second status check reports the landlord approved it on their phone
    return route.fulfill({ json: { payment: checks < 2 ? pending : { ...pending, status: 'confirmed', paid_at: '2026-11-27', expires_at: '2027-11-27' } } });
  });
  await signIn(page);
  await page.goto('/landlord/home-1');
  await expect(page.getByRole('heading', { name: 'Listing plan & payment' })).toBeVisible();
  await page.getByText('Premium', { exact: true }).click();
  await page.getByLabel('Mobile money number').fill('096 111 1111');
  await expect(page.getByLabel('Network')).toHaveValue('mtn');
  const started = page.waitForRequest(request => request.url().endsWith('/api/payments/listing'));
  await page.getByRole('button', { name: 'Pay K750 with mobile money' }).click();
  expect((await started).postDataJSON()).toEqual({ property_id: 'home-1', plan: 'premium', phone: '096 111 1111', operator: 'mtn' });
  await expect(page.getByRole('heading', { name: 'Check your phone' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Payment received. Your listing is live!' })).toBeVisible({ timeout: 15000 });
});

test('expired authentication returns landlord to sign in', async ({ page }) => {
  await signIn(page);
  await page.route('**/api/properties/landlord/my-properties', route => route.fulfill({ status: 401, json: { message: 'Expired' } }));
  await page.reload();
  await expect(page).toHaveURL(/\/login/);
  await expect(page.getByRole('status')).toContainText('Your session has expired');
});

test('landing page is responsive and has no runtime errors', async ({ page }, testInfo) => {
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.goto('/');
  await expect(page.locator('.property-card')).toHaveCount(2);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
  await page.screenshot({ path: testInfo.outputPath('home.png'), fullPage: true });
  expect(errors).toEqual([]);
});
