const express = require("express");
const router = express.Router();
const ChatRoom = require("../models/ChatRoom");
const Message = require("../models/Message");
const User = require("../models/User");
const { protect: authMiddleware } = require("../middleware/auth");

router.get("/room/:orderId", authMiddleware, async (req, res) => {
  try {
    let room = await ChatRoom.findOne({ orderId: req.params.orderId, customerId: req.user._id });
    if (!room) {
      return res.json(null);
    }
    res.json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/room", authMiddleware, async (req, res) => {
  try {
    const { orderId } = req.body;
    let room = await ChatRoom.findOne({ orderId, customerId: req.user._id });
    if (room) {
      return res.json(room);
    }
    room = await ChatRoom.create({ orderId, customerId: req.user._id });
    res.status(201).json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/messages/:chatRoomId", authMiddleware, async (req, res) => {
  try {
    const room = await ChatRoom.findById(req.params.chatRoomId);
    if (!room) return res.status(404).json({ message: "Chat room not found" });
    if (room.customerId.toString() !== req.user._id.toString() && req.user.role !== "admin") {
      return res.status(403).json({ message: "Not authorized" });
    }
    const messages = await Message.find({ chatRoomId: req.params.chatRoomId }).sort({ createdAt: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/messages/read/:chatRoomId", authMiddleware, async (req, res) => {
  try {
    await Message.updateMany(
      { chatRoomId: req.params.chatRoomId, senderId: { $ne: req.user._id }, read: false },
      { read: true, readAt: new Date() }
    );
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
