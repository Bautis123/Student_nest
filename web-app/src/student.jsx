import { lazy, Suspense, useEffect, useState } from 'react';
import { Link, useParams, useSearchParams } from 'react-router-dom';
import { ArrowLeft, ArrowRight, Search, MapPin, Heart, SlidersHorizontal, GraduationCap, ShieldCheck, MessageCircle, Phone, Check, Compass, ArrowUpRight, List, Map as MapIcon, Footprints, Bus, Users } from 'lucide-react';
import { useApp } from './context';
import { api } from './api';
import { PropertyReviews } from './reviews';
import { ListingSafety } from './reportListing';
import { useResource, Loading, ErrorState, Empty, PropertyCard, PropertyImage, Field, VerifiedBadge, VERIFIED_EXPLAINER } from './components';
import { amenityNames, money, filterProperties, phoneLink, campusDistance, travelEstimates, formatMinutes } from './utils';

// Leaflet is only downloaded when a map is actually shown.
const ListingsMap = lazy(() => import('./map').then(m => ({ default: m.ListingsMap })));
const PropertyMap = lazy(() => import('./map').then(m => ({ default: m.PropertyMap })));
const MapLoading = () => <div className="map-placeholder" role="status">Loading map…</div>;

export function Browse({ savedOnly = false }) {
  const [params, setParams] = useSearchParams();
  const query = params.get('q') || '';
  const school = params.get('school') || '';
  const maxPrice = params.get('budget') || '';
  const sort = params.get('sort') || 'newest';
  // Local mirror of ?verified=1: router URL updates are deferred, so a checkbox bound
  // only to the URL would briefly snap back after each click.
  const verifiedParam = params.get('verified') === '1';
  const [verifiedOnly, setVerifiedOnly] = useState(verifiedParam);
  useEffect(() => setVerifiedOnly(verifiedParam), [verifiedParam]);
  const [refresh, setRefresh] = useState(0);
  const [filtersOpen, setFiltersOpen] = useState(false);
  const view = params.get('view') === 'map' ? 'map' : 'list';
  const { saved } = useApp();
  const properties = useResource('/properties', undefined, refresh);
  const schools = useResource('/properties/schools', undefined, refresh);
  const update = (name, value) => setParams(previous => { const next = new URLSearchParams(previous); value ? next.set(name, value) : next.delete(name); return next; }, { replace: true });
  const matching = filterProperties((properties.data?.properties || []).filter(p => !savedOnly || saved.includes(p.id)), { query, school, maxPrice, sort, verifiedOnly });
  return <>
    {!savedOnly ? <section className="hero"><div className="hero-copy"><div className="kicker"><span />A little closer to campus. A lot closer to home.</div><h1>Big dreams.<br />A place to <em>belong.</em></h1><p>Find student accommodation near your campus.<br className="desktop-break" /> Less searching. More living.</p><div className="hero-points"><span><ShieldCheck size={17} />Admin-reviewed listings</span><span><MessageCircle size={17} />Talk directly to landlords</span></div></div><div className="hero-art" aria-hidden="true"><div className="orbit orbit-one" /><div className="orbit orbit-two" /><div className="sun" /><div className="house"><div className="roof" /><div className="house-front"><div className="window"><i /><i /><i /><i /></div><div className="door" /><div className="window second"><i /><i /><i /><i /></div></div><div className="house-side" /></div><div className="ground" /><div className="plant plant-one" /><div className="plant plant-two" /><div className="float-label campus-label"><GraduationCap size={23} /><div>Your next chapter<small>Starts with a place to call home</small></div></div><div className="float-label home-label"><span className="green-dot" />Find your nest</div><span className="art-caption">STUDENT LIVING, MADE SIMPLE</span></div></section> : <section className="page-heading container"><p className="eyebrow">Your shortlist</p><h1>Homes you’re keeping an eye on.</h1><p className="muted">Saved on this browser, ready when you are. Only currently available listings appear here.</p></section>}
    <section className="browse-section container" aria-labelledby="browse-title"><div className="search-panel"><label className="search-input"><Search size={20} /><span className="sr-only">Search homes</span><input placeholder="Search by area, campus or home…" value={query} onChange={e => update('q', e.target.value)} /></label><label className="school-select"><GraduationCap size={21} /><span className="sr-only">Campus</span><select value={school} onChange={e => update('school', e.target.value)}><option value="">All campuses</option>{schools.data?.schools?.map(s => <option value={s.id} key={s.id}>{s.name}</option>)}</select></label><button className={`filter-button ${filtersOpen || maxPrice || verifiedOnly ? 'active' : ''}`} onClick={() => setFiltersOpen(!filtersOpen)} aria-expanded={filtersOpen}><SlidersHorizontal size={18} />Filters{(maxPrice || verifiedOnly) && <span className="green-dot" />}</button></div>
      {schools.error && <p className="inline-note">Campus filters are unavailable. You can still search by name. <button className="text-button" onClick={() => setRefresh(r => r + 1)}>Retry</button></p>}
      {filtersOpen && <div className="filter-panel"><Field label="Maximum monthly rent (K)" type="number" min="0" value={maxPrice} placeholder="Any budget" onChange={e => update('budget', e.target.value)} /><label className="check-filter" title={VERIFIED_EXPLAINER}><input type="checkbox" checked={verifiedOnly} onChange={e => { setVerifiedOnly(e.target.checked); update('verified', e.target.checked ? '1' : ''); }} /><span>Verified homes only</span></label><button className="text-button" onClick={() => setParams({})}>Clear all filters</button></div>}
      <div className="results-heading"><div><p className="eyebrow">{savedOnly ? 'Made for your next move' : 'Find your corner of campus life'}</p><h2 id="browse-title">{savedOnly ? 'Your saved homes' : 'A home for your next chapter'}<span>{!properties.loading && !properties.error && matching.length}</span></h2></div><div className="results-tools"><div className="view-toggle" role="group" aria-label="Show homes as"><button type="button" aria-pressed={view === 'list'} onClick={() => update('view', '')}><List size={16} />List</button><button type="button" aria-pressed={view === 'map'} onClick={() => update('view', 'map')}><MapIcon size={16} />Map</button></div><label className="sort-control">Sort by <select aria-label="Sort homes" value={sort} onChange={e => update('sort', e.target.value)}><option value="newest">Newest first</option><option value="price">Lowest rent</option><option value="distance">Closest to campus</option></select></label></div></div>
      {properties.loading ? <Loading /> : properties.error ? <ErrorState message={properties.error} retry={() => setRefresh(r => r + 1)} /> : matching.length ? view === 'map' ? <Suspense fallback={<MapLoading />}><ListingsMap properties={matching} schools={schools.data?.schools || []} selectedSchool={school} /></Suspense> : <div className="property-grid">{matching.map(p => <PropertyCard key={p.id} property={p} />)}</div> : <Empty title={savedOnly ? 'Your next home could be one click away' : 'No homes found just yet'}>{savedOnly ? <Link to="/">Browse homes and tap the heart to save a favourite.</Link> : <>Try another campus or a wider budget. <button className="text-button" onClick={() => setParams({})}>Reset search</button></>}</Empty>}
    </section>
    {!savedOnly && <section className="landlord-banner container"><div className="banner-icon"><HomeMark /></div><div><p className="eyebrow">Have a place students will love?</p><h2>Good homes deserve to be found.</h2><p>Reach students looking for a place near your property.</p></div><Link className="button" to="/register">Become a landlord <ArrowRight size={18} /></Link></section>}
  </>;
}
function HomeMark() { return <GraduationCap size={34} strokeWidth={1.4} />; }

function CampusTravel({ property: p }) {
  const travel = travelEstimates(campusDistance(p));
  const hasMap = p.latitude != null && p.longitude != null;
  if (!travel && !hasMap) return null;
  const campus = p.school_name || 'campus';
  return <section className="detail-section" aria-labelledby="travel-title"><h2 id="travel-title">Getting to {campus}</h2>
    {travel && <div className="travel-grid">
      <div className="travel-option"><Footprints size={20} /><span>Walking<strong>~{formatMinutes(travel.walkMinutes)}</strong></span></div>
      {travel.busMinutes && <div className="travel-option"><Bus size={20} /><span>Minibus<strong>~{formatMinutes(travel.busMinutes)}</strong></span></div>}
      <div className="travel-option"><GraduationCap size={20} /><span>Distance<strong>{travel.km} km</strong></span></div>
    </div>}
    {travel && <p className="travel-note">Estimates from the straight-line distance, allowing for road detours and, by minibus, time to reach a stop and wait. Check the route before you commit.</p>}
    {hasMap && <Suspense fallback={<MapLoading />}><PropertyMap property={p} /></Suspense>}
  </section>;
}

export function PropertyDetail() {
  const { id } = useParams();
  const [refresh, setRefresh] = useState(0);
  const { data, loading, error } = useResource(`/properties/${encodeURIComponent(id)}`, undefined, refresh);
  const { saved, toggleSaved } = useApp();
  const [activePhoto, setActivePhoto] = useState(0);
  if (loading) return <Loading label="Opening this home…" />;
  if (error) return <div className="container"><Link className="back-link" to="/"><ArrowLeft size={16} />Back to homes</Link><ErrorState message={error} retry={() => setRefresh(r => r + 1)} /></div>;
  const p = data?.property;
  if (!p) return <Empty title="This home is no longer available"><Link to="/">Browse other homes</Link></Empty>;
  const amenities = typeof p.amenities === 'object' && p.amenities ? p.amenities : {};
  const prices = (p.rooms || []).map(r => Number(r.price_per_month)).filter(Number.isFinite);
  const call = phoneLink(p.landlord_phone);
  const whatsapp = phoneLink(p.landlord_phone, true);
  const track = () => { api(`/properties/${encodeURIComponent(id)}/contact`, { method: 'POST' }).catch(() => {}); };
  return <div className="container detail-page"><div className="detail-toolbar"><Link className="back-link" to="/"><ArrowLeft size={16} />All homes</Link><button className="button secondary small" onClick={() => toggleSaved(p.id)} aria-pressed={saved.includes(p.id)}><Heart size={17} fill={saved.includes(p.id) ? 'currentColor' : 'none'} />{saved.includes(p.id) ? 'Saved' : 'Save home'}</button></div>
    <div className="detail-heading"><p className="eyebrow">{p.school_name || 'Student accommodation'}</p><h1>{p.title}</h1><p className="muted location"><MapPin size={17} />{p.address}</p>{p.is_verified && <div className="verified-note"><VerifiedBadge large /><p>{VERIFIED_EXPLAINER} Still arrange a viewing before you pay.</p></div>}</div>
    <div className="detail-layout"><div><div className="gallery"><PropertyImage url={p.photos?.[activePhoto]?.url} title={p.title} /></div>{p.photos?.length > 1 && <div className="thumbnails">{p.photos.map((photo, index) => <button key={photo.id} className={activePhoto === index ? 'active' : ''} onClick={() => setActivePhoto(index)} aria-label={`View photo ${index + 1}`} aria-pressed={activePhoto === index}><PropertyImage url={photo.url} title={`${p.title}, photo ${index + 1}`} /></button>)}</div>}
      <section className="detail-section"><h2>A little about this home</h2><p className="description">{p.description || 'Contact the landlord for more information about this home.'}</p></section>
      <CampusTravel property={p} />
      <PropertyReviews property={p} />
      <section className="detail-section"><h2>Room options</h2>{p.rooms?.length ? <div className="room-list">{p.rooms.map(room => <div className="room-row" key={room.id}><div><h3>{room.room_type}</h3><p>{room.students_per_room} student{Number(room.students_per_room) !== 1 ? 's' : ''} per room · {room.available_rooms} rooms available</p></div><strong>{money(room.price_per_month)}<small> / month</small></strong></div>)}</div> : <p className="muted">Ask the landlord about room options and pricing.</p>}{p.rooms?.some(room => Number(room.students_per_room) > 1) && <Link className="roommate-cta" to={`/roommates?${new URLSearchParams({ ...(p.nearest_school_id && { school: p.nearest_school_id }) })}`}><Users size={17} />Sharing a room? Find a roommate at {p.school_name || 'your campus'} →</Link>}</section>
      {Object.values(amenities).some(Boolean) && <section className="detail-section"><h2>The everyday essentials</h2><div className="amenities">{Object.entries(amenities).filter(([, value]) => value === true).map(([key]) => <span key={key}><Check size={17} />{amenityNames[key] || key.replaceAll('_', ' ')}</span>)}</div></section>}
    </div><aside className="contact-card"><p className="eyebrow">Make your next move</p><div className="detail-price">{money(prices.length ? Math.min(...prices) : null)}{prices.length > 0 && <span>from / month</span>}</div><div className="landlord-info"><span className="avatar">{(p.landlord_name || 'L').slice(0, 1)}</span><div><strong>{p.landlord_name || 'Property landlord'}</strong><small>Your direct contact</small></div></div>{whatsapp && <a className="button" href={whatsapp} target="_blank" rel="noreferrer" onClick={track}><MessageCircle size={18} />Chat on WhatsApp</a>}{call && <a className="button secondary" href={call} onClick={track}><Phone size={17} />Call landlord</a>}{!call && <p className="muted">Contact details are currently unavailable.</p>}<p className="contact-note">Arrange a viewing and confirm availability directly with the landlord before making a payment.</p>{p.latitude != null && p.longitude != null && <a className="map-link" href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${p.latitude},${p.longitude}`)}`} target="_blank" rel="noreferrer"><Compass size={18} />View location on Google Maps <ArrowUpRight size={16} /></a>}<ListingSafety propertyId={p.id} /></aside></div>
  </div>;
}
