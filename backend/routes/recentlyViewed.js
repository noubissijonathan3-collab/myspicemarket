const express = require('express');
const router = express.Router();
const { getRecentlyViewed, addRecentlyViewed, clearRecentlyViewed } = require('../controllers/recentlyViewedController');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/', getRecentlyViewed);
router.post('/', addRecentlyViewed);
router.delete('/clear', clearRecentlyViewed);

module.exports = router;
