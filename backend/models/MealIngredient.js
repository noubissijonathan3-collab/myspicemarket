const mongoose = require("mongoose");

const mealIngredientSchema = new mongoose.Schema(
  {
    mealId: { type: mongoose.Schema.Types.ObjectId, ref: "Meal", required: true },
    foodstuffId: { type: mongoose.Schema.Types.ObjectId, ref: "Foodstuff", required: true },
    quantity: { type: Number, required: true },
    unit: { type: String, default: "g" },
    displayOrder: { type: Number, default: 0 },
    defaultPrice: { type: Number, default: null },
    isOptional: { type: Boolean, default: false },
    isModifiable: { type: Boolean, default: true },
  },
  { timestamps: true }
);

mealIngredientSchema.index({ mealId: 1, foodstuffId: 1 }, { unique: true });

module.exports = mongoose.model("MealIngredient", mealIngredientSchema);
