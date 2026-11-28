// Interactive maps (Leaflet + OpenStreetMap). Loaded lazily from student.jsx so the
// list view never downloads the map library.
import { useEffect, useMemo } from 'react';
import { Link } from 'react-router-dom';
import L from 'leaflet';
import { MapContainer, TileLayer, Marker, Popup, Polyline, useMap } from 'react-leaflet';
import 'leaflet/dist/leaflet.css';
import { money, commuteLabel } from './utils';

const LUSAKA = [-15.4167, 28.2833];
const TILE_URL = 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
const ATTRIBUTION = '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors';

const hasCoords = (lat, lng) => [lat, lng].every(v => v !== null && v !== undefined && v !== '' && Number.isFinite(Number(v)));
const point = (lat, lng) => [Number(lat), Number(lng)];

// HTML markers styled by CSS (no image assets, which bundlers tend to break).
const priceIcon = (label, active = false) => L.divIcon({
  className: '',
  html: `<span class="map-pin${active ? ' active' : ''}">${label}</span>`,
  iconSize: null,
  iconAnchor: [0, 0],
});
const campusIcon = L.divIcon({ className: '', html: '<span class="map-campus" aria-hidden="true">🎓</span>', iconSize: [34, 34], iconAnchor: [17, 17] });
const homeIcon = L.divIcon({ className: '', html: '<span class="map-home" aria-hidden="true">⌂</span>', iconSize: [38, 38], iconAnchor: [19, 19] });

function FitBounds({ points, maxZoom = 15 }) {
  const map = useMap();
  const key = points.map(p => p.join(',')).join('|');
  // The map can mount before its container has its final size (lazy chunk, layout
  // shifts); re-measure so every tile is requested.
  // Moves are instant: an animation still running when the page changes would
  // touch a map React has already removed (Leaflet's "_leaflet_pos" error).
  useEffect(() => {
    const container = map.getContainer();
    let frame = 0;
    const observer = new ResizeObserver(() => {
      cancelAnimationFrame(frame);
      frame = requestAnimationFrame(() => { if (container.isConnected) map.invalidateSize({ animate: false }); });
    });
    observer.observe(container);
    return () => { observer.disconnect(); cancelAnimationFrame(frame); };
  }, [map]);
  useEffect(() => {
    map.invalidateSize({ animate: false });
    if (points.length === 1) map.setView(points[0], maxZoom, { animate: false });
    else if (points.length > 1) map.fitBounds(points, { padding: [40, 40], maxZoom, animate: false });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [key, map, maxZoom]);
  return null;
}

function BaseMap({ label, children, className = '' }) {
  return <MapContainer center={LUSAKA} zoom={12} scrollWheelZoom={false} className={`leaflet-map ${className}`} aria-label={label} role="region">
    <TileLayer url={TILE_URL} attribution={ATTRIBUTION} />
    {children}
  </MapContainer>;
}

/** Browse page: every matching home as a price pin, plus campuses. */
export function ListingsMap({ properties, schools = [], selectedSchool = '' }) {
  const located = useMemo(() => properties.filter(p => hasCoords(p.latitude, p.longitude)), [properties]);
  const campuses = useMemo(() => schools.filter(s => hasCoords(s.latitude, s.longitude) && (!selectedSchool || String(s.id) === selectedSchool)), [schools, selectedSchool]);
  const bounds = [...located.map(p => point(p.latitude, p.longitude)), ...(selectedSchool ? campuses.map(s => point(s.latitude, s.longitude)) : [])];
  const missing = properties.length - located.length;
  return <div className="map-view">
    <BaseMap label="Map of student homes">
      <FitBounds points={bounds.length ? bounds : [LUSAKA]} maxZoom={bounds.length ? 15 : 12} />
      {campuses.map(s => <Marker key={`school-${s.id}`} position={point(s.latitude, s.longitude)} icon={campusIcon} title={s.name}><Popup><strong>{s.name}</strong>{s.area && <><br />{s.area}</>}</Popup></Marker>)}
      {located.map(p => <Marker key={p.id} position={point(p.latitude, p.longitude)} icon={priceIcon(p.min_price != null ? money(p.min_price) : 'Home', p.is_premium)} title={p.title} alt={p.title}>
        <Popup><div className="map-popup"><strong>{p.title}</strong><span>{p.address}</span>{commuteLabel(p) && <span>{commuteLabel(p)}</span>}<span className="map-popup-price">{money(p.min_price)}{p.min_price != null && ' / month'}</span><Link to={`/homes/${p.id}`}>View home →</Link></div></Popup>
      </Marker>)}
    </BaseMap>
    {missing > 0 && <p className="inline-note">{missing} home{missing === 1 ? '' : 's'} without a map location {missing === 1 ? 'is' : 'are'} shown in the list view.</p>}
  </div>;
}

/** Home page: the home, its campus and a straight line between them. */
export function PropertyMap({ property: p }) {
  if (!hasCoords(p.latitude, p.longitude)) return null;
  const home = point(p.latitude, p.longitude);
  const campus = hasCoords(p.school_lat, p.school_lng) ? point(p.school_lat, p.school_lng) : null;
  return <BaseMap label={`Map showing ${p.title}${campus ? ` and ${p.school_name || 'campus'}` : ''}`} className="detail-map">
    <FitBounds points={campus ? [home, campus] : [home]} maxZoom={16} />
    <Marker position={home} icon={homeIcon} title={p.title}><Popup><strong>{p.title}</strong><br />{p.address}</Popup></Marker>
    {campus && <><Marker position={campus} icon={campusIcon} title={p.school_name || 'Campus'}><Popup><strong>{p.school_name || 'Campus'}</strong></Popup></Marker>
      <Polyline positions={[home, campus]} pathOptions={{ color: '#15795a', weight: 3, dashArray: '6 8', opacity: 0.8 }} /></>}
  </BaseMap>;
}
