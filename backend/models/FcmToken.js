const mongoose = require("mongoose");

const fcmTokenSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    token: {
      type: String,
      required: true,
      unique: true,
    },
    platform: {
      type: String,
      enum: ["android", "ios", "web"],
      default: "android",
    },
    appType: {
      type: String,
      enum: ["customer", "agent"],
      default: "customer",
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    lastUsed: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

fcmTokenSchema.index({ user: 1, appType: 1 });
fcmTokenSchema.index({ token: 1 }, { unique: true });

module.exports = mongoose.model("FcmToken", fcmTokenSchema);
