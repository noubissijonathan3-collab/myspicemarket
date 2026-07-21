const mongoose = require("mongoose");

const ratingSchema = new mongoose.Schema(
  {
    mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal", unique: true, required: true },
    averageRating: { type: Number, default: 0 },
    reviewCount: { type: Number, default: 0 },
    distribution: {
      1: { type: Number, default: 0 },
      2: { type: Number, default: 0 },
      3: { type: Number, default: 0 },
      4: { type: Number, default: 0 },
      5: { type: Number, default: 0 },
    },
    categoryAverages: {
      taste: { type: Number, default: 0 },
      freshness: { type: Number, default: 0 },
      packaging: { type: Number, default: 0 },
      deliveryExperience: { type: Number, default: 0 },
      portionSize: { type: Number, default: 0 },
      valueForMoney: { type: Number, default: 0 },
      overallSatisfaction: { type: Number, default: 0 },
    },
    recommendationPercentage: { type: Number, default: 0 },
    verifiedReviewCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Rating", ratingSchema);
