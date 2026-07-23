const express = require("express");
const router = express.Router();
const ChatRoom = require("../models/ChatRoom");
const Message = require("../models/Message");
const User = require("../models/User");
const { protect: authMiddleware } = require("../middleware/auth");

// ==================== CHAT ROOM ENDPOINTS ====================

// Get chat room for an order — supports ?agentType=preparation|delivery
router.get("/room/:orderId", authMiddleware, async (req, res) => {
  try {
    const { agentType } = req.query;
    const query = { orderId: req.params.orderId };
    if (agentType) query.agentType = agentType;

    let room;
    if (agentType) {
      room = await ChatRoom.findOne(query);
    } else {
      // No agentType specified — return first room for backwards compat
      room = await ChatRoom.findOne({ orderId: req.params.orderId });
    }
    if (!room) return res.json(null);
    res.json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all chat rooms for an order (returns array)
router.get("/rooms/:orderId", authMiddleware, async (req, res) => {
  try {
    const rooms = await ChatRoom.find({ orderId: req.params.orderId });
    res.json(rooms);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create or get chat room for an order — accepts agentType
router.post("/room", authMiddleware, async (req, res) => {
  try {
    const { orderId, agentType } = req.body;
    if (!orderId) return res.status(400).json({ message: "orderId is required" });

    const resolvedType = agentType || "preparation";

    let room = await ChatRoom.findOne({ orderId, agentType: resolvedType });
    if (room) {
      const isAgent = req.user.role === "deliveryAgent" || req.user.role === "preparationAgent" || req.user.role === "admin";
      if (isAgent && !room.agentId) {
        room.agentId = req.user._id;
        room.agentName = req.user.fullName || "";
        room.agentAvatar = req.user.profileImage || "";
        await room.save();
      }
      return res.json(room);
    }

    const isAgent = req.user.role === "deliveryAgent" || req.user.role === "preparationAgent" || req.user.role === "admin";
    room = await ChatRoom.create({
      orderId,
      customerId: isAgent ? null : req.user._id,
      agentId: isAgent ? req.user._id : null,
      agentName: isAgent ? (req.user.fullName || "") : "",
      agentAvatar: isAgent ? (req.user.profileImage || "") : "",
      agentType: resolvedType,
    });
    res.status(201).json(room);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== MESSAGE ENDPOINTS ====================

// Get messages for an order (agent uses orderId, resolves to chatRoomId) — supports ?agentType=
router.get("/:orderId", authMiddleware, async (req, res) => {
  try {
    const { agentType } = req.query;
    const query = { orderId: req.params.orderId };
    if (agentType) query.agentType = agentType;

    const room = agentType
      ? await ChatRoom.findOne(query)
      : await ChatRoom.findOne({ orderId: req.params.orderId });
    if (!room) return res.json([]);
    const messages = await Message.find({ chatRoomId: room._id }).sort({ createdAt: 1 });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Send message for an order (agent uses orderId) — supports agentType in body
router.post("/:orderId", authMiddleware, async (req, res) => {
  try {
    const { message, type, fileUrl, agentType } = req.body;
    if (!message && !fileUrl) return res.status(400).json({ message: "Message is required" });

    const resolvedType = agentType || "preparation";
    let room = await ChatRoom.findOne({ orderId: req.params.orderId, agentType: resolvedType });
    if (!room) {
      const isAgent = req.user.role === "deliveryAgent" || req.user.role === "preparationAgent" || req.user.role === "admin";
      room = await ChatRoom.create({
        orderId: req.params.orderId,
        customerId: isAgent ? null : req.user._id,
        agentId: isAgent ? req.user._id : null,
        agentName: isAgent ? (req.user.fullName || "") : "",
        agentAvatar: isAgent ? (req.user.profileImage || "") : "",
        agentType: resolvedType,
      });
    }

    if (room.status === "closed") {
      return res.status(400).json({ message: "Chat is closed" });
    }

    const isAgent = req.user.role === "deliveryAgent" || req.user.role === "preparationAgent" || req.user.role === "admin";
    const senderRole = isAgent ? "agent" : "customer";

    const msg = await Message.create({
      chatRoomId: room._id,
      senderId: req.user._id,
      senderRole,
      message: message || "",
      type: type || "text",
      fileUrl: fileUrl || "",
    });

    res.status(201).json(msg);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Mark messages as read for an order
router.post("/:orderId/read", authMiddleware, async (req, res) => {
  try {
    const room = await ChatRoom.findOne({ orderId: req.params.orderId });
    if (!room) return res.status(404).json({ message: "Chat room not found" });

    const { messageIds } = req.body;
    const filter = { chatRoomId: room._id, senderId: { $ne: req.user._id }, read: false };
    if (messageIds && messageIds.length > 0) {
      filter._id = { $in: messageIds };
    }
    await Message.updateMany(filter, { read: true, readAt: new Date() });
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// ==================== COMPAT ENDPOINTS (customer app uses these) ====================

router.get("/messages/:chatRoomId", authMiddleware, async (req, res) => {
  try {
    const room = await ChatRoom.findById(req.params.chatRoomId);
    if (!room) return res.status(404).json({ message: "Chat room not found" });
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
