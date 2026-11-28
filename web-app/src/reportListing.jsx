import { useState } from 'react';
import { Flag, ShieldAlert, Check } from 'lucide-react';
import { api } from './api';
import { Field } from './components';

const reasons = {
  upfront_payment: 'Asked me to pay before a viewing',
  fake_listing: 'The home doesn’t exist or isn’t available',
  misleading: 'Photos, price or details are misleading',
  impersonation: 'Someone is pretending to be the landlord',
  other: 'Something else',
};

/** Scam-safety tips plus a "Report this listing" form, shown in the contact card. */
export function ListingSafety({ propertyId }) {
  const [open, setOpen] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [done, setDone] = useState('');

  async function submit(event) {
    event.preventDefault(); setBusy(true); setError('');
    const form = Object.fromEntries(new FormData(event.currentTarget));
    try {
      const result = await api(`/properties/${encodeURIComponent(propertyId)}/report`, { method: 'POST', body: { reason: form.reason, details: form.details, phone: form.phone || undefined } });
      setDone(result.message); setOpen(false);
    } catch (err) { setError(err.message); } finally { setBusy(false); }
  }

  return <div className="safety-box">
    <p className="safety-title"><ShieldAlert size={17} aria-hidden="true" />Stay safe</p>
    <ul>
      <li>Never pay a deposit or rent before you have viewed the room in person.</li>
      <li>Student Nest never asks you to pay landlords through us or by a separate link.</li>
      <li>Be wary of prices far below others nearby, or pressure to decide today.</li>
    </ul>
    {done ? <p className="report-done" role="status"><Check size={16} aria-hidden="true" />{done}</p>
      : !open ? <button type="button" className="text-button report-listing" onClick={() => setOpen(true)}><Flag size={15} aria-hidden="true" />Report this listing</button>
        : <form className="report-listing-form" onSubmit={submit}>
          <fieldset className="report-reasons"><legend>What’s wrong?</legend>{Object.entries(reasons).map(([value, label], index) => <label key={value}><input type="radio" name="reason" value={value} required defaultChecked={index === 0} />{label}</label>)}</fieldset>
          <Field label="Details (optional)"><textarea name="details" rows={3} maxLength={1000} placeholder="What happened? e.g. asked for K500 by mobile money to hold the room" /></Field>
          <Field label="Your phone (optional, private)" name="phone" type="tel" inputMode="tel" placeholder="So our team can follow up" />
          {error && <p className="error-message" role="alert">{error}</p>}
          <div className="form-actions"><button className="button small" disabled={busy}>{busy ? 'Sending…' : 'Send report'}</button><button type="button" className="text-button" onClick={() => setOpen(false)}>Cancel</button></div>
        </form>}
  </div>;
}
