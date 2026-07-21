const mongoose = require("mongoose");

const weeklyMealPlanSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    familySize: { type: Number, default: 1 },
    budget: { type: Number, default: 0 },
    preferences: { type: [String], default: [] },
    days: [
      {
        day: { type: String, enum: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"] },
        meals: [
          {
            mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal" },
            name: { type: String },
            servings: { type: Number },
          },
        ],
      },
    ],
    shoppingList: [
      {
        name: { type: String },
        quantity: { type: String },
        unit: { type: String },
      },
    ],
  },
  { timestamps: true }
);

module.exports = mongoose.model("WeeklyMealPlan", weeklyMealPlanSchema);
