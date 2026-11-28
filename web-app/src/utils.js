export const money = (value) => value === null || value === undefined || value === '' ? 'Ask landlord' : `K${Number(value).toLocaleString('en-ZM', { maximumFractionDigits: 0 })}`;
export const amenityNames = { wifi: 'Wi-Fi', water: 'Running water', electricity: 'Electricity', security: 'Security', furnished: 'Furnished', parking: 'Parking', solar: 'Solar power', kitchen: 'Kitchen' };
export function safeImage(url) {
  try { const parsed = new URL(url); return parsed.protocol === 'https:' || parsed.protocol === 'http:' ? parsed.href : ''; } catch { return ''; }
}
export function statusOf(property) {
  if (!property.is_approved) return 'Awaiting review';
  if (property.listing_expires_at && new Date(property.listing_expires_at).getTime() <= Date.now()) return 'Expired';
  return property.is_active ? 'Live' : 'Awaiting activation';
}
export function phoneLink(phone, whatsapp = false) {
  let digits = String(phone || '').replace(/\D/g, '');
  if (digits.startsWith('0')) digits = `260${digits.slice(1)}`;
  return digits ? whatsapp ? `https://wa.me/${digits}` : `tel:+${digits}` : null;
}
export function filterProperties(properties, { query = '', school = '', maxPrice = '', sort = 'newest', verifiedOnly = false } = {}) {
  const result = properties.filter(p => (!school || String(p.nearest_school_id) === school)
    && (!verifiedOnly || p.is_verified === true)
    && (!maxPrice || (p.min_price != null && Number(p.min_price) <= Number(maxPrice)))
    && `${p.title} ${p.address} ${p.school_name || ''}`.toLowerCase().includes(query.toLowerCase().trim()));
  if (sort === 'price') result.sort((a, b) => (a.min_price == null ? Infinity : Number(a.min_price)) - (b.min_price == null ? Infinity : Number(b.min_price)));
  if (sort === 'distance') result.sort((a, b) => (a.distance_from_school == null ? Infinity : Number(a.distance_from_school)) - (b.distance_from_school == null ? Infinity : Number(b.distance_from_school)));
  return result;
}
export function readStored(storage, key, fallback) {
  try { return JSON.parse(storage.getItem(key)) ?? fallback; } catch { return fallback; }
}
const OPERATOR_PREFIXES = { mtn: ['096', '076'], airtel: ['097', '077'], zamtel: ['095', '075'] };
export const operatorNames = { mtn: 'MTN MoMo', airtel: 'Airtel Money', zamtel: 'Zamtel Kwacha' };
export function detectOperator(phone) {
  let digits = String(phone || '').replace(/\D/g, '');
  if (digits.startsWith('260')) digits = `0${digits.slice(3)}`;
  return Object.keys(OPERATOR_PREFIXES).find(op => OPERATOR_PREFIXES[op].some(prefix => digits.startsWith(prefix))) || '';
}
export const formatDate = (value) => value ? new Date(value).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric', timeZone: 'Africa/Lusaka' }) : '';

// Travel estimates from the straight-line distance to campus. Real routes are
// longer than a straight line, so we add a detour allowance; minibus time also
// includes walking to the stop and waiting. Always shown as approximate.
const ROUTE_DETOUR = 1.3;
const WALK_KMH = 4.8;
const MINIBUS_KMH = 18;
const MINIBUS_OVERHEAD_MIN = 10;
const MINIBUS_MIN_KM = 1.5; // shorter trips are simply walked
export function distanceKm(lat1, lon1, lat2, lon2) {
  if ([lat1, lon1, lat2, lon2].some(v => v === null || v === undefined || v === '' || !Number.isFinite(Number(v)))) return null;
  const rad = v => (Number(v) * Math.PI) / 180;
  const a = Math.sin((rad(lat2) - rad(lat1)) / 2) ** 2 + Math.cos(rad(lat1)) * Math.cos(rad(lat2)) * Math.sin((rad(lon2) - rad(lon1)) / 2) ** 2;
  return Math.round(6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)) * 100) / 100;
}
export function campusDistance(p) {
  const stored = p?.distance_from_school;
  if (stored !== null && stored !== undefined && stored !== '' && Number.isFinite(Number(stored))) return Number(stored);
  return distanceKm(p?.latitude, p?.longitude, p?.school_lat, p?.school_lng);
}
export function travelEstimates(km) {
  if (km === null || km === undefined || !Number.isFinite(Number(km)) || Number(km) < 0) return null;
  const road = Number(km) * ROUTE_DETOUR;
  return {
    km: Number(km),
    walkMinutes: Math.max(1, Math.round((road / WALK_KMH) * 60)),
    busMinutes: road >= MINIBUS_MIN_KM ? Math.round((road / MINIBUS_KMH) * 60 + MINIBUS_OVERHEAD_MIN) : null,
  };
}
export function formatMinutes(minutes) {
  if (minutes < 60) return `${minutes} min`;
  const h = Math.floor(minutes / 60), m = minutes % 60;
  return m ? `${h} h ${m} min` : `${h} h`;
}
/** Short label for listing cards: walking when reasonable, otherwise minibus. */
export function commuteLabel(p) {
  const t = travelEstimates(campusDistance(p));
  if (!t) return null;
  return t.walkMinutes <= 40 || !t.busMinutes ? `~${formatMinutes(t.walkMinutes)} walk to campus` : `~${formatMinutes(t.busMinutes)} by minibus to campus`;
}
