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
