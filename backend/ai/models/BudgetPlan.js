const mongoose = require("mongoose");

const budgetPlanSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    budget: { type: Number, required: true },
    currency: { type: String, default: "FCFA" },
    recommendations: [
      {
        mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal" },
        name: { type: String },
        price: { type: Number },
        reason: { type: String },
      },
    ],
    totalCost: { type: Number },
    savings: { type: Number },
  },
  { timestamps: true }
);

module.exports = mongoose.model("BudgetPlan", budgetPlanSchema);
