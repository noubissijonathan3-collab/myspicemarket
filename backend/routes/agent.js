const express = require("express");
const bcrypt = require("bcryptjs");
const User = require("../models/User");
const Order = require("../models/Order");
const OrderItem = require("../models/OrderItem");
const Notification = require("../models/Notification");
const { protect } = require("../middleware/auth");

const router = express.Router();

// Middleware: all agent routes require auth + deliveryAgent or preparationAgent role
router.use(protect);

const agentOnly = (req, res, next) => {
  if (req.user.role !== "deliveryAgent" && req.user.role !== "preparationAgent" && req.user.role !== "admin") {
    return res.status(403).json({ message: "Agent access required" });
  }
  next();
};

const deliveryOnly = (req, res, next) => {
  if (req.user.role !== "deliveryAgent" && req.user.role !== "admin") {
    return res.status(403).json({ message: "Delivery agent access required" });
  }
  next();
};

// ==================== PROFILE ====================

router.get("/profile", agentOnly, async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select("-password");
    if (!user) return res.status(404).json({ message: "User not found" });

    const totalDeliveries = await Order.countDocuments({
      deliveryAgent: req.user._id,
      status: "Delivered",
    });

    const activeDeliveries = await Order.countDocuments({
      deliveryAgent: req.user._id,
      status: { $in: ["Out for Delivery", "On Route"] },
    });

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const todayDeliveries = await Order.countDocuments({
      deliveryAgent: req.user._id,
      status: "Delivered",
      deliveryTime: { $gte: todayStart },
    });

    const earningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: req.user._id, status: "Delivered" } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const totalEarnings = earningsAgg.length > 0 ? earningsAgg[0].total : 0;

    const todayEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: req.user._id, status: "Delivered", deliveryTime: { $gte: todayStart } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const todayEarnings = todayEarningsAgg.length > 0 ? todayEarningsAgg[0].total : 0;

    res.json({
      ...user.toObject(),
      stats: {
        totalDeliveries,
        activeDeliveries,
        todayDeliveries,
        totalEarnings,
        todayEarnings,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/profile", agentOnly, async (req, res) => {
  try {
    const { fullName, phone, vehicleType } = req.body;
    const updateData = {};
    if (fullName) updateData.fullName = fullName;
    if (phone) updateData.phone = phone;
    if (vehicleType) updateData.vehicleType = vehicleType;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updateData },
      { returnDocument: "after" }
    ).select("-password");

    if (!user) return res.status(404).json({ message: "User not found" });
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== AVAILABILITY ====================

router.put("/availability", agentOnly, async (req, res) => {
  try {
    const { isAvailable } = req.body;
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: { isAvailable: !!isAvailable } },
      { returnDocument: "after" }
    ).select("-password");

    if (!user) return res.status(404).json({ message: "User not found" });
    res.json({ isAvailable: user.isAvailable });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== ORDERS (delivery agent) ====================

router.get("/orders", deliveryOnly, async (req, res) => {
  try {
    const { status } = req.query;
    const query = { deliveryAgent: req.user._id };

    if (status) {
      const statusMap = {
        assigned: { status: { $in: ["Confirmed", "Ready"] }, deliveryStatus: "assigned" },
        active: { status: { $in: ["Out for Delivery", "On Route"] } },
        delivered: { status: "Delivered" },
        cancelled: { status: "Cancelled" },
        pending: { deliveryStatus: "assigned", status: { $in: ["Confirmed", "Ready"] } },
      };
      if (statusMap[status]) {
        Object.assign(query, statusMap[status]);
      }
    }

    const orders = await Order.find(query)
      .populate("userId", "fullName phone email address")
      .sort({ createdAt: -1 });

    const ordersWithItems = await Promise.all(
      orders.map(async (order) => {
        const items = await OrderItem.find({ orderId: order._id })
          .populate("foodstuffId", "name image unit price");
        return { order, items };
      })
    );

    res.json(ordersWithItems);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/orders/all", agentOnly, async (req, res) => {
  try {
    let query;
    if (req.user.role === "deliveryAgent") {
      query = { deliveryAgent: req.user._id };
    } else {
      query = {};
    }

    if (req.query.status) query.status = req.query.status;

    const orders = await Order.find(query)
      .populate("userId", "fullName phone email address")
      .populate("deliveryAgent", "fullName phone")
      .sort({ createdAt: -1 });

    const ordersWithItems = await Promise.all(
      orders.map(async (order) => {
        const items = await OrderItem.find({ orderId: order._id })
          .populate("foodstuffId", "name image unit price");
        return { order, items };
      })
    );

    res.json(ordersWithItems);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/orders/:id", agentOnly, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("userId", "fullName phone email address")
      .populate("deliveryAgent", "fullName phone vehicleType");

    if (!order) return res.status(404).json({ message: "Order not found" });

    const items = await OrderItem.find({ orderId: order._id })
      .populate("foodstuffId", "name image unit price");

    res.json({ order, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== ORDER STATUS UPDATES (delivery agent) ====================

router.put("/orders/:id/pickup", deliveryOnly, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });
    if (order.deliveryAgent && order.deliveryAgent.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "This order is assigned to another agent" });
    }

    order.status = "Out for Delivery";
    order.deliveryStatus = "picked_up";
    order.pickupTime = new Date();
    if (!order.deliveryAgent) order.deliveryAgent = req.user._id;
    await order.save();

    const updated = await Order.findById(order._id)
      .populate("userId", "fullName phone email address");

    const items = await OrderItem.find({ orderId: order._id })
      .populate("foodstuffId", "name image unit price");

    res.json({ order: updated, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/orders/:id/deliver", deliveryOnly, async (req, res) => {
  try {
    const { deliveryPin, deliveryPhoto, deliverySignature, deliveryNotes } = req.body;

    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });
    if (order.deliveryAgent && order.deliveryAgent.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "This order is assigned to another agent" });
    }

    order.status = "Delivered";
    order.deliveryStatus = "delivered";
    order.deliveryTime = new Date();
    if (deliveryPin) order.deliveryPin = deliveryPin;
    if (deliveryPhoto) order.deliveryPhoto = deliveryPhoto;
    if (deliverySignature) order.deliverySignature = deliverySignature;
    if (deliveryNotes) order.deliveryNotes = deliveryNotes;
    if (!order.deliveryAgent) order.deliveryAgent = req.user._id;
    await order.save();

    // Notify customer
    await Notification.create({
      userId: order.userId,
      title: "Order Delivered",
      message: `Your order #${order._id.toString().slice(-6).toUpperCase()} has been delivered successfully!`,
      type: "delivery_update",
      data: { orderId: order._id.toString(), status: "Delivered" },
    });

    const updated = await Order.findById(order._id)
      .populate("userId", "fullName phone email address");

    const items = await OrderItem.find({ orderId: order._id })
      .populate("foodstuffId", "name image unit price");

    res.json({ order: updated, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/orders/:id/fail", deliveryOnly, async (req, res) => {
  try {
    const { reason } = req.body;

    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });
    if (order.deliveryAgent && order.deliveryAgent.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "This order is assigned to another agent" });
    }

    order.status = "Cancelled";
    order.deliveryStatus = "failed";
    order.cancellationReason = reason || "Delivery failed";
    if (!order.deliveryAgent) order.deliveryAgent = req.user._id;
    await order.save();

    await Notification.create({
      userId: order.userId,
      title: "Delivery Failed",
      message: `Your order #${order._id.toString().slice(-6).toUpperCase()} could not be delivered. ${reason || ""}`,
      type: "delivery_update",
      data: { orderId: order._id.toString(), status: "Cancelled" },
    });

    const updated = await Order.findById(order._id)
      .populate("userId", "fullName phone email address");

    res.json({ order: updated });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/orders/:id/status", agentOnly, async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });

    if (req.user.role === "deliveryAgent") {
      if (order.deliveryAgent && order.deliveryAgent.toString() !== req.user._id.toString()) {
        return res.status(403).json({ message: "This order is assigned to another agent" });
      }
      if (!order.deliveryAgent) order.deliveryAgent = req.user._id;
    }

    order.status = status;
    await order.save();

    const updated = await Order.findById(order._id)
      .populate("userId", "fullName phone email address");

    const items = await OrderItem.find({ orderId: order._id })
      .populate("foodstuffId", "name image unit price");

    res.json({ order: updated, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Accept assignment
router.put("/orders/:id/accept", deliveryOnly, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });
    if (order.deliveryAgent && order.deliveryAgent.toString() !== req.user._id.toString()) {
      return res.status(400).json({ message: "Order already assigned to another agent" });
    }

    order.deliveryAgent = req.user._id;
    order.deliveryStatus = "assigned";
    await order.save();

    const updated = await Order.findById(order._id)
      .populate("userId", "fullName phone email address");

    const items = await OrderItem.find({ orderId: order._id })
      .populate("foodstuffId", "name image unit price");

    res.json({ order: updated, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Reject assignment
router.put("/orders/:id/reject", deliveryOnly, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });

    if (order.deliveryAgent && order.deliveryAgent.toString() === req.user._id.toString()) {
      order.deliveryAgent = null;
      order.deliveryStatus = "unassigned";
      await order.save();
    }

    res.json({ message: "Assignment rejected" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== STATS ====================

router.get("/stats", agentOnly, async (req, res) => {
  try {
    const agentId = req.user._id;
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - now.getDay());
    startOfWeek.setHours(0, 0, 0, 0);
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const totalDeliveries = await Order.countDocuments({ deliveryAgent: agentId, status: "Delivered" });
    const activeDeliveries = await Order.countDocuments({
      deliveryAgent: agentId,
      status: { $in: ["Out for Delivery", "On Route"] },
    });
    const pendingAssignments = await Order.countDocuments({
      deliveryAgent: null,
      status: { $in: ["Confirmed", "Ready"] },
    });

    const todayDeliveries = await Order.countDocuments({
      deliveryAgent: agentId,
      status: "Delivered",
      deliveryTime: { $gte: startOfDay },
    });

    const weekDeliveries = await Order.countDocuments({
      deliveryAgent: agentId,
      status: "Delivered",
      deliveryTime: { $gte: startOfWeek },
    });

    const monthDeliveries = await Order.countDocuments({
      deliveryAgent: agentId,
      status: "Delivered",
      deliveryTime: { $gte: startOfMonth },
    });

    const totalEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered" } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const totalEarnings = totalEarningsAgg.length > 0 ? totalEarningsAgg[0].total : 0;

    const todayEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered", deliveryTime: { $gte: startOfDay } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const todayEarnings = todayEarningsAgg.length > 0 ? todayEarningsAgg[0].total : 0;

    const monthEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered", deliveryTime: { $gte: startOfMonth } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const monthEarnings = monthEarningsAgg.length > 0 ? monthEarningsAgg[0].total : 0;

    const failedDeliveries = await Order.countDocuments({
      deliveryAgent: agentId,
      deliveryStatus: "failed",
    });

    const avgDeliveryTime = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered", pickupTime: { $ne: null }, deliveryTime: { $ne: null } } },
      {
        $project: {
          deliveryDuration: { $subtract: ["$deliveryTime", "$pickupTime"] },
        },
      },
      { $group: { _id: null, avg: { $avg: "$deliveryDuration" } } },
    ]);
    const avgMinutes = avgDeliveryTime.length > 0
      ? Math.round(avgDeliveryTime[0].avg / 60000)
      : 0;

    const recentOrders = await Order.find({ deliveryAgent: agentId })
      .populate("userId", "fullName phone")
      .sort({ createdAt: -1 })
      .limit(10);

    res.json({
      totalDeliveries,
      activeDeliveries,
      pendingAssignments,
      todayDeliveries,
      weekDeliveries,
      monthDeliveries,
      totalEarnings,
      todayEarnings,
      monthEarnings,
      failedDeliveries,
      avgDeliveryMinutes: avgMinutes,
      recentOrders,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== EARNINGS ====================

router.get("/earnings", deliveryOnly, async (req, res) => {
  try {
    const agentId = req.user._id;
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const totalEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered" } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const totalEarnings = totalEarningsAgg.length > 0 ? totalEarningsAgg[0].total : 0;

    const todayEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered", deliveryTime: { $gte: startOfDay } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const todayEarnings = todayEarningsAgg.length > 0 ? todayEarningsAgg[0].total : 0;

    const monthEarningsAgg = await Order.aggregate([
      { $match: { deliveryAgent: agentId, status: "Delivered", deliveryTime: { $gte: startOfMonth } } },
      { $group: { _id: null, total: { $sum: "$total" } } },
    ]);
    const monthEarnings = monthEarningsAgg.length > 0 ? monthEarningsAgg[0].total : 0;

    const todayCount = await Order.countDocuments({
      deliveryAgent: agentId,
      status: "Delivered",
      deliveryTime: { $gte: startOfDay },
    });

    const monthCount = await Order.countDocuments({
      deliveryAgent: agentId,
      status: "Delivered",
      deliveryTime: { $gte: startOfMonth },
    });

    const totalCount = await Order.countDocuments({
      deliveryAgent: agentId,
      status: "Delivered",
    });

    const history = await Order.find({ deliveryAgent: agentId, status: "Delivered" })
      .populate("userId", "fullName")
      .sort({ deliveryTime: -1 })
      .limit(50);

    res.json({
      summary: {
        totalEarnings,
        todayEarnings,
        monthEarnings,
        totalCount,
        todayCount,
        monthCount,
        avgPerDelivery: totalCount > 0 ? Math.round(totalEarnings / totalCount) : 0,
      },
      history,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== NOTIFICATIONS ====================

router.get("/notifications", agentOnly, async (req, res) => {
  try {
    const notifications = await Notification.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .limit(50);

    const unreadCount = await Notification.countDocuments({ userId: req.user._id, isRead: false });

    res.json({ notifications, unreadCount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/notifications/:id/read", agentOnly, async (req, res) => {
  try {
    await Notification.findByIdAndUpdate(req.params.id, { $set: { isRead: true } });
    res.json({ message: "Marked as read" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/notifications/read-all", agentOnly, async (req, res) => {
  try {
    await Notification.updateMany({ userId: req.user._id, isRead: false }, { $set: { isRead: true } });
    res.json({ message: "All notifications marked as read" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/notifications/:id", agentOnly, async (req, res) => {
  try {
    await Notification.findByIdAndDelete(req.params.id);
    res.json({ message: "Notification deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== CHANGE PASSWORD ====================

router.put("/change-password", agentOnly, async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: "Current and new password are required" });
    }
    if (newPassword.length < 6) {
      return res.status(400).json({ message: "New password must be at least 6 characters" });
    }

    const user = await User.findById(req.user._id);
    if (!user) return res.status(404).json({ message: "User not found" });

    const isMatch = await bcrypt.compare(currentPassword, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: "Current password is incorrect" });
    }

    user.password = await bcrypt.hash(newPassword, 10);
    await user.save();

    res.json({ message: "Password changed successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
