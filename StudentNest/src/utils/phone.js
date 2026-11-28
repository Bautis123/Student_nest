/** Normalise "+260 97 123 4567", "260971234567" or "0971234567" to "0971234567"; null if not a Zambian mobile. */
const normalizeZambianMobile = (input) => {
  let digits = String(input || '').replace(/\D/g, '');
  if (digits.startsWith('260')) digits = `0${digits.slice(3)}`;
  return /^0[79]\d{8}$/.test(digits) ? digits : null;
};

/** WhatsApp click-to-chat link for a normalised Zambian number. */
const whatsappLink = (phone) => (phone ? `https://wa.me/260${phone.slice(1)}` : null);

module.exports = { normalizeZambianMobile, whatsappLink };
