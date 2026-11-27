import { useState } from 'react';
import { Star, MessageSquareQuote, PenLine, ShieldCheck } from 'lucide-react';
import { api } from './api';
import { useResource, Field, Stars } from './components';
import { formatDate } from './utils';

export const ratingLabels = {
  rating_overall: 'Overall',
  rating_landlord: 'Landlord',
  rating_utilities: 'Water & power',
  rating_security: 'Security',
  rating_value: 'Value for money',
};
const monthYear = (value) => value ? new Date(value).toLocaleDateString('en-GB', { month: 'short', year: 'numeric', timeZone: 'Africa/Lusaka' }) : '';
const stayLabel = (r) => `Stayed ${monthYear(r.stay_from)} – ${r.stay_to ? monthYear(r.stay_to) : 'now'}`;

/** Accessible 1–5 star picker built on radio buttons. */
function StarInput({ name, label, value, onChange }) {
  return <fieldset className="star-input"><legend>{label}</legend>
    <div>{[1, 2, 3, 4, 5].map(n => <label key={n} className={value >= n ? 'on' : ''}>
      <input type="radio" name={name} value={n} checked={value === n} onChange={() => onChange(n)} required />
      <Star size={24} aria-hidden="true" /><span className="sr-only">{n} star{n === 1 ? '' : 's'}</span>
    </label>)}</div>
  </fieldset>;
}

/** "What past tenants say" section on a home's page. */
export function PropertyReviews({ property }) {
  const [refresh, setRefresh] = useState(0);
  const resource = useResource(`/reviews?property_id=${encodeURIComponent(property.id)}`, undefined, refresh);
  const [writing, setWriting] = useState(false);
  const [thanks, setThanks] = useState('');
  const summary = resource.data?.summary;
  const list = resource.data?.reviews || [];

  return <section className="detail-section reviews-section" aria-labelledby="reviews-title">
    <div className="reviews-heading"><h2 id="reviews-title">What past tenants say</h2>{!writing && !thanks && <button className="button secondary small" onClick={() => setWriting(true)}><PenLine size={16} />Write a review</button>}</div>
    {resource.error ? <p className="inline-note">Reviews couldn’t be loaded right now. <button className="text-button" onClick={() => setRefresh(r => r + 1)}>Retry</button></p>
      : summary?.count > 0 ? <div className="review-summary">
        <div className="review-score"><strong>{Number(summary.rating_overall).toFixed(1)}</strong><Stars value={summary.rating_overall} size={18} /><span>{summary.count} review{summary.count === 1 ? '' : 's'}</span></div>
        <dl className="review-bars">{Object.entries(ratingLabels).filter(([key]) => key !== 'rating_overall').map(([key, label]) => <div key={key}><dt>{label}</dt><dd><span className="bar"><i style={{ width: `${(Number(summary[key]) / 5) * 100}%` }} /></span><b>{Number(summary[key]).toFixed(1)}</b></dd></div>)}</dl>
      </div>
      : !resource.loading && !writing && !thanks && <p className="muted">No reviews yet. Lived here? Your review helps the next student decide.</p>}
    {thanks && <div className="pay-status success" role="status"><ShieldCheck size={24} /><div><h3>Thanks for your review</h3><p>{thanks}</p></div></div>}
    {writing && <ReviewForm propertyId={property.id} onCancel={() => setWriting(false)} onDone={message => { setWriting(false); setThanks(message); }} />}
    {list.length > 0 && <ul className="review-list">{list.map(review => <li key={review.id}>
      <header><Stars value={review.rating_overall} /><strong>{review.reviewer_name}</strong><span>{stayLabel(review)}</span></header>
      <p>{review.comment}</p>
      {review.landlord_reply && <blockquote className="landlord-reply"><MessageSquareQuote size={16} aria-hidden="true" /><div><strong>Landlord’s reply</strong><p>{review.landlord_reply}</p></div></blockquote>}
    </li>)}</ul>}
  </section>;
}

function ReviewForm({ propertyId, onCancel, onDone }) {
  const [ratings, setRatings] = useState({});
  const [stillHere, setStillHere] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const thisMonth = new Date().toISOString().slice(0, 7);
  async function submit(event) {
    event.preventDefault(); setError('');
    if (Object.keys(ratingLabels).some(key => !ratings[key])) { setError('Give every rating from 1 to 5 stars.'); return; }
    const form = Object.fromEntries(new FormData(event.currentTarget));
    setBusy(true);
    try {
      const result = await api('/reviews', { method: 'POST', body: { property_id: propertyId, reviewer_name: form.reviewer_name, phone: form.phone, stay_from: form.stay_from, stay_to: stillHere ? null : form.stay_to || null, comment: form.comment, ...ratings } });
      onDone(result.message);
    } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  return <form className="review-form" onSubmit={submit}>
    <p className="form-hint review-hint">Reviews are for students who lived here. Our team confirms your stay before your review appears.</p>
    <div className="star-grid">{Object.entries(ratingLabels).map(([key, label]) => <StarInput key={key} name={key} label={label} value={ratings[key] || 0} onChange={n => setRatings(r => ({ ...r, [key]: n }))} />)}</div>
    <div className="form-row"><Field label="Moved in" name="stay_from" type="month" max={thisMonth} required /><Field label="Moved out" name="stay_to" type="month" max={thisMonth} disabled={stillHere} required={!stillHere} /></div>
    <label className="check-filter still-here"><input type="checkbox" checked={stillHere} onChange={e => setStillHere(e.target.checked)} /><span>I still live here</span></label>
    <Field label="Your review"><textarea name="comment" rows={4} minLength={20} maxLength={1000} required placeholder="Water and electricity, the landlord, security, noise, distance to campus…" /></Field>
    <div className="form-row"><Field label="Name to show (optional)" name="reviewer_name" maxLength={60} placeholder="e.g. Mutale, or leave blank" /><Field label="Phone (private)" name="phone" type="tel" inputMode="tel" required placeholder="e.g. 0971234567" /></div>
    <p className="form-hint">Your phone number is never shown. Our team may call to confirm you stayed here.</p>
    {error && <p className="error-message" role="alert">{error}</p>}
    <div className="form-actions"><button className="button" disabled={busy}>{busy ? 'Sending…' : 'Submit review'}</button><button type="button" className="text-button" onClick={onCancel}>Cancel</button></div>
  </form>;
}

/** Landlord's listing page: read reviews and reply publicly. */
export function LandlordReviews({ property, token }) {
  const [refresh, setRefresh] = useState(0);
  const resource = useResource(`/reviews?property_id=${encodeURIComponent(property.id)}`, undefined, refresh);
  const list = resource.data?.reviews || [];
  if (resource.loading && !resource.data) return null;
  return <section className="panel"><h2>Tenant reviews</h2>
    {resource.data?.summary?.count > 0 && <p className="muted">Average <strong>{Number(resource.data.summary.rating_overall).toFixed(1)}</strong> from {resource.data.summary.count} review{resource.data.summary.count === 1 ? '' : 's'}. Replies are public. A polite, specific reply reassures future tenants.</p>}
    {!list.length ? <p className="muted">No approved reviews yet. Reviews appear here after our team confirms the tenant’s stay.</p>
      : <ul className="review-list compact">{list.map(review => <LandlordReviewItem key={review.id} review={review} token={token} onSaved={() => setRefresh(r => r + 1)} />)}</ul>}
  </section>;
}

function LandlordReviewItem({ review, token, onSaved }) {
  const [editing, setEditing] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  async function save(event) {
    event.preventDefault(); setBusy(true); setError('');
    try { await api(`/reviews/${review.id}/reply`, { token, method: 'PUT', body: { reply: new FormData(event.currentTarget).get('reply') } }); setEditing(false); onSaved(); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  return <li>
    <header><Stars value={review.rating_overall} /><strong>{review.reviewer_name}</strong><span>{stayLabel(review)}</span></header>
    <p>{review.comment}</p>
    {editing ? <form onSubmit={save}><Field label="Your public reply"><textarea name="reply" rows={3} maxLength={1000} defaultValue={review.landlord_reply || ''} /></Field>{error && <p className="error-message" role="alert">{error}</p>}<div className="form-actions"><button className="button secondary small" disabled={busy}>{busy ? 'Saving…' : 'Save reply'}</button><button type="button" className="text-button" onClick={() => setEditing(false)}>Cancel</button></div></form>
      : <>{review.landlord_reply && <blockquote className="landlord-reply"><MessageSquareQuote size={16} aria-hidden="true" /><div><strong>Your reply · {formatDate(review.landlord_reply_at)}</strong><p>{review.landlord_reply}</p></div></blockquote>}<button className="text-button" onClick={() => setEditing(true)}>{review.landlord_reply ? 'Edit reply' : 'Reply'}</button></>}
  </li>;
}
