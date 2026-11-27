import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowUpRight, Heart, MapPin, Home, AlertCircle, LoaderCircle, BadgeCheck } from 'lucide-react';
import { api } from './api';
import { useApp } from './context';
import { money, safeImage } from './utils';

export function useResource(path, token, refresh = 0) {
  const [state, setState] = useState({ loading: true, data: null, error: '' });
  useEffect(() => {
    const controller = new AbortController();
    setState({ loading: true, data: null, error: '' });
    api(path, { token, signal: controller.signal })
      .then(data => { if (!controller.signal.aborted) setState({ loading: false, data, error: '' }); })
      .catch(error => { if (!controller.signal.aborted) setState({ loading: false, data: null, error: error.message }); });
    return () => controller.abort();
  }, [path, token, refresh]);
  return state;
}
export function Loading({ label = 'Finding your next home…' }) {
  return <div className="state" role="status"><LoaderCircle className="spin" size={28} /><h3>{label}</h3><p>This may take a moment while the server wakes up.</p></div>;
}
export function ErrorState({ message, retry }) {
  return <div className="state" role="alert"><AlertCircle size={30} /><h3>Something got in the way</h3><p>{message}</p>{retry && <button className="button" onClick={retry}>Try again</button>}</div>;
}
export function Empty({ title, children }) { return <div className="state"><Home size={32} /><h3>{title}</h3><p>{children}</p></div>; }
export function Field({ label, children, ...props }) { return <label className="field"><span>{label}</span>{children || <input {...props} />}</label>; }
export function PropertyImage({ url, title, ...props }) {
  const [failed, setFailed] = useState(false);
  const source = safeImage(url);
  useEffect(() => setFailed(false), [url]);
  return source && !failed ? <img src={source} alt={title} loading="lazy" onError={() => setFailed(true)} {...props} /> : <div className="image-placeholder"><Home size={44} strokeWidth={1} /><span>Student Nest</span><small>Photos coming soon</small></div>;
}
export const VERIFIED_EXPLAINER = 'Student Nest has inspected this home or checked the landlord’s proof of ownership.';
export function VerifiedBadge({ large = false }) {
  return <span className={`verified-badge ${large ? 'large' : ''}`} title={VERIFIED_EXPLAINER}><BadgeCheck size={large ? 18 : 14} aria-hidden="true" />Verified</span>;
}
export function PropertyCard({ property: p }) {
  const { saved, toggleSaved } = useApp();
  return <article className="property-card">
    <div className="card-image"><Link to={`/homes/${p.id}`} aria-label={`View ${p.title}`}><PropertyImage url={p.cover_photo?.[0]?.url} title={p.title} /></Link>
      {p.is_premium && <span className="image-label">Featured</span>}
      <button className={`save-button ${saved.includes(p.id) ? 'selected' : ''}`} onClick={() => toggleSaved(p.id)} aria-label={`${saved.includes(p.id) ? 'Unsave' : 'Save'} ${p.title}`} aria-pressed={saved.includes(p.id)}><Heart size={19} fill={saved.includes(p.id) ? 'currentColor' : 'none'} /></button>
    </div>
    <div className="card-body"><div className="card-tags"><p className="eyebrow">{p.school_name || 'Student accommodation'}</p>{p.is_verified && <VerifiedBadge />}</div><Link className="card-title" to={`/homes/${p.id}`}>{p.title}<ArrowUpRight size={19} /></Link><p className="muted location"><MapPin size={14} />{p.address}</p>
      <div className="card-meta"><span>{p.distance_from_school != null ? `${p.distance_from_school} km from campus` : 'Explore this home'}</span><span>{Number(p.available_spaces_count || 0)} spaces</span></div>
      <div className="card-bottom"><span><strong>{money(p.min_price)}</strong>{p.min_price != null && <small> / month</small>}</span><Link to={`/homes/${p.id}`}>View home <ArrowUpRight size={15} /></Link></div>
    </div>
  </article>;
}
