const express = require("express");
const crypto = require("crypto");
const router = express.Router();
const Order = require("../models/Order");
const OrderItem = require("../models/OrderItem");
const { protect: authMiddleware } = require("../middleware/auth");
const { notifyOrderStatusChange, createNotification } = require("../utils/notify");

function generateDeliveryPin() {
  return String(crypto.randomInt(1000, 9999));
}

function maskPin(pin) {
  if (!pin) return "";
  return "XXXX";
}

function orderToSafe(order) {
  const obj = typeof order.toObject === "function" ? order.toObject() : { ...order };
  if (obj.deliveryPin) obj.deliveryPin = maskPin(obj.deliveryPin);
  return obj;
}

router.get("/", authMiddleware, async (req, res) => {
  try {
    let query = {};
    if (req.user.role === "customer") {
      query.userId = req.user._id;
    }
    const orders = await Order.find(query)
      .populate("preparationAgent", "fullName phone profileImage")
      .populate("deliveryAgent", "fullName phone profileImage")
      .sort({ createdAt: -1 });
    const safeOrders = orders.map(orderToSafe);
    res.json(safeOrders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id", authMiddleware, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate("preparationAgent", "fullName phone profileImage")
      .populate("deliveryAgent", "fullName phone profileImage");
    if (!order) return res.status(404).json({ message: "Order not found" });
    const items = await OrderItem.find({ orderId: order._id }).populate("foodstuffId", "name image unit");

    const safeOrder = orderToSafe(order);

    if (req.user.role === "customer" && String(order.userId) === String(req.user._id)) {
      safeOrder.deliveryPin = order.deliveryPin;
    }

    res.json({ order: safeOrder, items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { items: orderItems, delivery } = req.body;
    if (!orderItems || orderItems.length === 0) {
      return res.status(400).json({ message: "Order must contain at least one item" });
    }

    const Foodstuff = require("../models/Foodstuff");
    let total = 0;
    const itemDocs = [];

    for (const item of orderItems) {
      const foodstuff = await Foodstuff.findById(item.foodstuffId);
      if (!foodstuff) {
        return res.status(404).json({ message: `Foodstuff ${item.foodstuffId} not found` });
      }
      const lineTotal = foodstuff.price * item.quantity;
      total += lineTotal;
      itemDocs.push({
        foodstuffId: foodstuff._id,
        quantity: item.quantity,
        price: foodstuff.price,
      });
    }

    const deliveryPin = generateDeliveryPin();

    const order = new Order({
      userId: req.user._id,
      delivery,
      total,
      deliveryPin,
      status: "Pending",
    });
    const savedOrder = await order.save();

    const orderItemDocs = itemDocs.map((d) => ({ ...d, orderId: savedOrder._id }));
    await OrderItem.insertMany(orderItemDocs);

    const safeOrder = orderToSafe(savedOrder);
    safeOrder.deliveryPin = deliveryPin;

    await createNotification({
      userId: req.user._id,
      recipientRole: "customer",
      title: "Order Placed Successfully",
      message: `Your order has been placed and is pending confirmation.`,
      type: "ORDER",
      category: "orders",
      priority: "medium",
      orderId: savedOrder._id,
      actionLink: `/orders/${savedOrder._id}`,
      actionType: "view_order",
      metadata: { orderNumber: savedOrder._id, total },
    });

    res.status(201).json({ order: safeOrder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/:id/status", authMiddleware, async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });

    if (order.status === status) {
      return res.json(order);
    }

    if (!Order.canTransition(order.status, status)) {
      return res.status(400).json({
        message: `Cannot transition from "${order.status}" to "${status}"`,
        currentStatus: order.status,
        allowedTransitions: Order.canTransition ? (() => {
          const map = { Pending: ["Confirmed", "Cancelled"], Confirmed: ["Preparing", "Cancelled"], Preparing: ["Ready", "Cancelled"], Ready: ["Out for Delivery", "Cancelled"], "Out for Delivery": ["On Route", "Delivered", "Cancelled"], "On Route": ["Delivered", "Cancelled"], Delivered: [], Cancelled: [] };
          return map[order.status] || [];
        })() : [],
      });
    }

    if (status === "Delivered") {
      return res.status(400).json({ message: "Use the verify-delivery endpoint to complete delivery" });
    }

    const oldStatus = order.status;
    order.status = status;
    if (status === "Out for Delivery") {
      order.deliveryTime = new Date();
    }
    const updated = await order.save();

    const fullOrder = await Order.findById(order._id);
    await notifyOrderStatusChange(fullOrder, oldStatus, status);

    res.json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/:id/verify-delivery", authMiddleware, async (req, res) => {
  try {
    const { pin, latitude, longitude } = req.body;
    const order = await Order.findById(req.params.id);

    if (!order) return res.status(404).json({ message: "Order not found" });

    if (String(order.deliveryAgent) !== String(req.user._id)) {
      return res.status(403).json({ message: "You are not assigned to this order" });
    }

    if (order.status !== "Out for Delivery" && order.status !== "On Route") {
      return res.status(400).json({ message: `Order is not in delivery state (current: ${order.status})` });
    }

    if (order.deliveryVerified) {
      return res.status(400).json({ message: "Delivery has already been verified" });
    }

    if (order.deliveryPinLocked) {
      return res.status(423).json({ message: "Delivery verification is locked. Contact admin." });
    }

    if (!pin || pin.length !== 4) {
      return res.status(400).json({ message: "PIN must be 4 digits" });
    }

    if (pin !== order.deliveryPin) {
      order.deliveryPinAttempts += 1;

      if (order.deliveryPinAttempts >= 5) {
        order.deliveryPinLocked = true;
        await order.save();

        await createNotification({
          userId: order.userId,
          recipientRole: "customer",
          title: "Delivery Verification Locked",
          message: "Too many failed PIN attempts. Please contact admin for delivery verification.",
          type: "DELIVERY",
          category: "deliveries",
          priority: "critical",
          orderId: order._id,
          actionType: "view_order",
        });

        return res.status(423).json({
          message: "Too many failed attempts. Verification locked. Contact admin.",
          attempts: order.deliveryPinAttempts,
          locked: true,
        });
      }

      await order.save();
      return res.status(400).json({
        message: "Incorrect PIN",
        attempts: order.deliveryPinAttempts,
        maxAttempts: 5,
      });
    }

    order.status = "Delivered";
    order.deliveryVerified = true;
    order.deliveryCompletedAt = new Date();
    order.deliveryTime = new Date();
    if (latitude != null && longitude != null) {
      order.deliveryCompletedGps = { latitude, longitude };
    }
    await order.save();

    await notifyOrderStatusChange(order, "Out for Delivery", "Delivered");

    res.json({
      message: "Delivery verified successfully",
      order: { _id: order._id, status: order.status, deliveryCompletedAt: order.deliveryCompletedAt },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
