const mongoose = require("mongoose");

const deliveryLocationSchema = new mongoose.Schema(
  {
    deliveryAgent: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      default: null,
    },
    storeLocation: {
      latitude: { type: Number, default: 4.0511 },
      longitude: { type: Number, default: 9.7679 },
    },
    customerLocation: {
      latitude: { type: Number },
      longitude: { type: Number },
    },
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    speed: { type: Number, default: 0 },
    heading: { type: Number, default: 0 },
    altitude: { type: Number, default: 0 },
    accuracy: { type: Number, default: 0 },
    status: {
      type: String,
      enum: [
        "en_route_to_pickup",
        "arrived_at_pickup",
        "picked_up",
        "en_route_to_customer",
        "near_customer",
        "arrived",
        "delivered",
      ],
      default: "en_route_to_pickup",
    },
    remainingDistance: { type: Number, default: 0 },
    estimatedArrival: { type: Number, default: 0 },
    offlineQueued: { type: Boolean, default: false },
    timestamp: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

deliveryLocationSchema.index({ deliveryAgent: 1, timestamp: -1 });
deliveryLocationSchema.index({ orderId: 1 });
deliveryLocationSchema.index({ status: 1, timestamp: -1 });

module.exports = mongoose.model("DeliveryLocation", deliveryLocationSchema);
