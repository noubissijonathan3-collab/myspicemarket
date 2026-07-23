const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    status: {
      type: String,
      enum: ["Pending", "Confirmed", "Preparing", "Ready", "Out for Delivery", "On Route", "Delivered", "Cancelled"],
      default: "Pending",
    },
    delivery: {
      receiver: { type: String, default: "" },
      phone: { type: String, default: "" },
      address: { type: String, default: "" },
      latitude: { type: Number, default: null },
      longitude: { type: Number, default: null },
      notes: { type: String, default: "" },
    },
    preparationAgent: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
    deliveryAgent: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
    deliveryStatus: {
      type: String,
      enum: ["unassigned", "assigned", "picked_up", "in_transit", "delivered", "failed", null],
      default: null,
    },
    deliveryPin: { type: String, default: "" },
    deliveryPhoto: { type: String, default: "" },
    deliverySignature: { type: String, default: "" },
    deliveryNotes: { type: String, default: "" },
    cancellationReason: { type: String, default: "" },
    pickupTime: { type: Date, default: null },
    deliveryTime: { type: Date, default: null },
    estimatedDeliveryTime: { type: Date, default: null },
    total: { type: Number, default: 0 },
    isChecklistFinished: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Order", orderSchema);
