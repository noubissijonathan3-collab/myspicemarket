const mongoose = require("mongoose");

const foodstuffSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    category: { type: String, default: "Other" },
    image: { type: String, default: "" },
    unit: { type: String, default: "piece" },
    price: { type: Number, required: true },
    stock: { type: Number, default: 0 },
    description: { type: String, default: "" },
    isAvailable: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Foodstuff", foodstuffSchema);
