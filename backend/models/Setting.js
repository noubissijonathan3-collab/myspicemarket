const mongoose = require("mongoose");

const settingSchema = new mongoose.Schema(
  {
    deliveryFee: { type: Number, default: 1500 },
    currency: { type: String, default: "FCFA" },
    tax: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Setting", settingSchema);
