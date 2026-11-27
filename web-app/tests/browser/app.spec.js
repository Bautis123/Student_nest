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
