// Automatic WhatsApp alerts to landlords.
//
// WHATSAPP_PROVIDER:
//   meta  = WhatsApp Business Cloud API (needs WHATSAPP_TOKEN, WHATSAPP_PHONE_NUMBER_ID
//           and an approved template named WHATSAPP_TEMPLATE_VIEWING)
//   log   = demo mode: the alert is written to the server log, nothing is sent
//   unset = alerts off (students still send the request themselves via tap-to-send)
//
// Business-initiated WhatsApp messages must use a template approved by Meta.
// The viewing template's body takes four parameters, in this order:
//   {{1}} student name, {{2}} property title, {{3}} preferred day and time, {{4}} dashboard link
const DEFAULT_API_VERSION = 'v21.0';
const REQUEST_TIMEOUT_MS = 15000;

/** "0971234567" → "260971234567" (international format, no plus). */
const toInternational = (phone) => (phone?.startsWith('0') ? `260${phone.slice(1)}` : phone);

const createMetaProvider = ({
  token = process.env.WHATSAPP_TOKEN,
  phoneNumberId = process.env.WHATSAPP_PHONE_NUMBER_ID,
  template = process.env.WHATSAPP_TEMPLATE_VIEWING || 'viewing_request',
  language = process.env.WHATSAPP_TEMPLATE_LANGUAGE || 'en',
  apiVersion = process.env.WHATSAPP_API_VERSION || DEFAULT_API_VERSION,
  fetchImpl = globalThis.fetch,
} = {}) => {
  if (!token || !phoneNumberId) throw new Error('WHATSAPP_TOKEN and WHATSAPP_PHONE_NUMBER_ID are required');
  return {
    name: 'meta',
    async sendViewingAlert({ to, studentName, propertyTitle, when, link }) {
      const response = await fetchImpl(`https://graph.facebook.com/${apiVersion}/${phoneNumberId}/messages`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: toInternational(to),
          type: 'template',
          template: {
            name: template,
            language: { code: language },
            components: [{
              type: 'body',
              parameters: [studentName, propertyTitle, when, link].map((text) => ({ type: 'text', text: String(text).slice(0, 200) })),
            }],
          },
        }),
        signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
      });
      if (!response.ok) {
        const payload = await response.json().catch(() => ({}));
        throw new Error(payload?.error?.message || `WhatsApp API error (${response.status})`);
      }
    },
  };
};

const createLogProvider = ({ log = console.log } = {}) => ({
  name: 'log',
  async sendViewingAlert({ to, studentName, propertyTitle, when, link }) {
    log(`[whatsapp demo] to ${toInternational(to)}: ${studentName} wants to view "${propertyTitle}" ${when}. ${link}`);
  },
});

let provider;
const getWhatsAppProvider = () => {
  if (provider !== undefined) return provider;
  const name = (process.env.WHATSAPP_PROVIDER || '').toLowerCase();
  provider = name === 'meta' ? createMetaProvider() : name === 'log' ? createLogProvider() : null;
  return provider;
};
const setWhatsAppProvider = (value) => { provider = value; };

module.exports = { createMetaProvider, createLogProvider, getWhatsAppProvider, setWhatsAppProvider, toInternational };
