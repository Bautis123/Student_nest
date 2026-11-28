import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowUpRight, Heart, MapPin, Home, AlertCircle, LoaderCircle, BadgeCheck, Star } from 'lucide-react';
import { api } from './api';
import { useApp } from './context';
import { money, safeImage, commuteLabel } from './utils';

export function useResource(path, token, refresh = 0) {
  const [state, setState] = useState({ loading: true, data: null, error: '' });
  const lastPath = useRef(path);
  useEffect(() => {
    const controller = new AbortController();
    // On a refresh of the same resource keep showing the current data while reloading.
    const samePath = lastPath.current === path;
    lastPath.current = path;
    setState(previous => ({ loading: true, data: samePath ? previous.data : null, error: '' }));
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
/** Read-only stars, e.g. 4.5 → four full stars and a half. */
export function Stars({ value, size = 16 }) {
  const rounded = Math.round(Number(value || 0) * 2) / 2;
  return <span className="stars" role="img" aria-label={`${rounded} out of 5 stars`}>
    {[1, 2, 3, 4, 5].map(n => rounded >= n
      ? <Star key={n} size={size} className="full" aria-hidden="true" />
      : rounded >= n - 0.5
        // Half star: a full star clipped to its left half over an empty one.
        ? <span key={n} className="half-star" style={{ width: size, height: size }} aria-hidden="true"><Star size={size} /><span><Star size={size} className="full" /></span></span>
        : <Star key={n} size={size} aria-hidden="true" />)}
  </span>;
}

/** Compact rating for listing cards: "★ 4.5 (3)". */
export function RatingPill({ average, count }) {
  if (!count) return null;
  return <span className="rating-pill" aria-label={`Rated ${average} out of 5 from ${count} review${count === 1 ? '' : 's'}`}><Star size={13} aria-hidden="true" />{Number(average).toFixed(1)}<small>({count})</small></span>;
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
      <div className="card-meta"><span>{commuteLabel(p) || 'Explore this home'}</span><span className="card-meta-end"><RatingPill average={p.rating_average} count={p.review_count} />{Number(p.available_spaces_count || 0)} spaces</span></div>
      <div className="card-bottom"><span><strong>{money(p.min_price)}</strong>{p.min_price != null && <small> / month</small>}</span><Link to={`/homes/${p.id}`}>View home <ArrowUpRight size={15} /></Link></div>
    </div>
  </article>;
}
