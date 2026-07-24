const mongoose = require("mongoose");

const NOTIFICATION_CATEGORIES = [
  "orders",
  "deliveries",
  "messages",
  "promotions",
  "system",
  "security",
  "inventory",
  "account",
];

const NOTIFICATION_PRIORITIES = ["low", "medium", "high", "critical"];

const NOTIFICATION_TYPES = [
  "ORDER",
  "DELIVERY",
  "CHAT",
  "PROMOTION",
  "SYSTEM",
  "SECURITY",
  "INVENTORY",
  "ACCOUNT",
];

const RETENTION_DAYS = {
  orders: 90,
  deliveries: 90,
  messages: 30,
  promotions: 365,
  system: 180,
  security: 365,
  inventory: 180,
  account: 365,
};

const notificationSchema = new mongoose.Schema(
  {
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    recipientRole: {
      type: String,
      enum: ["customer", "preparationAgent", "deliveryAgent", "admin", "all"],
      default: "customer",
    },
    title: { type: String, required: true },
    message: { type: String, required: true },
    type: {
      type: String,
      enum: NOTIFICATION_TYPES,
      default: "ORDER",
    },
    category: {
      type: String,
      enum: NOTIFICATION_CATEGORIES,
      default: "orders",
    },
    priority: {
      type: String,
      enum: NOTIFICATION_PRIORITIES,
      default: "medium",
    },
    orderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Order",
      default: null,
    },
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Foodstuff",
      default: null,
    },
    isRead: { type: Boolean, default: false, index: true },
    readAt: { type: Date, default: null },
    actionLink: { type: String, default: null },
    actionType: {
      type: String,
      enum: ["view_order", "view_chat", "view_delivery", "view_profile", "view_product", null],
      default: null,
    },
    metadata: { type: mongoose.Schema.Types.Mixed, default: null },
    expiresAt: { type: Date, default: null },
    sentBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
  },
  { timestamps: true }
);

notificationSchema.index({ user: 1, isRead: 1 });
notificationSchema.index({ user: 1, createdAt: -1 });
notificationSchema.index({ user: 1, category: 1 });
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

notificationSchema.statics.CATEGORIES = NOTIFICATION_CATEGORIES;
notificationSchema.statics.PRIORITIES = NOTIFICATION_PRIORITIES;
notificationSchema.statics.TYPES = NOTIFICATION_TYPES;
notificationSchema.statics.RETENTION_DAYS = RETENTION_DAYS;

module.exports = mongoose.model("Notification", notificationSchema);
