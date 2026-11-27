import { test } from 'node:test';
import assert from 'node:assert/strict';
import { filterProperties, statusOf, phoneLink, safeImage } from '../src/utils.js';

test('search combines campus, budget and text without treating missing prices as free', () => {
  const homes = [
    { id: 1, title: 'Garden lodge', address: 'Lusaka', nearest_school_id: 'unza', min_price: '900' },
    { id: 2, title: 'Garden room', address: 'Lusaka', nearest_school_id: 'unza', min_price: null },
    { id: 3, title: 'Garden house', address: 'Kitwe', nearest_school_id: 'cbu', min_price: '600' },
  ];
  assert.deepEqual(filterProperties(homes, { query: ' GARDEN ', school: 'unza', maxPrice: '1000' }).map(p => p.id), [1]);
  assert.deepEqual(filterProperties(homes, { sort: 'price' }).map(p => p.id), [3, 1, 2]);
  assert.equal(homes[0].id, 1);
});
test('status never labels expired or unapproved properties live', () => {
  assert.equal(statusOf({ is_approved: false, is_active: true }), 'Awaiting review');
  assert.equal(statusOf({ is_approved: true, is_active: true, listing_expires_at: '2020-01-01' }), 'Expired');
  assert.equal(statusOf({ is_approved: true, is_active: false }), 'Awaiting activation');
});
test('contact links normalize local Zambian phone numbers', () => {
  assert.equal(phoneLink('097 123 4567'), 'tel:+260971234567');
  assert.equal(phoneLink('+260 971234567', true), 'https://wa.me/260971234567');
  assert.equal(phoneLink(null), null);
});
test('photo URLs exclude executable and relative schemes', () => {
  assert.equal(safeImage('javascript:alert(1)'), '');
  assert.equal(safeImage('/not-a-public-photo'), '');
  assert.equal(safeImage('https://example.com/home.jpg'), 'https://example.com/home.jpg');
});
test('verified-only filter keeps just admin-verified homes', () => {
  const homes = [{ id: 1, title: 'A', address: '', is_verified: true }, { id: 2, title: 'B', address: '', is_verified: false }, { id: 3, title: 'C', address: '' }];
  assert.deepEqual(filterProperties(homes, { verifiedOnly: true }).map(p => p.id), [1]);
  assert.equal(filterProperties(homes).length, 3);
});
test('travel estimates allow for detours and minibus waiting time', async () => {
  const { travelEstimates, formatMinutes, commuteLabel, campusDistance, distanceKm } = await import('../src/utils.js');
  assert.deepEqual(travelEstimates(1.2), { km: 1.2, walkMinutes: 20, busMinutes: 15 });
  assert.equal(travelEstimates(0.5).busMinutes, null, 'short trips are walked');
  assert.equal(travelEstimates(null), null);
  assert.equal(travelEstimates('not a number'), null);
  assert.equal(formatMinutes(45), '45 min');
  assert.equal(formatMinutes(125), '2 h 5 min');
  assert.equal(commuteLabel({ distance_from_school: '1.2' }), '~20 min walk to campus');
  assert.equal(commuteLabel({ distance_from_school: 6 }), '~36 min by minibus to campus');
  assert.equal(commuteLabel({}), null);
  assert.equal(campusDistance({ latitude: -15.39, longitude: 28.33, school_lat: -15.39, school_lng: 28.34 }), distanceKm(-15.39, 28.33, -15.39, 28.34));
  assert.ok(Math.abs(distanceKm(-15.3947, 28.3322, -15.4167, 28.2833) - 5.75) < 0.2, 'UNZA to Lusaka CBD is ~5.7 km');
});
test('landlords see when a listing is hidden after reports', () => {
  assert.equal(statusOf({ is_approved: true, is_active: true, flagged_at: '2026-11-27' }), 'Hidden: under review after reports');
  assert.equal(statusOf({ is_approved: false, flagged_at: '2026-11-27' }), 'Awaiting review');
});
