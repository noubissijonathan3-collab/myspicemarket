const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    fullName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, default: "" },
    password: { type: String, required: true },
    profileImage: { type: String, default: "" },
    address: {
      street: { type: String, default: "" },
      city: { type: String, default: "Douala" },
      quarter: { type: String, default: "" },
      landmark: { type: String, default: "" },
    },
    role: { type: String, enum: ["customer", "admin", "preparationAgent", "deliveryAgent"], default: "customer" },
    isVerified: { type: Boolean, default: true },
    resetOTP: { type: String, default: null },
    resetOTPExpiry: { type: Date, default: null },
    resetVerified: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
