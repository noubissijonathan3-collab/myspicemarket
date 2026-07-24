const express = require("express");
const router = express.Router();
const Notification = require("../models/Notification");
const { protect: authMiddleware } = require("../middleware/auth");

router.get("/", authMiddleware, async (req, res) => {
  try {
    const { category, type, unreadOnly, limit = 50, page = 1 } = req.query;
    const query = { user: req.user._id };

    if (category) query.category = category;
    if (type) query.type = type;
    if (unreadOnly === "true") query.isRead = false;

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const [notifications, total, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(parseInt(limit)),
      Notification.countDocuments(query),
      Notification.countDocuments({ user: req.user._id, isRead: false }),
    ]);

    res.json({
      notifications,
      unreadCount,
      total,
      page: parseInt(page),
      totalPages: Math.ceil(total / parseInt(limit)),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/unread-count", authMiddleware, async (req, res) => {
  try {
    const count = await Notification.countDocuments({
      user: req.user._id,
      isRead: false,
    });
    res.json({ count });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/categories", authMiddleware, async (req, res) => {
  try {
    const counts = await Notification.aggregate([
      { $match: { user: req.user._id } },
      { $group: { _id: "$category", total: { $sum: 1 }, unread: { $sum: { $cond: ["$isRead", 0, 1] } } } },
      { $sort: { _id: 1 } },
    ]);

    const result = {};
    for (const cat of Notification.CATEGORIES) {
      const found = counts.find((c) => c._id === cat);
      result[cat] = { total: found ? found.total : 0, unread: found ? found.unread : 0 };
    }
    res.json(result);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/:id/read", authMiddleware, async (req, res) => {
  try {
    const updated = await Notification.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { isRead: true, readAt: new Date() },
      { returnDocument: "after" }
    );
    if (!updated) return res.status(404).json({ message: "Notification not found" });
    res.json(updated);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/read-all", authMiddleware, async (req, res) => {
  try {
    const { category } = req.body;
    const query = { user: req.user._id, isRead: false };
    if (category) query.category = category;

    await Notification.updateMany(query, { isRead: true, readAt: new Date() });

    const unreadCount = await Notification.countDocuments({ user: req.user._id, isRead: false });
    res.json({ success: true, unreadCount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const deleted = await Notification.findOneAndDelete({
      _id: req.params.id,
      user: req.user._id,
    });
    if (!deleted) return res.status(404).json({ message: "Notification not found" });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/clear-all", authMiddleware, async (req, res) => {
  try {
    const { category } = req.query;
    const query = { user: req.user._id };
    if (category) query.category = category;

    await Notification.deleteMany(query);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
