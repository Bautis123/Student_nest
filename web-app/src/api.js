const base = (import.meta.env.VITE_API_BASE_URL || '/api').replace(/\/$/, '');
export async function api(path, { method = 'GET', body, token, signal } = {}) {
  const multipart = body instanceof FormData;
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 60000);
  const cancel = () => controller.abort();
  if (signal?.aborted) controller.abort();
  signal?.addEventListener('abort', cancel, { once: true });
  try {
    const response = await fetch(`${base}${path}`, {
      method, signal: controller.signal,
      headers: { ...(body && !multipart ? { 'Content-Type': 'application/json' } : {}), ...(token ? { Authorization: `Bearer ${token}` } : {}) },
      body: body ? multipart ? body : JSON.stringify(body) : undefined,
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) {
      const error = new Error(data.message || `Request failed (${response.status}). Please try again.`);
      error.status = response.status;
      error.data = data;
      if (response.status === 401 && token) window.dispatchEvent(new Event('session-expired'));
      throw error;
    }
    return data;
  } catch (error) {
    if (signal?.aborted) throw error;
    if (error.name === 'AbortError') throw new Error('The server is taking longer than expected. Please try again.');
    if (error instanceof TypeError) throw new Error('Unable to reach Student Nest. Check your connection and try again.');
    throw error;
  } finally {
    clearTimeout(timeout);
    signal?.removeEventListener('abort', cancel);
  }
}
