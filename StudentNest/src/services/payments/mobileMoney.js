// Zambian mobile money number helpers.
const { normalizeZambianMobile: normalizePhone } = require('../../utils/phone');

const OPERATOR_PREFIXES = {
  mtn: ['096', '076'],
  airtel: ['097', '077'],
  zamtel: ['095', '075'],
};

const OPERATORS = Object.keys(OPERATOR_PREFIXES);

const detectOperator = (phone) =>
  OPERATORS.find((operator) => OPERATOR_PREFIXES[operator].some((prefix) => phone?.startsWith(prefix))) || null;

module.exports = { OPERATORS, normalizePhone, detectOperator };
