const express = require('express');
const router = express.Router();
const { getRecommendations, generateRecommendations } = require('../controllers/recommendationController');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/', async (req, res) => {
  const Recommendation = require('../models/Recommendation');
  const count = await Recommendation.countDocuments({ user: req.user.id, isActive: true });
  if (count === 0) {
    await generateRecommendations(req, res);
  } else {
    await getRecommendations(req, res);
  }
});
router.post('/generate', generateRecommendations);

module.exports = router;
