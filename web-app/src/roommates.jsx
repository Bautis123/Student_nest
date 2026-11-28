import { useState } from 'react';
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { Users, Plus, MessageCircle, Flag, ShieldCheck, Copy, Check, ArrowLeft, Trash2, GraduationCap, CalendarDays, Wallet } from 'lucide-react';
import { api } from './api';
import { useResource, Loading, ErrorState, Empty, Field } from './components';
import { money, formatDate } from './utils';

export const tagNames = { quiet: 'Quiet', non_smoker: 'Non-smoker', early_riser: 'Early riser', night_owl: 'Night owl', tidy: 'Tidy', studious: 'Studious', social: 'Social', cooks: 'Likes cooking', religious: 'Religious', pets_ok: 'Pets OK' };
const shareLabels = { female: 'Sharing with women', male: 'Sharing with men', any: 'Open to anyone' };
const SAFETY_TIPS = 'Meet in a public place first, view rooms together, and never send money or ID documents to someone you haven’t met. Report anything suspicious.';

/** Browse approved roommate requests. */
export function RoommatesPage() {
  const [params, setParams] = useSearchParams();
  const school = params.get('school') || '';
  const budget = params.get('budget') || '';
  const share = params.get('share') || '';
  const [refresh, setRefresh] = useState(0);
  const schools = useResource('/properties/schools');
  const query = new URLSearchParams({ ...(school && { school_id: school }), ...(budget && { max_budget: budget }), ...(share && { share_with: share }) });
  const posts = useResource(`/roommates?${query}`, undefined, refresh);
  const update = (name, value) => setParams(prev => { const next = new URLSearchParams(prev); value ? next.set(name, value) : next.delete(name); return next; }, { replace: true });
  const list = posts.data?.posts || [];

  return <div className="container roommates-page">
    <section className="page-heading heading-with-action"><div><p className="eyebrow">Find someone to share with</p><h1>Split the rent. Share the journey.</h1><p className="muted">Students looking for a roommate near campus. Every request is reviewed by the Student Nest team before it appears.</p></div><Link className="button" to="/roommates/new"><Plus size={18} />Post a request</Link></section>
    <div className="info-panel"><ShieldCheck size={21} /><p><strong>Stay safe.</strong> {SAFETY_TIPS}</p></div>
    <div className="roommate-filters">
      <Field label="Campus"><select value={school} onChange={e => update('school', e.target.value)}><option value="">All campuses</option>{schools.data?.schools?.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}</select></Field>
      <Field label="Their budget up to (K / month)" type="number" min="0" placeholder="Any" value={budget} onChange={e => update('budget', e.target.value)} />
      <Field label="Show people who’d share with"><select value={share} onChange={e => update('share', e.target.value)}><option value="">Anyone</option><option value="female">A woman</option><option value="male">A man</option></select></Field>
    </div>
    <div className="results-heading"><h2>Looking for a roommate<span>{!posts.loading && !posts.error && list.length}</span></h2></div>
    {posts.loading ? <Loading label="Finding students near you…" /> : posts.error ? <ErrorState message={posts.error} retry={() => setRefresh(r => r + 1)} /> : list.length ? <div className="roommate-grid">{list.map(post => <RoommateCard key={post.id} post={post} />)}</div> : <Empty title="No roommate requests here yet">Be the first: <Link to="/roommates/new">post a request</Link> and others at your campus can find you.</Empty>}
  </div>;
}

function RoommateCard({ post }) {
  const [contact, setContact] = useState(null);
  const [reporting, setReporting] = useState(false);
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  async function reveal() {
    setBusy(true); setMessage('');
    try { setContact(await api(`/roommates/${post.id}/contact`)); } catch (err) { setMessage(err.message); } finally { setBusy(false); }
  }
  async function report(event) {
    event.preventDefault(); setBusy(true);
    try { const r = await api(`/roommates/${post.id}/report`, { method: 'POST', body: { reason: new FormData(event.currentTarget).get('reason') } }); setMessage(r.message); setReporting(false); } catch (err) { setMessage(err.message); } finally { setBusy(false); }
  }
  return <article className="roommate-card">
    <header><span className="avatar">{post.display_name.slice(0, 1).toUpperCase()}</span><div><h3>{post.display_name}</h3><p className="muted">{shareLabels[post.share_with]}</p></div></header>
    <dl className="roommate-facts">
      <div><dt><GraduationCap size={15} />Campus</dt><dd>{post.school_name || 'Any campus'}</dd></div>
      <div><dt><Wallet size={15} />Budget</dt><dd>up to {money(post.budget_max)} / month</dd></div>
      {post.move_in && <div><dt><CalendarDays size={15} />Move in</dt><dd>{formatDate(post.move_in)}</dd></div>}
    </dl>
    {post.about && <p className="roommate-about">{post.about}</p>}
    {post.tags?.length > 0 && <ul className="tag-list" aria-label="Lifestyle">{post.tags.map(tag => <li key={tag}>{tagNames[tag] || tag}</li>)}</ul>}
    <footer>
      {contact ? <a className="button small" href={contact.whatsapp} target="_blank" rel="noreferrer"><MessageCircle size={16} />WhatsApp {contact.phone}</a> : <button className="button small" onClick={reveal} disabled={busy}><MessageCircle size={16} />Show WhatsApp</button>}
      <button className="text-button report-link" onClick={() => setReporting(r => !r)} aria-expanded={reporting}><Flag size={14} />Report</button>
    </footer>
    {reporting && <form className="report-form" onSubmit={report}><Field label="What’s wrong with this post?"><textarea name="reason" rows={2} maxLength={500} placeholder="e.g. asked for money, fake details" /></Field><button className="button secondary small" disabled={busy}>Send report</button></form>}
    {message && <p className="inline-note" role="status">{message}</p>}
  </article>;
}

/** Shared create/edit form. */
function RoommateForm({ initial = {}, submitLabel, busy, error, onSubmit }) {
  const schools = useResource('/properties/schools');
  const [tags, setTags] = useState(initial.tags || []);
  // Controlled: campuses load asynchronously, and an uncontrolled select would fall
  // back to the first campus before its saved value's option exists.
  const [schoolId, setSchoolId] = useState(initial.school_id || '');
  const toggle = tag => setTags(current => current.includes(tag) ? current.filter(t => t !== tag) : [...current, tag]);
  function submit(event) {
    event.preventDefault();
    const form = Object.fromEntries(new FormData(event.currentTarget));
    onSubmit({ ...form, budget_max: Number(form.budget_max), tags });
  }
  return <form className="panel roommate-form" onSubmit={submit}>
    <div className="form-row"><Field label="First name" name="display_name" required minLength={2} maxLength={60} defaultValue={initial.display_name} autoComplete="given-name" /><Field label="Campus"><select name="school_id" required value={schoolId} onChange={e => setSchoolId(e.target.value)}><option value="" disabled>Choose your campus</option>{schools.data?.schools?.map(s => <option key={s.id} value={s.id}>{s.name}</option>)}</select></Field></div>
    <div className="form-row"><Field label="I am"><select name="gender" required defaultValue={initial.gender || ''}><option value="" disabled>Choose</option><option value="female">A woman</option><option value="male">A man</option><option value="unspecified">Prefer not to say</option></select></Field><Field label="I’d share with"><select name="share_with" required defaultValue={initial.share_with || 'any'}><option value="any">Anyone</option><option value="female">Women only</option><option value="male">Men only</option></select></Field></div>
    <div className="form-row"><Field label="Budget (K/month)" name="budget_max" type="number" min="1" step="1" required defaultValue={initial.budget_max ? Math.round(initial.budget_max) : ''} /><Field label="Move-in (optional)" name="move_in" type="date" defaultValue={initial.move_in ? String(initial.move_in).slice(0, 10) : ''} /></div>
    <Field label="About me (optional)"><textarea name="about" rows={3} maxLength={500} defaultValue={initial.about || ''} placeholder="Course and year, what you’re looking for in a roommate…" /></Field>
    <fieldset className="tag-picker"><legend>Lifestyle</legend>{Object.entries(tagNames).map(([tag, label]) => <label key={tag} className={tags.includes(tag) ? 'selected' : ''}><input type="checkbox" checked={tags.includes(tag)} onChange={() => toggle(tag)} />{label}</label>)}</fieldset>
    <Field label="WhatsApp number" name="phone" type="tel" inputMode="tel" required defaultValue={initial.phone} placeholder="e.g. 0971234567" autoComplete="tel" />
    <p className="form-hint">Your number stays hidden until a student taps “Show WhatsApp” on your approved post.</p>
    {error && <p className="error-message" role="alert">{error}</p>}
    <button className="button" disabled={busy}>{busy ? 'Please wait…' : submitLabel}</button>
  </form>;
}

function ManageLink({ token }) {
  const [copied, setCopied] = useState(false);
  const link = `${window.location.origin}/roommates/manage/${token}`;
  async function copy() { try { await navigator.clipboard.writeText(link); setCopied(true); } catch { setCopied(false); } }
  return <div className="manage-link">
    <p><strong>Save your private link.</strong> It’s the only way to edit or remove your post, and anyone who has it can change your post. We can’t show it again.</p>
    <code>{link}</code>
    <div className="manage-link-actions"><button type="button" className="button secondary small" onClick={copy}>{copied ? <Check size={15} /> : <Copy size={15} />}{copied ? 'Copied' : 'Copy link'}</button><a className="button secondary small" href={`https://wa.me/?text=${encodeURIComponent(`My Student Nest roommate post (keep private): ${link}`)}`} target="_blank" rel="noreferrer"><MessageCircle size={15} />Send to myself on WhatsApp</a></div>
  </div>;
}

export function NewRoommatePost() {
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [token, setToken] = useState('');
  async function submit(body) {
    setBusy(true); setError('');
    try { const result = await api('/roommates', { method: 'POST', body }); setToken(result.manage_token); window.scrollTo(0, 0); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  return <div className="container narrow-page">
    <Link className="back-link" to="/roommates"><ArrowLeft size={16} />Roommates</Link>
    {token ? <div className="panel"><div className="pay-status success"><Check size={26} /><div><h3>Request sent for review</h3><p>The Student Nest team checks every request, usually within a day. Once approved it’s visible for 30 days.</p></div></div><ManageLink token={token} /><Link className="text-button" to={`/roommates/manage/${token}`}>Open my post</Link></div>
      : <><div className="page-heading"><p className="eyebrow">Roommate request</p><h1>Tell students who you are.</h1><p className="muted">No account needed. Keep it friendly and honest — don’t include your ID number, address or bank details.</p></div><RoommateForm submitLabel="Send for review" busy={busy} error={error} onSubmit={submit} /></>}
  </div>;
}

const statusText = {
  pending: 'Waiting for review. Students can’t see it yet.',
  approved: 'Live. Students can see it',
  rejected: 'Not approved',
};

export function ManageRoommatePost() {
  const { token } = useParams();
  const navigate = useNavigate();
  const [refresh, setRefresh] = useState(0);
  const resource = useResource(`/roommates/manage/${encodeURIComponent(token)}`, undefined, refresh);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [saved, setSaved] = useState(false);
  if (resource.loading && !resource.data) return <Loading label="Opening your post…" />;
  if (resource.error) return <div className="container narrow-page"><ErrorState message={resource.error} /><Link className="button" to="/roommates">Browse roommates</Link></div>;
  const post = resource.data.post;
  async function save(body) {
    setBusy(true); setError(''); setSaved(false);
    try { await api(`/roommates/manage/${encodeURIComponent(token)}`, { method: 'PATCH', body }); setSaved(true); setRefresh(r => r + 1); } catch (err) { setError(err.message); } finally { setBusy(false); }
  }
  async function remove() {
    if (!window.confirm('Remove your roommate post? This can’t be undone.')) return;
    setBusy(true);
    try { await api(`/roommates/manage/${encodeURIComponent(token)}`, { method: 'DELETE' }); navigate('/roommates', { replace: true }); } catch (err) { setError(err.message); setBusy(false); }
  }
  return <div className="container narrow-page">
    <Link className="back-link" to="/roommates"><ArrowLeft size={16} />Roommates</Link>
    <div className="page-heading"><p className="eyebrow">Your roommate post</p><h1>Hi {post.display_name}.</h1></div>
    <div className={`info-panel status-${post.status}`}><Users size={21} /><p><strong>{statusText[post.status]}{post.status === 'approved' && post.expires_at ? ` until ${formatDate(post.expires_at)}.` : ''}</strong>{post.review_note && <> Note from the team: {post.review_note}</>} Saving changes sends your post for review again.</p></div>
    {saved && <p className="inline-note" role="status">Saved. Your post is back in the review queue.</p>}
    <RoommateForm key={`${post.id}-${refresh}`} initial={post} submitLabel="Save and send for review" busy={busy} error={error} onSubmit={save} />
    <button type="button" className="text-button danger remove-post" onClick={remove} disabled={busy}><Trash2 size={15} />Remove my post</button>
  </div>;
}
