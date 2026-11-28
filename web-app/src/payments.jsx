import { useEffect, useRef, useState } from 'react';
import { CheckCircle2, Smartphone, LoaderCircle, AlertCircle, RotateCw, Sparkles } from 'lucide-react';
import { api } from './api';
import { useResource, Field } from './components';
import { money, detectOperator, operatorNames, formatDate } from './utils';

const POLL_INTERVAL_MS = 4000;
const POLL_TIMEOUT_MS = 3 * 60 * 1000;
const statusLabels = { pending: 'Waiting for approval', confirmed: 'Paid', failed: 'Not completed' };

/** Landlord pays the listing fee by mobile money; the listing goes live when the payment confirms. */
export function ListingPayment({ property, token, phone: accountPhone, reload }) {
  const plans = useResource('/payments/plans');
  const [historyRefresh, setHistoryRefresh] = useState(0);
  const history = useResource(`/payments/mine?property_id=${encodeURIComponent(property.id)}`, token, historyRefresh);
  const [planId, setPlanId] = useState('basic');
  const [phone, setPhone] = useState(accountPhone || '');
  const [operator, setOperator] = useState(detectOperator(accountPhone));
  const [payment, setPayment] = useState(null);
  const [waitedTooLong, setWaitedTooLong] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const pollStartedAt = useRef(0);
  const reloadRef = useRef(reload); // parent passes a new function each render
  reloadRef.current = reload;

  // While a payment waits for the landlord to approve it on their phone, check it regularly.
  useEffect(() => {
    if (payment?.status !== 'pending') return undefined;
    pollStartedAt.current = pollStartedAt.current || Date.now();
    const timer = setInterval(async () => {
      if (Date.now() - pollStartedAt.current > POLL_TIMEOUT_MS) { setWaitedTooLong(true); clearInterval(timer); return; }
      try {
        const { payment: latest } = await api(`/payments/${payment.id}`, { token });
        if (latest.status !== 'pending') {
          setPayment(latest); setHistoryRefresh(r => r + 1);
          if (latest.status === 'confirmed') reloadRef.current?.();
        }
      } catch { /* transient: try again on the next tick */ }
    }, POLL_INTERVAL_MS);
    return () => clearInterval(timer);
  }, [payment?.id, payment?.status, token]);

  async function pay(event) {
    event.preventDefault(); setBusy(true); setError(''); setWaitedTooLong(false); pollStartedAt.current = 0;
    try {
      const result = await api('/payments/listing', { token, method: 'POST', body: { property_id: property.id, plan: planId, phone, operator } });
      setPayment(result.payment); setHistoryRefresh(r => r + 1);
    } catch (err) {
      if (err.status === 409 && err.data?.payment_id) {
        const { payment: existing } = await api(`/payments/${err.data.payment_id}`, { token }).catch(() => ({}));
        if (existing) { setPayment(existing); return; }
      }
      setError(err.message);
    } finally { setBusy(false); }
  }
  function checkAgain() { setWaitedTooLong(false); pollStartedAt.current = 0; setPayment(p => ({ ...p })); }
  function startOver() { setPayment(null); setError(''); }

  if (plans.loading) return null;
  const available = plans.data?.plans || [];
  const plan = available.find(p => p.id === planId) || available[0];
  const liveUntil = property.listing_expires_at && new Date(property.listing_expires_at) > new Date() ? property.listing_expires_at : null;

  let body;
  if (!plans.data?.enabled) {
    body = <p className="muted">In-app payments are coming soon. For now, the Student Nest team will contact you to arrange payment once your listing is approved.</p>;
  } else if (!property.is_approved) {
    body = <p className="muted">Payment opens as soon as an admin approves your listing. We review new listings to keep Student Nest safe for students.</p>;
  } else if (payment?.status === 'pending') {
    body = <div className="pay-status pending" role="status" aria-live="polite">
      {waitedTooLong ? <AlertCircle size={28} /> : <Smartphone size={28} />}
      <div><h3>{waitedTooLong ? 'Still waiting for your approval' : 'Check your phone'}</h3>
        <p>{waitedTooLong ? 'We haven’t received a confirmation yet. If you approved it, check again in a moment.' : <>Approve the {money(payment.amount)} payment on <strong>{payment.phone}</strong> by entering your {operatorNames[payment.mobile_money_provider] || 'mobile money'} PIN.</>}</p>
        {waitedTooLong ? <button type="button" className="button secondary small" onClick={checkAgain}><RotateCw size={15} />Check again</button> : <p className="pay-waiting"><LoaderCircle className="spin" size={15} />Waiting for confirmation…</p>}
      </div></div>;
  } else if (payment?.status === 'confirmed') {
    body = <div className="pay-status success" role="status"><CheckCircle2 size={28} /><div><h3>Payment received. Your listing is live!</h3><p>{money(payment.amount)} paid. Students can see your listing until <strong>{formatDate(payment.expires_at)}</strong>.</p></div></div>;
  } else {
    body = <form onSubmit={pay}>
      {payment?.status === 'failed' && <div className="pay-status failed" role="alert"><AlertCircle size={24} /><div><h3>Payment not completed</h3><p>{`${(payment.failure_reason || 'The payment was declined or cancelled').replace(/[.\s]+$/, '')}.`} You have not been charged. Please try again.</p></div></div>}
      <fieldset className="plan-options"><legend>Choose a plan</legend>{available.map(option => <label key={option.id} className={`plan-option ${planId === option.id ? 'selected' : ''}`}>
        <input type="radio" name="plan" value={option.id} checked={planId === option.id} onChange={() => setPlanId(option.id)} />
        <span className="plan-name">{option.id === 'premium' && <Sparkles size={15} />}{option.name}</span>
        <strong>{money(option.amount)}<small> / {option.months} months</small></strong>
        <span className="plan-description">{option.description}</span>
      </label>)}</fieldset>
      <div className="form-row">
        <Field label="Mobile money number" name="phone" type="tel" inputMode="tel" autoComplete="tel" required value={phone} placeholder="e.g. 0971234567" onChange={e => { setPhone(e.target.value); const detected = detectOperator(e.target.value); if (detected) setOperator(detected); }} />
        <Field label="Network"><select name="operator" required value={operator} onChange={e => setOperator(e.target.value)}><option value="">Select network</option>{Object.entries(operatorNames).map(([id, name]) => <option key={id} value={id}>{name}</option>)}</select></Field>
      </div>
      {error && <p className="error-message" role="alert">{error}</p>}
      <button className="button full" disabled={busy || !plan}>{busy ? 'Sending request…' : `Pay ${money(plan?.amount)} with mobile money`}</button>
      <p className="form-hint pay-hint">You’ll get a prompt on your phone to approve the payment with your PIN. Student Nest never asks for your PIN.</p>
    </form>;
  }

  const past = (history.data?.payments || []).filter(p => p.id !== payment?.id || p.status !== 'pending').slice(0, 5);
  return <section className="panel" aria-labelledby="pay-title">
    <h2 id="pay-title">Listing plan & payment</h2>
    {liveUntil && <p className="muted">Live until {formatDate(liveUntil)}. Paying again adds another 12 months.</p>}
    {body}
    {payment?.status === 'confirmed' && <button type="button" className="text-button" onClick={startOver}>Make another payment</button>}
    {past.length > 0 && <details className="pay-history"><summary>Payment history</summary><ul>{past.map(p => <li key={p.id}><span>{formatDate(p.paid_at || p.created_at)} · {p.plan ? p.plan[0].toUpperCase() + p.plan.slice(1) : 'Listing fee'}</span><span>{money(p.amount)} <em className={`pay-pill ${p.status}`}>{statusLabels[p.status] || p.status}</em></span></li>)}</ul></details>}
  </section>;
}
