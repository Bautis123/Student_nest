const reports = require('../services/listingReportService');
const { recordAdminLog } = require('../services/adminLogService');

const handle = (fn) => async (req, res) => {
  try {
    await fn(req, res);
  } catch (err) {
    if (err.status) return res.status(err.status).json({ message: err.message });
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
};

// Public: POST /api/properties/:id/report
const reportListing = handle(async (req, res) => {
  await reports.reportListing(req.params.id, req.body);
  // Same reply whether or not the listing was hidden, so reporters can't probe the threshold.
  res.status(201).json({ message: 'Thank you. Our team will review this listing. Never pay anyone before you have viewed a room in person.' });
});

// Admin
const adminList = handle(async (req, res) => {
  res.json({ listings: await reports.listForAdmin() });
});
const adminResolve = handle(async (req, res) => {
  const { action, note } = req.body || {};
  const result = await reports.resolveReports(req.params.propertyId, action, note, req.user.id);
  res.json(result);
  await recordAdminLog(req, {
    action: action === 'take_down' ? 'listing_taken_down' : 'listing_reports_dismissed',
    entityType: 'property',
    entityId: result.property.id,
    message: action === 'take_down'
      ? `Took down "${result.property.title}" after student reports`
      : `Dismissed ${result.reportsClosed} report(s) about "${result.property.title}"`,
    metadata: { reports_closed: result.reportsClosed, note: typeof note === 'string' && note.trim() ? note.trim().slice(0, 500) : undefined },
  });
});

module.exports = { reportListing, adminList, adminResolve };
