const mongoose = require("mongoose");

const chatRoomSchema = new mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: "Order", required: true },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    agentId: { type: mongoose.Schema.Types.ObjectId, ref: "User", default: null },
    agentName: { type: String, default: "" },
    agentAvatar: { type: String, default: "" },
    agentType: { type: String, enum: ["preparation", "delivery"], default: "preparation" },
    status: { type: String, enum: ["active", "closed"], default: "active" },
  },
  { timestamps: true }
);

chatRoomSchema.index({ orderId: 1, agentType: 1 });

module.exports = mongoose.model("ChatRoom", chatRoomSchema);
