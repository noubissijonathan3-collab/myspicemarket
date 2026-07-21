const mongoose = require("mongoose");

const mealRecommendationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal", required: true },
    reason: { type: String, default: "" },
    score: { type: Number, default: 0 },
    source: { type: String, enum: ["ai", "behavior", "popular"], default: "ai" },
    viewed: { type: Boolean, default: false },
    interacted: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("MealRecommendation", mealRecommendationSchema);
