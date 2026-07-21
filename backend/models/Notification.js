const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    title: { type: String, default: "" },
    message: { type: String, default: "" },
    type: { type: String, enum: ["push", "email", "sms"], default: "push" },
    broadcast: { type: Boolean, default: false },
    scheduledAt: { type: Date, default: null },
    data: { type: mongoose.Schema.Types.Mixed, default: null },
    sentBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Notification", notificationSchema);
