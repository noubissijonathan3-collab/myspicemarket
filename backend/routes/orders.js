const express = require("express");
const router = express.Router();
const Order = require("../models/Order");
const OrderItem = require("../models/OrderItem");
const { protect: authMiddleware } = require("../middleware/auth");

router.get("/", authMiddleware, async (req, res) => {
  try {
    let query = {};
    if (req.user.role === "customer") {
      query.userId = req.user._id;
    }
    const orders = await Order.find(query)
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id", authMiddleware, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "Order not found" });
    const items = await OrderItem.find({ orderId: order._id }).populate("foodstuffId", "name image unit");
    res.json({ order, items });
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

    const order = new Order({
      userId: req.user._id,
      delivery,
      total,
    });
    const savedOrder = await order.save();

    const orderItemDocs = itemDocs.map((d) => ({ ...d, orderId: savedOrder._id }));
    await OrderItem.insertMany(orderItemDocs);

    res.status(201).json({ order: savedOrder });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/:id/status", authMiddleware, async (req, res) => {
  try {
    const { status } = req.body;
    const updated = await Order.findByIdAndUpdate(req.params.id, { status }, { returnDocument: 'after' });
    if (!updated) return res.status(404).json({ message: "Order not found" });
    res.json(updated);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

module.exports = router;
