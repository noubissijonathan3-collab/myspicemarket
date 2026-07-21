const express = require("express");
const router = express.Router();
const Rating = require("../models/Rating");

router.get("/:mealId", async (req, res) => {
  try {
    const rating = await Rating.findOne({ mealId: req.params.mealId });
    if (!rating) {
      return res.json({
        averageRating: 0,
        reviewCount: 0,
        distribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
        categoryAverages: {
          taste: 0, freshness: 0, packaging: 0, deliveryExperience: 0,
          portionSize: 0, valueForMoney: 0, overallSatisfaction: 0,
        },
        recommendationPercentage: 0,
        verifiedReviewCount: 0,
      });
    }
    res.json(rating);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
