const Notification = require("../models/Notification");

let _io = null;
let _sendPush = null;

function setSocketIO(io) {
  _io = io;
}

function setPushSender(fn) {
  _sendPush = fn;
}

async function createNotification({
  userId,
  recipientRole = "customer",
  title,
  message,
  type = "ORDER",
  category = "orders",
  priority = "medium",
  orderId = null,
  productId = null,
  actionLink = null,
  actionType = null,
  metadata = null,
  expiresAt = null,
  sentBy = null,
  skipDuplicate = false,
}) {
  try {
    if (skipDuplicate) {
      const recentWindow = new Date(Date.now() - 30 * 60 * 1000);
      const existing = await Notification.findOne({
        user: userId,
        type,
        category,
        orderId,
        createdAt: { $gte: recentWindow },
      });
      if (existing) {
        existing.title = title;
        existing.message = message;
        existing.priority = priority;
        existing.metadata = metadata;
        await existing.save();
        _emitToUser(userId, "notification_update", _toSafe(existing));
        return existing;
      }
    }

    const notification = await Notification.create({
      user: userId,
      recipientRole,
      title,
      message,
      type,
      category,
      priority,
      orderId,
      productId,
      actionLink,
      actionType,
      metadata,
      expiresAt,
      sentBy,
    });

    const safe = _toSafe(notification);

    _emitToUser(userId, "notification:new", safe);

    const unreadCount = await Notification.countDocuments({ user: userId, isRead: false });
    _emitToUser(userId, "notification:unread_count", { count: unreadCount });

    if (_sendPush) {
      try {
        await _sendPush(userId, { title, message, orderId, actionLink, actionType, type, priority });
      } catch (pushErr) {
        console.error("Push notification error:", pushErr.message);
      }
    }

    return notification;
  } catch (err) {
    console.error("createNotification error:", err.message);
    return null;
  }
}

function _emitToUser(userId, event, data) {
  if (!_io) return;
  const userIdStr = userId.toString();
  try {
    for (const [, socket] of _io.sockets.sockets) {
      if (socket.user && socket.user._id && socket.user._id.toString() === userIdStr) {
        socket.emit(event, data);
      }
    }
  } catch (_) {}
}

function _toSafe(notif) {
  const obj = typeof notif.toObject === "function" ? notif.toObject() : { ...notif };
  delete obj.__v;
  return obj;
}

async function notifyOrderStatusChange(order, oldStatus, newStatus) {
  const title = _orderStatusTitle(newStatus);
  const message = _orderStatusMessage(newStatus, order);
  const orderId = order._id;

  if (order.userId) {
    await createNotification({
      userId: order.userId,
      recipientRole: "customer",
      title,
      message,
      type: "ORDER",
      category: "orders",
      priority: _orderPriority(newStatus),
      orderId,
      actionLink: `/orders/${orderId}`,
      actionType: "view_order",
      metadata: { oldStatus, newStatus, orderNumber: order.orderNumber },
      skipDuplicate: true,
    });
  }

  if (newStatus === "Ready" && order.preparationAgent) {
    await createNotification({
      userId: order.preparationAgent,
      recipientRole: "preparationAgent",
      title: "Preparation Completed",
      message: `Order is ready for delivery pickup.`,
      type: "ORDER",
      category: "orders",
      priority: "high",
      orderId,
      actionType: "view_order",
      metadata: { oldStatus, newStatus },
    });
  }

  if (newStatus === "Out for Delivery" && order.deliveryAgent) {
    await createNotification({
      userId: order.deliveryAgent,
      recipientRole: "deliveryAgent",
      title: "New Delivery Assignment",
      message: `Order is ready for pickup. Start delivery.`,
      type: "DELIVERY",
      category: "deliveries",
      priority: "high",
      orderId,
      actionType: "view_delivery",
      metadata: { oldStatus, newStatus },
    });
  }

  if (newStatus === "Delivered" && order.deliveryAgent) {
    await createNotification({
      userId: order.deliveryAgent,
      recipientRole: "deliveryAgent",
      title: "Delivery Completed",
      message: `Delivery has been verified successfully.`,
      type: "DELIVERY",
      category: "deliveries",
      priority: "medium",
      orderId,
      actionType: "view_delivery",
      metadata: { oldStatus, newStatus },
    });
  }
}

function _orderStatusTitle(status) {
  const titles = {
    Confirmed: "Order Confirmed",
    Preparing: "Order Being Prepared",
    Ready: "Order Ready",
    "Out for Delivery": "Order Out for Delivery",
    "On Route": "Delivery On Route",
    Delivered: "Order Delivered",
    Cancelled: "Order Cancelled",
  };
  return titles[status] || "Order Updated";
}

function _orderStatusMessage(status, order) {
  const shortId = order._id ? order._id.toString().slice(-6).toUpperCase() : "";
  const msgs = {
    Confirmed: `Your order #${shortId} has been confirmed and will soon be prepared.`,
    Preparing: `Your groceries for order #${shortId} are currently being prepared.`,
    Ready: `Your order #${shortId} is ready and awaiting delivery.`,
    "Out for Delivery": `Your order #${shortId} is on its way!`,
    "On Route": `Your delivery agent is approaching with order #${shortId}.`,
    Delivered: `Your order #${shortId} has been delivered successfully. Enjoy!`,
    Cancelled: `Your order #${shortId} has been cancelled.`,
  };
  return msgs[status] || `Order #${shortId} has been updated to ${status}.`;
}

function _orderPriority(status) {
  if (["Delivered", "Cancelled"].includes(status)) return "medium";
  if (["Out for Delivery", "On Route"].includes(status)) return "high";
  return "medium";
}

async function notifyAgentAssigned(order, agentId, agentRole, agentName) {
  if (!agentId) return;

  const roleLabel = agentRole === "preparationAgent" ? "Preparation" : "Delivery";
  const shortId = order._id ? order._id.toString().slice(-6).toUpperCase() : "";

  await createNotification({
    userId: agentId,
    recipientRole: agentRole,
    title: `New ${roleLabel} Assignment`,
    message: `You have been assigned to order #${shortId}.`,
    type: agentRole === "preparationAgent" ? "ORDER" : "DELIVERY",
    category: agentRole === "preparationAgent" ? "orders" : "deliveries",
    priority: "high",
    orderId: order._id,
    actionType: agentRole === "preparationAgent" ? "view_order" : "view_delivery",
    metadata: { agentName, role: agentRole },
  });

  if (order.userId) {
    const agentLabel = agentRole === "preparationAgent" ? "preparation agent" : "delivery agent";
    await createNotification({
      userId: order.userId,
      recipientRole: "customer",
      title: `${roleLabel} Agent Assigned`,
      message: `${agentName || agentLabel} has been assigned to your order #${shortId}.`,
      type: "ORDER",
      category: "orders",
      priority: "medium",
      orderId: order._id,
      actionType: "view_order",
      skipDuplicate: true,
    });
  }
}

async function notifyChatMessage({ recipientId, recipientRole, senderName, senderRole, orderId, agentType, messagePreview }) {
  const typeLabel = agentType === "preparation" ? "Preparation" : "Delivery";
  const shortId = orderId ? orderId.toString().slice(-6).toUpperCase() : "";
  const roleLabel = senderRole === "customer" ? "Customer" : typeLabel + " Agent";

  await createNotification({
    userId: recipientId,
    recipientRole,
    title: `${senderName || roleLabel} sent a message`,
    message: messagePreview || `New message regarding order #${shortId}`,
    type: "CHAT",
    category: "messages",
    priority: "medium",
    orderId,
    actionLink: `/chat/${orderId}`,
    actionType: "view_chat",
    metadata: { senderRole, agentType, senderName },
    skipDuplicate: true,
  });
}

async function notifyNewUser(user) {
  await createNotification({
    userId: user._id,
    recipientRole: "customer",
    title: "Welcome to My SpiceMarket!",
    message: `Hello ${user.fullName}, your account has been created successfully.`,
    type: "ACCOUNT",
    category: "account",
    priority: "low",
    actionType: "view_profile",
  });
}

module.exports = {
  setSocketIO,
  setPushSender,
  createNotification,
  notifyOrderStatusChange,
  notifyAgentAssigned,
  notifyChatMessage,
  notifyNewUser,
};
