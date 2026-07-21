const mongoose = require("mongoose");

const nutritionLogSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal" },
    query: { type: String, default: "" },
    analysis: {
      calories: { type: Number },
      protein: { type: String },
      carbs: { type: String },
      fat: { type: String },
      fiber: { type: String },
      summary: { type: String },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("NutritionLog", nutritionLogSchema);
