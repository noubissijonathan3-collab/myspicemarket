const mongoose = require("mongoose");

const promotionSchema = new mongoose.Schema(
  {
    code: { type: String, required: true, unique: true },
    description: { type: String, default: "" },
    discountPercent: { type: Number, default: 0 },
    type: { type: String, enum: ["percentage", "fixed"], default: "percentage" },
    minOrderAmount: { type: Number, default: 0 },
    validFrom: { type: Date },
    validTo: { type: Date },
    isActive: { type: Boolean, default: true },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Promotion", promotionSchema);
