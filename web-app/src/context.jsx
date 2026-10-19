import { createContext, useContext, useEffect, useState } from 'react';
import { readStored } from './utils';
const AppContext = createContext(null);
export function AppProvider({ children }) {
  const [session, setSession] = useState(() => readStored(sessionStorage, 'sn-session', null));
  const [saved, setSaved] = useState(() => {
    const value = readStored(localStorage, 'sn-saved', []);
    return Array.isArray(value) ? value : [];
  });
  const [notice, setNotice] = useState('');
  const login = (value) => { sessionStorage.setItem('sn-session', JSON.stringify(value)); setSession(value); };
  const logout = () => { sessionStorage.removeItem('sn-session'); setSession(null); };
  useEffect(() => {
    const expire = () => { logout(); setNotice('Your session has expired. Please sign in again.'); };
    window.addEventListener('session-expired', expire);
    return () => window.removeEventListener('session-expired', expire);
  }, []);
  function toggleSaved(id) {
    setSaved(current => {
      const next = current.includes(id) ? current.filter(item => item !== id) : [...current, id];
      try { localStorage.setItem('sn-saved', JSON.stringify(next)); } catch { setNotice('Your browser could not save this shortlist.'); }
      return next;
    });
  }
  return <AppContext.Provider value={{ session, login, logout, saved, toggleSaved, notice, setNotice }}>{children}</AppContext.Provider>;
}
export const useApp = () => useContext(AppContext);
