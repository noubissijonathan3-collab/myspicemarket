const express = require("express");
const router = express.Router();
const mealRecommendationController = require("../controllers/mealRecommendationController");
const { protect } = require("../../middleware/auth");

router.post("/suggest", protect, mealRecommendationController.suggest);
router.get("/recommend", protect, mealRecommendationController.recommend);
router.post("/substitute", protect, mealRecommendationController.substitute);

module.exports = router;
