const mongoose = require("mongoose");

const reviewSchema = new mongoose.Schema(
  {
    mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal", required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    rating: { type: Number, min: 1, max: 5, required: true },
    title: { type: String, default: "" },
    comment: { type: String, default: "" },
    images: [{ type: String }],
    verifiedPurchase: { type: Boolean, default: false },
    helpfulCount: { type: Number, default: 0 },
    reply: {
      text: { type: String, default: "" },
      createdAt: { type: Date },
    },
    categoryRatings: {
      taste: { type: Number, min: 1, max: 5, default: 0 },
      freshness: { type: Number, min: 1, max: 5, default: 0 },
      packaging: { type: Number, min: 1, max: 5, default: 0 },
      deliveryExperience: { type: Number, min: 1, max: 5, default: 0 },
      portionSize: { type: Number, min: 1, max: 5, default: 0 },
      valueForMoney: { type: Number, min: 1, max: 5, default: 0 },
      overallSatisfaction: { type: Number, min: 1, max: 5, default: 0 },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Review", reviewSchema);
