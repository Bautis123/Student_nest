import { useEffect, useState } from 'react';
import { Link, Navigate, useLocation, useNavigate, useParams } from 'react-router-dom';
import { ArrowLeft, ArrowRight, Plus, Home, Eye, Users, CheckCircle2, Upload, MapPin, Star, Trash2 } from 'lucide-react';
import { api } from './api';
import { useApp } from './context';
import { useResource, Loading, ErrorState, Empty, Field, PropertyImage } from './components';
import { amenityNames, money, statusOf } from './utils';

export function Auth({ register = false }) {
  const { session, login } = useApp();
  const navigate = useNavigate();
  const location = useLocation();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [registered, setRegistered] = useState(false);
  useEffect(() => { setError(''); setRegistered(false); }, [register]);
  if (session?.user?.role === 'landlord') return <Navigate to="/landlord" replace />;
  async function submit(event) {
    event.preventDefault(); setBusy(true); setError('');
    const body = Object.fromEntries(new FormData(event.currentTarget));
    try {
      const result = await api(register ? '/auth/register' : '/auth/login', { method: 'POST', body });
      if (register) setRegistered(true);
      else {
        if (result.user?.role !== 'landlord') throw new Error('Please use the admin portal for an administrator account.');
        login(result);
        const from = location.state?.from;
        navigate(typeof from === 'string' && from.startsWith('/landlord') ? from : '/landlord', { replace: true });
      }
    } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  return <section className="auth-layout container"><div className="auth-intro"><p className="eyebrow">For the people who make a place a home</p><h1>Your property.<br />Their next <em>chapter.</em></h1><p>Bring your student accommodation to the people looking for it.</p><div className="auth-step"><span>01</span><div><h3>Create your account</h3><p>Our team reviews landlord registrations.</p></div></div><div className="auth-step"><span>02</span><div><h3>Make your listing yours</h3><p>Add your rooms, prices and photos.</p></div></div><div className="auth-step"><span>03</span><div><h3>Welcome your next tenants</h3><p>After review and payment verification, students can find and contact you.</p></div></div></div>
    <div className="auth-card">{registered ? <div className="state"><CheckCircle2 size={40} /><h2>You’re on the list.</h2><p>Your account has been submitted for admin approval. Once approved, sign in with your phone number and password.</p><Link className="button" to="/login">Go to sign in <ArrowRight size={16} /></Link></div> : <><p className="eyebrow">Landlord portal</p><h2>{register ? 'Let’s get you started.' : 'Welcome back.'}</h2><p className="muted">{register ? 'Create an account to list your property.' : 'Sign in to manage your student homes.'}</p><form onSubmit={submit} key={register ? 'register' : 'login'}>{register && <Field label="Full name" name="full_name" autoComplete="name" required maxLength={160} />}<Field label="Phone number" name="phone" type="tel" autoComplete="tel" placeholder="e.g. 0971234567" required maxLength={40} />{register && <Field label="Email (optional)" name="email" type="email" autoComplete="email" maxLength={160} />}<Field label="Password" name="password" type="password" autoComplete={register ? 'new-password' : 'current-password'} required minLength={register ? 8 : undefined} maxLength={128} />{register && <p className="form-hint">Use at least 8 characters.</p>}{error && <p className="error-message" role="alert">{error}</p>}<button className="button full" disabled={busy}>{busy ? 'Please wait…' : register ? 'Create account' : 'Sign in'}<ArrowRight size={17} /></button></form><p className="auth-switch">{register ? 'Already have an account?' : 'New to Student Nest?'} <Link to={register ? '/login' : '/register'}>{register ? 'Sign in' : 'Create an account'}</Link></p></>}</div>
  </section>;
}

export function Dashboard() {
  const { session } = useApp();
  const [refresh, setRefresh] = useState(0);
  const { loading, error, data } = useResource('/properties/landlord/my-properties', session.token, refresh);
  const properties = data?.properties || [];
  return <div className="container dashboard"><div className="page-heading heading-with-action"><div><p className="eyebrow">Your landlord workspace</p><h1>Hello, {session.user.full_name?.split(' ')[0] || 'there'}.</h1><p className="muted">A little care for your listings goes a long way.</p></div><Link className="button" to="/landlord/new"><Plus size={18} />Add a property</Link></div>
    {loading ? <Loading label="Loading your properties…" /> : error ? <ErrorState message={error} retry={() => setRefresh(r => r + 1)} /> : <><div className="stats-grid"><Stat icon={<Home />} label="Your properties" value={properties.length} /><Stat icon={<Eye />} label="Listing views" value={properties.reduce((sum, p) => sum + Number(p.view_count || 0), 0)} /><Stat icon={<Users />} label="Available rooms" value={properties.reduce((sum, p) => sum + Number(p.available_rooms_count || 0), 0)} /></div><div className="results-heading"><h2>Your properties</h2><button className="text-button" onClick={() => setRefresh(r => r + 1)}>Refresh</button></div>{!properties.length ? <Empty title="Your first listing starts here"><Link to="/landlord/new">Add a property, then add rooms and photos.</Link></Empty> : <div className="dashboard-list">{properties.map(p => <article className="listing-row" key={p.id}><div className="listing-symbol"><Home size={27} /></div><div className="listing-summary"><span className={`badge ${statusOf(p) === 'Live' ? 'live' : ''}`}>{statusOf(p)}</span><h3>{p.title}</h3><p className="muted">{p.address}</p><p className="listing-counts">{p.available_rooms_count} / {p.total_rooms_count} rooms available · {p.view_count || 0} views{p.listing_expires_at && ` · Expires ${new Date(p.listing_expires_at).toLocaleDateString('en-GB', { timeZone: 'Africa/Lusaka' })}`}</p></div><Link className="button secondary small" to={`/landlord/${p.id}`}>Manage <ArrowRight size={16} /></Link></article>)}</div>}<div className="info-panel"><CheckCircle2 size={21} /><p><strong>From listing to live.</strong> Add your property details, rooms and photos. An admin reviews your listing and verifies payment before activation. Payment is handled by the team; this app does not collect money.</p></div></>}
  </div>;
}
function Stat({ icon, label, value }) { return <div className="stat-card">{icon}<span>{label}<strong>{value}</strong></span></div>; }

export function ListingEditor() {
  const { id } = useParams();
  const { session } = useApp();
  const [refresh, setRefresh] = useState(0);
  // Separate components keep the new-property flow independent of private detail loading.
  return id ? <ExistingListing key={id} id={id} token={session.token} refresh={refresh} reload={() => setRefresh(r => r + 1)} /> : <ListingForm token={session.token} />;
}
function ExistingListing({ id, token, refresh, reload }) {
  const resource = useResource(`/properties/landlord/my-properties/${encodeURIComponent(id)}`, token, refresh);
  if (resource.loading) return <Loading label="Opening your listing…" />;
  if (resource.error) return <div className="container"><ErrorState message={resource.error} retry={reload} /></div>;
  return <ListingForm token={token} property={resource.data.property} reload={reload} />;
}
function ListingForm({ token, property, reload }) {
  const navigate = useNavigate();
  const schools = useResource('/properties/schools');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [latitude, setLatitude] = useState(property?.latitude || '');
  const [longitude, setLongitude] = useState(property?.longitude || '');
  async function submit(event) {
    event.preventDefault(); setBusy(true); setError('');
    const form = new FormData(event.currentTarget);
    const body = { title: form.get('title').trim(), description: form.get('description').trim(), address: form.get('address').trim(), amenities: Object.fromEntries(Object.keys(amenityNames).map(key => [key, form.get(key) === 'on'])) };
    if (!property) Object.assign(body, { latitude: Number(latitude), longitude: Number(longitude), nearest_school_id: form.get('nearest_school_id') || null });
    try {
      const result = await api(property ? `/properties/${property.id}` : '/properties', { token, method: property ? 'PATCH' : 'POST', body });
      if (property) reload(); else navigate(`/landlord/${result.property.id}`, { replace: true });
    } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  function locate() {
    if (!navigator.geolocation) { setError('Location is unavailable. Enter coordinates manually.'); return; }
    setBusy(true); setError('');
    navigator.geolocation.getCurrentPosition(position => { setLatitude(position.coords.latitude.toFixed(7)); setLongitude(position.coords.longitude.toFixed(7)); setBusy(false); }, () => { setError('Location could not be accessed. Enter the property coordinates manually.'); setBusy(false); }, { timeout: 15000 });
  }
  return <div className="container editor-page"><Link to="/landlord" className="back-link"><ArrowLeft size={16} />My properties</Link><div className="page-heading"><p className="eyebrow">{property ? 'Make it feel like home' : 'A new home on Student Nest'}</p><h1>{property ? 'Manage your property' : 'Let’s put your place on the map.'}</h1><p className="muted">{property ? 'Keep your listing accurate and your room availability up to date.' : 'Start with the details. You’ll add rooms and photos in the next step.'}</p></div>{property && <div className="info-panel"><CheckCircle2 size={21} /><p><strong>{statusOf(property)}.</strong> Listings go live after admin review and verified payment. Editing property details sends the listing back for review.</p></div>}
    <div className="editor-layout"><section className="panel"><h2>Property details</h2><form onSubmit={submit}><Field label="Property name" name="title" required maxLength={220} defaultValue={property?.title} placeholder="e.g. Garden View Student Lodge" /><Field label="About the property"><textarea name="description" rows={5} maxLength={6000} defaultValue={property?.description} placeholder="Tell students what makes this a good place to live." /></Field><Field label="Street address / area" name="address" required maxLength={500} defaultValue={property?.address} placeholder="Street, area and town" />{!property && <><Field label="Nearest campus"><select name="nearest_school_id"><option value="">Select a campus (optional)</option>{schools.data?.schools?.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}</select></Field>{schools.error && <p className="error-message">Campus list unavailable. Please reload before selecting a campus.</p>}<div className="form-row"><Field label="Latitude" type="number" min={-90} max={90} step="any" required value={latitude} onChange={e => setLatitude(e.target.value)} /><Field label="Longitude" type="number" min={-180} max={180} step="any" required value={longitude} onChange={e => setLongitude(e.target.value)} /></div><button className="text-button" type="button" disabled={busy} onClick={locate}><MapPin size={16} />Use my current location</button><p className="form-hint">Use this while at the property, or copy its coordinates from Google Maps.</p></>}
      <fieldset className="amenity-fields"><legend>What’s included?</legend>{Object.entries(amenityNames).map(([key, label]) => <label key={key}><input type="checkbox" name={key} defaultChecked={property?.amenities?.[key] === true} />{label}</label>)}</fieldset>{error && <p className="error-message" role="alert">{error}</p>}<button className="button" disabled={busy}>{busy ? 'Saving…' : property ? 'Save details for review' : 'Save and add rooms'}<ArrowRight size={16} /></button></form></section><aside className="editor-aside">{property ? <><Rooms property={property} token={token} reload={reload} /><Photos property={property} token={token} reload={reload} /></> : <div className="panel guide-panel"><span className="step-number">01 / 03</span><h2>A clear listing makes all the difference.</h2><p>Use a recognisable name and an accurate address. Include the little things students need to know.</p><ol><li>Save your property details</li><li>Add room types and monthly rent</li><li>Upload clear photos of your space</li></ol><p>Then the admin team can review your listing.</p></div>}</aside></div>
  </div>;
}
function Rooms({ property, token, reload }) {
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  async function add(event) {
    event.preventDefault(); setBusy(true); setError('');
    const form = new FormData(event.currentTarget);
    const room = { room_type: form.get('room_type').trim(), price_per_month: Number(form.get('price_per_month')), students_per_room: Number(form.get('students_per_room')), total_rooms: Number(form.get('total_rooms')), available_rooms: Number(form.get('available_rooms')) };
    if (room.available_rooms > room.total_rooms) { setError('Available rooms cannot exceed total rooms.'); setBusy(false); return; }
    try { await api(`/properties/${property.id}/rooms`, { token, method: 'POST', body: { rooms: [room] } }); reload(); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  async function availability(event, room) {
    event.preventDefault(); setBusy(true); setError('');
    const available_rooms = Number(new FormData(event.currentTarget).get('available_rooms'));
    try { await api(`/properties/rooms/${room.id}`, { token, method: 'PATCH', body: { available_rooms } }); reload(); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  return <section className="panel"><h2>Rooms & availability</h2>{property.rooms?.map(room => <div className="manage-room" key={room.id}><div><h3>{room.room_type}</h3><p className="muted">{money(room.price_per_month)} / month · {room.students_per_room} per room</p></div><form className="availability-form" onSubmit={e => availability(e, room)}><Field label={`Available rooms — ${room.room_type}`} name="available_rooms" type="number" min={0} max={room.total_rooms} required defaultValue={room.available_rooms} /><button className="button secondary small" disabled={busy}>Update</button></form></div>)}{!property.rooms?.length && <p className="muted">Add your first room type to show pricing and availability.</p>}<details className="add-room" open={!property.rooms?.length}><summary><Plus size={16} />Add a room type</summary><form onSubmit={add}><Field label="Room type" name="room_type" required maxLength={120} placeholder="e.g. Double sharing" /><div className="form-row"><Field label="Monthly rent (K)" name="price_per_month" type="number" min={1} step="0.01" required /><Field label="Students per room" name="students_per_room" type="number" min={1} max={100} defaultValue={2} required /></div><div className="form-row"><Field label="Total rooms" name="total_rooms" type="number" min={1} defaultValue={1} required /><Field label="Available rooms" name="available_rooms" type="number" min={0} defaultValue={1} required /></div><button className="button secondary" disabled={busy}>{busy ? 'Saving…' : 'Add room type'}</button></form></details>{error && <p className="error-message" role="alert">{error}</p>}</section>;
}
function Photos({ property, token, reload }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  async function upload(event) {
    event.preventDefault(); setError('');
    const data = new FormData(event.currentTarget);
    const files = data.getAll('photos').filter(file => file.size);
    if (!files.length || files.length > 10 || files.some(file => file.size > 5 * 1024 * 1024 || !['image/jpeg', 'image/png', 'image/webp'].includes(file.type))) { setError('Choose 1–10 JPG, PNG or WebP photos, each under 5 MB.'); return; }
    if (!property.photos?.length) data.set('is_cover', 'true');
    setBusy(true);
    try { await api(`/photos/${property.id}`, { token, method: 'POST', body: data }); reload(); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  async function change(photo, remove = false) {
    if (remove && !window.confirm('Delete this photo from your listing?')) return;
    setBusy(true); setError('');
    try { await api(`/photos/${photo.id}${remove ? '' : '/cover'}`, { token, method: remove ? 'DELETE' : 'PATCH', body: remove ? undefined : { property_id: property.id } }); reload(); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  return <section className="panel"><h2>Show students around</h2><p className="muted">Add bright, clear photos of the actual property.</p><div className="manage-photos">{property.photos?.map(photo => <div key={photo.id}><PropertyImage url={photo.url} title="Property photo" /><div className="photo-actions"><button type="button" className="text-button" disabled={busy || photo.is_cover} onClick={() => change(photo)} aria-label={photo.is_cover ? 'Cover photo' : 'Set as cover'}><Star size={16} fill={photo.is_cover ? 'currentColor' : 'none'} />{photo.is_cover ? 'Cover' : 'Set cover'}</button><button type="button" className="text-button danger" disabled={busy} onClick={() => change(photo, true)} aria-label="Delete photo"><Trash2 size={16} /></button></div></div>)}</div><form onSubmit={upload}><Field label="Choose photos"><input name="photos" type="file" multiple accept="image/jpeg,image/png,image/webp" required /></Field><p className="form-hint">Up to 10 photos per upload. JPG, PNG or WebP, max 5 MB each.</p>{error && <p className="error-message" role="alert">{error}</p>}<button className="button secondary" disabled={busy}><Upload size={16} />{busy ? 'Uploading…' : 'Upload photos'}</button></form></section>;
}
