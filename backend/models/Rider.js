const mongoose = require("mongoose");

const riderSchema = new mongoose.Schema(
  {
    fullName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    phone: { type: String, required: true },
    password: { type: String, required: true },
    vehicleType: { type: String, enum: ["Bike", "Car", "Scooter"], default: "Bike" },
    isAvailable: { type: Boolean, default: true },
    totalDeliveries: { type: Number, default: 0 },
    rating: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Rider", riderSchema);
