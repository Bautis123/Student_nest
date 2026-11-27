import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowUpRight, Heart, MapPin, Home, AlertCircle, LoaderCircle, BadgeCheck, Star } from 'lucide-react';
import { api } from './api';
import { useApp } from './context';
import { money, safeImage, commuteLabel } from './utils';

// Public, non-personal responses (home list, campuses) can be kept on the device so
// repeat visits show something instantly while the API wakes up or refreshes.
const CACHE_PREFIX = 'sn-cache:';
const CACHE_MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000;
const CACHE_MAX_CHARS = 1_500_000;
function readCache(path) {
  try {
    const entry = JSON.parse(localStorage.getItem(CACHE_PREFIX + path));
    return entry && Date.now() - entry.savedAt < CACHE_MAX_AGE_MS ? entry.data : null;
  } catch { return null; }
}
function writeCache(path, data) {
  try {
    const value = JSON.stringify({ savedAt: Date.now(), data });
    if (value.length <= CACHE_MAX_CHARS) localStorage.setItem(CACHE_PREFIX + path, value);
  } catch { /* storage full or blocked: caching is only a speed-up */ }
}

/**
 * Load an API resource. With { cache: true } the last good response is shown
 * immediately (stale: true) and kept if the refresh fails; only use it for
 * public data that is safe to store on the device.
 */
export function useResource(path, token, refresh = 0, { cache = false } = {}) {
  const [state, setState] = useState(() => {
    const cached = cache ? readCache(path) : null;
    return { loading: true, data: cached, error: '', stale: Boolean(cached) };
  });
  const lastPath = useRef(path);
  useEffect(() => {
    const controller = new AbortController();
    // On a refresh of the same resource keep showing the current data while reloading.
    const samePath = lastPath.current === path;
    lastPath.current = path;
    setState(previous => {
      const data = samePath ? previous.data : (cache ? readCache(path) : null);
      return { loading: true, data, error: '', stale: previous.stale && samePath };
    });
    api(path, { token, signal: controller.signal })
      .then(data => {
        if (controller.signal.aborted) return;
        if (cache) writeCache(path, data);
        setState({ loading: false, data, error: '', stale: false });
      })
      .catch(error => {
        if (controller.signal.aborted) return;
        setState(previous => ({ loading: false, data: cache ? previous.data : null, error: error.message, stale: cache && Boolean(previous.data) }));
      });
    return () => controller.abort();
  }, [path, token, refresh, cache]);
  return state;
}

/** True once `ms` have passed, e.g. to explain a slow first load. */
export function useSlow(active, ms = 4000) {
  const [slow, setSlow] = useState(false);
  useEffect(() => {
    if (!active) { setSlow(false); return undefined; }
    const timer = setTimeout(() => setSlow(true), ms);
    return () => clearTimeout(timer);
  }, [active, ms]);
  return slow;
}
function WakeUpNote() {
  return <p className="wake-note" role="status"><LoaderCircle className="spin" size={16} aria-hidden="true" />Waking up Student Nest. The first visit after a quiet spell can take up to a minute.</p>;
}

/** Placeholder cards shown while homes load, so the page has its shape immediately. */
export function SkeletonGrid({ count = 6 }) {
  const slow = useSlow(true);
  return <div aria-busy="true" aria-label="Loading homes">
    {slow && <WakeUpNote />}
    <div className="property-grid">{Array.from({ length: count }, (_, i) => <div key={i} className="property-card skeleton-card" aria-hidden="true"><div className="skeleton skeleton-image" /><div className="card-body"><span className="skeleton skeleton-line short" /><span className="skeleton skeleton-line" /><span className="skeleton skeleton-line medium" /><span className="skeleton skeleton-line short" /></div></div>)}</div>
  </div>;
}

/** Placeholder for a home's page. */
export function DetailSkeleton() {
  const slow = useSlow(true);
  return <div className="container detail-page" aria-busy="true" aria-label="Opening this home">
    {slow && <WakeUpNote />}
    <div className="detail-heading" aria-hidden="true"><span className="skeleton skeleton-line short" /><span className="skeleton skeleton-title" /><span className="skeleton skeleton-line medium" /></div>
    <div className="detail-layout" aria-hidden="true"><div className="skeleton skeleton-gallery" /><div className="skeleton skeleton-aside" /></div>
  </div>;
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
