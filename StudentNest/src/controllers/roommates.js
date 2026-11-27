const roommates = require('../services/roommateService');
const { recordAdminLog } = require('../services/adminLogService');

const sendError = (res, err) => {
  if (err.status) return res.status(err.status).json({ message: err.message });
  console.error(err);
  return res.status(500).json({ message: 'Server error' });
};
const handle = (fn) => async (req, res) => {
  try { await fn(req, res); } catch (err) { sendError(res, err); }
};

// Public (students, no account)
const getOptions = (req, res) => {
  res.json({ tags: roommates.TAGS, lifetime_days: roommates.POST_LIFETIME_DAYS });
};
const listPosts = handle(async (req, res) => {
  res.json({ posts: await roommates.listVisiblePosts(req.query) });
});
const createPost = handle(async (req, res) => {
  const { post, manageToken } = await roommates.createPost(req.body);
  // The token is shown once; the student keeps the link to edit or remove the post.
  res.status(201).json({ post, manage_token: manageToken });
});
const revealContact = handle(async (req, res) => {
  res.json(await roommates.revealContact(req.params.id));
});
const reportPost = handle(async (req, res) => {
  await roommates.reportPost(req.params.id, req.body?.reason);
  res.json({ message: 'Thank you. Our team will review this post.' });
});

// Private link (manage token)
const getManaged = handle(async (req, res) => {
  res.json({ post: await roommates.findByToken(req.params.token) });
});
const updateManaged = handle(async (req, res) => {
  res.json({ post: await roommates.updateByToken(req.params.token, req.body) });
});
const removeManaged = handle(async (req, res) => {
  await roommates.removeByToken(req.params.token);
  res.json({ message: 'Your post has been removed' });
});

// Admin
const adminList = handle(async (req, res) => {
  res.json({ posts: await roommates.listForAdmin() });
});
const adminModerate = handle(async (req, res) => {
  const { status, note } = req.body || {};
  const post = await roommates.moderatePost(req.params.id, status, note);
  res.json({ post });
  await recordAdminLog(req, {
    action: status === 'approved' ? 'roommate_post_approved' : 'roommate_post_rejected',
    entityType: 'roommate_post',
    entityId: post.id,
    message: `${status === 'approved' ? 'Approved' : 'Rejected'} roommate post by ${post.display_name}`,
    metadata: { note: typeof note === 'string' && note.trim() ? note.trim().slice(0, 500) : undefined },
  });
});

module.exports = {
  getOptions, listPosts, createPost, revealContact, reportPost,
  getManaged, updateManaged, removeManaged, adminList, adminModerate,
};
