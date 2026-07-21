const mongoose = require("mongoose");

const mealSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    description: { type: String, default: "" },
    categoryId: { type: mongoose.Schema.Types.ObjectId, ref: "Category" },
    image: { type: String, default: "" },
    preparationTime: { type: Number, default: 30 },
    difficulty: { type: String, enum: ["Easy", "Medium", "Hard"], default: "Medium" },
    servings: { type: Number, default: 2 },
    isPopular: { type: Boolean, default: false },
    favoritesCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Meal", mealSchema);
