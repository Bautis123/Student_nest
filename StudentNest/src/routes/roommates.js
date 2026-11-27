const express = require('express');
const router = express.Router();
const roommates = require('../controllers/roommates');

// Students do not have accounts. Posts are moderated before they are visible,
// and are managed through a private link (token) returned when they are created.

router.get('/options', roommates.getOptions);
router.get('/', roommates.listPosts);
router.post('/', roommates.createPost);

router.get('/manage/:token', roommates.getManaged);
router.patch('/manage/:token', roommates.updateManaged);
router.delete('/manage/:token', roommates.removeManaged);

router.get('/:id/contact', roommates.revealContact);
router.post('/:id/report', roommates.reportPost);

module.exports = router;
