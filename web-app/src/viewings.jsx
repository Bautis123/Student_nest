import { useState } from 'react';
import { CalendarCheck, MessageCircle, Check, X } from 'lucide-react';
import { api } from './api';
import { useResource, Field } from './components';

const times = { morning: 'Morning', afternoon: 'Afternoon', evening: 'Evening' };
const timeHints = { morning: '8am–12pm', afternoon: '12–4pm', evening: '4–6pm' };
const lusakaToday = () => new Intl.DateTimeFormat('en-CA', { timeZone: 'Africa/Lusaka', year: 'numeric', month: '2-digit', day: '2-digit' }).format(new Date());
const plusDays = (iso, n) => { const d = new Date(`${iso}T12:00:00Z`); d.setUTCDate(d.getUTCDate() + n); return d.toISOString().slice(0, 10); };
const dayLabel = (iso) => new Date(`${String(iso).slice(0, 10)}T12:00:00Z`).toLocaleDateString('en-GB', { weekday: 'short', day: 'numeric', month: 'short', timeZone: 'UTC' });

/** "Book a viewing" in a home's contact card. */
export function BookViewing({ property }) {
  const [open, setOpen] = useState(false);
  const [time, setTime] = useState('afternoon');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [booked, setBooked] = useState(null);
  const today = lusakaToday();

  async function submit(event) {
    event.preventDefault(); setBusy(true); setError('');
    const form = Object.fromEntries(new FormData(event.currentTarget));
    try {
      setBooked(await api('/viewings', { method: 'POST', body: { property_id: property.id, student_name: form.student_name, student_phone: form.student_phone, preferred_date: form.preferred_date, preferred_time: time, message: form.message } }));
      setOpen(false);
    } catch (err) { setError(err.message); } finally { setBusy(false); }
  }

  if (booked) return <div className="viewing-booked" role="status">
    <p className="viewing-booked-title"><CalendarCheck size={18} aria-hidden="true" />Viewing request sent</p>
    <p>{booked.landlord_name || 'The landlord'} can see your request for <strong>{dayLabel(booked.request.preferred_date)}, {times[booked.request.preferred_time].toLowerCase()}</strong>. Send it on WhatsApp too so they reply faster.</p>
    {booked.whatsapp_link && <a className="button full" href={booked.whatsapp_link} target="_blank" rel="noreferrer"><MessageCircle size={17} />Send request on WhatsApp</a>}
  </div>;

  if (!open) return <button type="button" className="button secondary full book-viewing" onClick={() => setOpen(true)}><CalendarCheck size={17} />Book a viewing</button>;

  return <form className="viewing-form" onSubmit={submit}>
    <p className="viewing-form-title"><CalendarCheck size={17} aria-hidden="true" />Book a viewing</p>
    <Field label="Your name" name="student_name" required minLength={2} maxLength={60} autoComplete="given-name" />
    <Field label="Your WhatsApp number" name="student_phone" type="tel" inputMode="tel" required placeholder="e.g. 0971234567" autoComplete="tel" />
    <Field label="Day" name="preferred_date" type="date" required min={today} max={plusDays(today, 60)} defaultValue={plusDays(today, 1)} />
    <fieldset className="time-options"><legend>Time of day</legend>{Object.entries(times).map(([value, label]) => <label key={value} className={time === value ? 'selected' : ''}><input type="radio" name="preferred_time" value={value} checked={time === value} onChange={() => setTime(value)} /><span>{label}</span><small>{timeHints[value]}</small></label>)}</fieldset>
    <Field label="Message (optional)"><textarea name="message" rows={2} maxLength={500} placeholder="e.g. Is the twin room still available?" /></Field>
    {error && <p className="error-message" role="alert">{error}</p>}
    <div className="form-actions"><button className="button" disabled={busy}>{busy ? 'Sending…' : 'Send request'}</button><button type="button" className="text-button" onClick={() => setOpen(false)}>Cancel</button></div>
  </form>;
}

const statusLabels = { pending: 'Waiting for you', confirmed: 'Confirmed', declined: 'Declined' };

/** Landlord dashboard inbox of viewing requests across all their homes. */
export function LandlordViewings({ token }) {
  const [refresh, setRefresh] = useState(0);
  const resource = useResource('/viewings/mine', token, refresh);
  const requests = resource.data?.requests || [];
  const waiting = requests.filter(r => r.status === 'pending').length;
  if (resource.loading && !resource.data) return null;
  if (resource.error) return <p className="inline-note">Viewing requests couldn’t be loaded. <button className="text-button" onClick={() => setRefresh(r => r + 1)}>Retry</button></p>;
  return <section className="viewings-panel" aria-labelledby="viewings-title">
    <div className="results-heading"><h2 id="viewings-title">Viewing requests{waiting > 0 && <span>{waiting} new</span>}</h2><button className="text-button" onClick={() => setRefresh(r => r + 1)}>Refresh</button></div>
    {!requests.length ? <p className="muted">When students ask to view one of your homes, their requests appear here.</p>
      : <ul className="viewing-list">{requests.map(request => <ViewingItem key={request.id} request={request} token={token} onChange={() => setRefresh(r => r + 1)} />)}</ul>}
  </section>;
}

function ViewingItem({ request, token, onChange }) {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [note, setNote] = useState('');
  async function answer(status) {
    setBusy(true); setError('');
    try { await api(`/viewings/${request.id}`, { token, method: 'PATCH', body: { status, note } }); onChange(); } catch (err) { setError(err.message); setBusy(false); }
  }
  return <li className={`viewing-item ${request.status}`}>
    <header><strong>{request.student_name}</strong><span className={`pay-pill ${request.status === 'pending' ? '' : request.status === 'confirmed' ? 'confirmed' : 'failed'}`}>{statusLabels[request.status]}</span></header>
    <p className="viewing-when"><CalendarCheck size={15} aria-hidden="true" />{request.when}</p>
    <p className="muted">{request.property_title}</p>
    {request.message && <p className="viewing-message">“{request.message}”</p>}
    {request.status === 'pending' ? <>
      <Field label="Note to student (optional)"><input value={note} onChange={e => setNote(e.target.value)} maxLength={300} placeholder="e.g. Ask for Jane at the gate" /></Field>
      <div className="viewing-actions">
        <button className="button small" disabled={busy} onClick={() => answer('confirmed')}><Check size={15} />Confirm</button>
        <button className="button secondary small" disabled={busy} onClick={() => answer('declined')}><X size={15} />Decline</button>
        <a className="text-button" href={request.reply_link} target="_blank" rel="noreferrer"><MessageCircle size={15} />Chat with {request.student_name}</a>
      </div>
    </> : <div className="viewing-actions"><a className="button secondary small" href={request.reply_link} target="_blank" rel="noreferrer"><MessageCircle size={15} />Send {request.status === 'confirmed' ? 'confirmation' : 'reply'} on WhatsApp</a></div>}
    {error && <p className="error-message" role="alert">{error}</p>}
  </li>;
}
