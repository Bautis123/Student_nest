const viewings = require('../services/viewingService');

const handle = (fn) => async (req, res) => {
  try {
    await fn(req, res);
  } catch (err) {
    if (err.status) return res.status(err.status).json({ message: err.message });
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Public: POST /api/viewings
const createRequest = handle(async (req, res) => {
  const result = await viewings.createRequest(req.body?.property_id, req.body);
  res.status(201).json(result);
});

// Landlord: GET /api/viewings/mine, PATCH /api/viewings/:id
const listMine = handle(async (req, res) => {
  res.json({ requests: await viewings.listForLandlord(req.user.id) });
});
const respond = handle(async (req, res) => {
  res.json({ request: await viewings.respond(req.user.id, req.params.id, req.body?.status, req.body?.note) });
});

module.exports = { createRequest, listMine, respond };
