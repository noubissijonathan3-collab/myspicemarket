const mongoose = require("mongoose");

const favoriteSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal", required: true },
  },
  { timestamps: true }
);

favoriteSchema.index({ userId: 1, mealId: 1 }, { unique: true });

module.exports = mongoose.model("Favorite", favoriteSchema);
