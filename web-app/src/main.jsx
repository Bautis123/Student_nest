import React from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Link, NavLink, Navigate, Route, Routes, useLocation } from 'react-router-dom';
import { Heart, ArrowUpRight, LogOut, Menu, X } from 'lucide-react';
import { AppProvider, useApp } from './context';
import { Browse, PropertyDetail } from './student';
import { Auth, Dashboard, ListingEditor } from './landlord';
import './styles.css';

function Layout() {
  const { session, logout, saved, notice, setNotice } = useApp();
  const [menu, setMenu] = React.useState(false);
  const location = useLocation();
  React.useEffect(() => { setMenu(false); window.scrollTo(0, 0); }, [location.pathname]);
  return <><a className="skip-link" href="#main">Skip to content</a><header className="site-header"><div className="header-inner">
    <Link to="/" className="brand" aria-label="Student Nest home"><img src="/logo.png" alt="Student Nest" /></Link>
    <button className="menu-toggle" onClick={() => setMenu(!menu)} aria-label="Toggle navigation" aria-expanded={menu}>{menu ? <X /> : <Menu />}</button>
    <nav className={menu ? 'open' : ''} aria-label="Main navigation"><NavLink to="/" end>Find a home</NavLink><NavLink to="/saved"><Heart size={16} />Saved{saved.length > 0 && <span className="count">{saved.length}</span>}</NavLink><span className="nav-divider" />{session ? <><NavLink to="/landlord">My listings</NavLink><button className="text-button" onClick={logout}><LogOut size={16} />Sign out</button></> : <><NavLink to="/login">Landlord sign in</NavLink><Link className="button small" to="/register">List your property <ArrowUpRight size={16} /></Link></>}</nav>
  </div></header>{notice && <div className="global-notice" role="status">{notice}<button onClick={() => setNotice('')} aria-label="Dismiss notification"><X size={16} /></button></div>}
    <main id="main"><Routes><Route path="/" element={<Browse />} /><Route path="/saved" element={<Browse savedOnly />} /><Route path="/homes/:id" element={<PropertyDetail />} /><Route path="/login" element={<Auth />} /><Route path="/register" element={<Auth register />} /><Route path="/landlord" element={<Protected><Dashboard /></Protected>} /><Route path="/landlord/new" element={<Protected><ListingEditor /></Protected>} /><Route path="/landlord/:id" element={<Protected><ListingEditor /></Protected>} /><Route path="*" element={<div className="state"><h1>Page not found</h1><Link className="button" to="/">Find a home</Link></div>} /></Routes></main>
    <footer className="site-footer"><Link to="/" className="footer-brand">Student Nest<span>Your campus. Your community. Your home.</span></Link><p>Made for student life in Zambia.</p><a href="https://student-nest-api.onrender.com/admin" target="_blank" rel="noreferrer">Admin portal <ArrowUpRight size={14} /></a></footer>
  </>;
}
function Protected({ children }) {
  const { session } = useApp();
  const location = useLocation();
  return session?.user?.role === 'landlord' ? children : <Navigate to="/login" state={{ from: location.pathname }} replace />;
}
class ErrorBoundary extends React.Component {
  state = { failed: false };
  static getDerivedStateFromError() { return { failed: true }; }
  render() { return this.state.failed ? <div className="state"><h1>We couldn’t open this page.</h1><p>Try reloading Student Nest.</p><button className="button" onClick={() => window.location.reload()}>Reload</button></div> : this.props.children; }
}
createRoot(document.getElementById('root')).render(<ErrorBoundary><BrowserRouter><AppProvider><Layout /></AppProvider></BrowserRouter></ErrorBoundary>);
