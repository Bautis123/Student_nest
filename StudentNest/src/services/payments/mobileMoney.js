// Zambian mobile money number helpers.

const OPERATOR_PREFIXES = {
  mtn: ['096', '076'],
  airtel: ['097', '077'],
  zamtel: ['095', '075'],
};

const OPERATORS = Object.keys(OPERATOR_PREFIXES);

/** Normalise "+260 97 123 4567", "260971234567" or "0971234567" to "0971234567". */
const normalizePhone = (input) => {
  let digits = String(input || '').replace(/\D/g, '');
  if (digits.startsWith('260')) digits = `0${digits.slice(3)}`;
  return /^0[79]\d{8}$/.test(digits) ? digits : null;
};

const detectOperator = (phone) =>
  OPERATORS.find((operator) => OPERATOR_PREFIXES[operator].some((prefix) => phone?.startsWith(prefix))) || null;

module.exports = { OPERATORS, normalizePhone, detectOperator };
