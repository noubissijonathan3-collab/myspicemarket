const jwt = require("jsonwebtoken");
const User = require("./models/User");
const ChatRoom = require("./models/ChatRoom");
const Message = require("./models/Message");

const setupSocket = (io) => {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.query.token;
      if (!token) return next(new Error("Authentication required"));
      const decoded = jwt.verify(token, process.env.JWT_SECRET || "spicemarket_jwt_secret");
      const user = await User.findById(decoded.userId).select("-password");
      if (!user) return next(new Error("User not found"));
      socket.user = user;
      next();
    } catch (err) {
      next(new Error("Invalid token"));
    }
  });

  io.on("connection", (socket) => {
    console.log(`User connected: ${socket.user.fullName || socket.user.name || "Unknown"} (${socket.user._id}) role=${socket.user.role}`);

    // Join a chat room by chatRoomId
    socket.on("join_chat", async ({ chatRoomId }) => {
      if (!chatRoomId) return;
      socket.join(chatRoomId);
      await Message.updateMany(
        { chatRoomId, senderId: { $ne: socket.user._id }, read: false },
        { read: true, readAt: new Date() }
      );
      socket.to(chatRoomId).emit("user_online", { userId: socket.user._id.toString() });
    });

    // Join a chat room by orderId — resolves orderId to chatRoomId
    socket.on("join_order", async ({ orderId }) => {
      if (!orderId) return;
      try {
        let room = await ChatRoom.findOne({ orderId });
        if (!room) {
          const isAgent = socket.user.role === "deliveryAgent" || socket.user.role === "preparationAgent" || socket.user.role === "admin";
          room = await ChatRoom.create({
            orderId,
            customerId: isAgent ? null : socket.user._id,
            agentId: isAgent ? socket.user._id : null,
            agentName: isAgent ? (socket.user.fullName || "") : "",
            agentAvatar: isAgent ? (socket.user.profileImage || "") : "",
          });
        } else {
          const isAgent = socket.user.role === "deliveryAgent" || socket.user.role === "preparationAgent" || socket.user.role === "admin";
          if (isAgent && !room.agentId) {
            room.agentId = socket.user._id;
            room.agentName = socket.user.fullName || "";
            room.agentAvatar = socket.user.profileImage || "";
            await room.save();
          }
        }
        const chatRoomId = room._id.toString();
        socket.join(chatRoomId);

        socket.emit("chat_room_joined", {
          chatRoomId,
          orderId,
          customerId: room.customerId,
          agentId: room.agentId,
          agentName: room.agentName,
          agentAvatar: room.agentAvatar,
          status: room.status,
        });

        await Message.updateMany(
          { chatRoomId, senderId: { $ne: socket.user._id }, read: false },
          { read: true, readAt: new Date() }
        );
        socket.to(chatRoomId).emit("user_online", { userId: socket.user._id.toString() });
      } catch (err) {
        console.error("join_order error:", err.message);
        socket.emit("chat_error", { message: "Failed to join order chat" });
      }
    });

    socket.on("leave_chat", ({ chatRoomId }) => {
      if (!chatRoomId) return;
      socket.leave(chatRoomId);
      socket.to(chatRoomId).emit("user_offline", { userId: socket.user._id.toString() });
    });

    socket.on("leave_order", ({ orderId }) => {
      if (!orderId) return;
      ChatRoom.findOne({ orderId }).then((room) => {
        if (room) {
          socket.leave(room._id.toString());
          socket.to(room._id.toString()).emit("user_offline", { userId: socket.user._id.toString() });
        }
      }).catch(() => {});
    });

    socket.on("send_message", async ({ chatRoomId, message, type, fileUrl }, callback) => {
      try {
        if (!chatRoomId) {
          if (typeof callback === "function") callback({ error: "chatRoomId is required" });
          return;
        }
        const room = await ChatRoom.findById(chatRoomId);
        if (!room) {
          if (typeof callback === "function") callback({ error: "Chat room not found" });
          return;
        }
        if (room.status === "closed") {
          if (typeof callback === "function") callback({ error: "Chat is closed" });
          return;
        }

        const isAgent = socket.user.role === "deliveryAgent" || socket.user.role === "preparationAgent" || socket.user.role === "admin";
        const senderRole = isAgent ? "agent" : "customer";

        const msg = await Message.create({
          chatRoomId,
          senderId: socket.user._id,
          senderRole,
          message: message || "",
          type: type || "text",
          fileUrl: fileUrl || "",
        });

        const populated = await Message.findById(msg._id);

        io.to(chatRoomId).emit("new_message", populated);
        if (typeof callback === "function") callback({ success: true, message: populated });
      } catch (err) {
        if (typeof callback === "function") callback({ error: err.message });
      }
    });

    socket.on("typing", ({ chatRoomId, isTyping }) => {
      if (!chatRoomId) return;
      socket.to(chatRoomId).emit("user_typing", {
        userId: socket.user._id.toString(),
        fullName: socket.user.fullName,
        chatRoomId,
        isTyping,
      });
    });

    socket.on("mark_read", async ({ chatRoomId }) => {
      if (!chatRoomId) return;
      await Message.updateMany(
        { chatRoomId, senderId: { $ne: socket.user._id }, read: false },
        { read: true, readAt: new Date() }
      );
      socket.to(chatRoomId).emit("messages_read", { userId: socket.user._id.toString() });
    });

    // ==================== IN-APP CALL SIGNALING ====================

    socket.on("call:initiate", ({ targetUserId, orderId, callerName, callerRole }) => {
      const callerId = socket.user._id.toString();
      socket.join("call_" + callerId);

      const targetSockets = Array.from(io.sockets.sockets.values())
        .filter((s) => s.user && s.user._id.toString() === targetUserId);

      if (targetSockets.length === 0) {
        socket.emit("call:unavailable", { message: "User is currently offline" });
        return;
      }

      targetSockets.forEach((targetSocket) => {
        targetSocket.emit("call:incoming", {
          callerId,
          callerName: callerName || socket.user.fullName,
          callerRole: callerRole || socket.user.role,
          orderId,
        });
      });

      socket.emit("call:ringing", { targetUserId });
    });

    socket.on("call:accept", ({ callerId }) => {
      const callerSockets = Array.from(io.sockets.sockets.values())
        .filter((s) => s.user && s.user._id.toString() === callerId);

      callerSockets.forEach((callerSocket) => {
        callerSocket.emit("call:accepted", {
          accepterId: socket.user._id.toString(),
          accepterName: socket.user.fullName,
        });
      });
    });

    socket.on("call:reject", ({ callerId }) => {
      const callerSockets = Array.from(io.sockets.sockets.values())
        .filter((s) => s.user && s.user._id.toString() === callerId);

      callerSockets.forEach((callerSocket) => {
        callerSocket.emit("call:rejected", {
          rejecterId: socket.user._id.toString(),
        });
      });
    });

    socket.on("call:sdp", ({ targetUserId, sdp, type }) => {
      const targetSockets = Array.from(io.sockets.sockets.values())
        .filter((s) => s.user && s.user._id.toString() === targetUserId);

      targetSockets.forEach((targetSocket) => {
        targetSocket.emit("call:sdp", {
          senderId: socket.user._id.toString(),
          sdp,
          type,
        });
      });
    });

    socket.on("call:ice", ({ targetUserId, candidate }) => {
      const targetSockets = Array.from(io.sockets.sockets.values())
        .filter((s) => s.user && s.user._id.toString() === targetUserId);

      targetSockets.forEach((targetSocket) => {
        targetSocket.emit("call:ice", {
          senderId: socket.user._id.toString(),
          candidate,
        });
      });
    });

    socket.on("call:end", ({ targetUserId }) => {
      const targetSockets = Array.from(io.sockets.sockets.values())
        .filter((s) => s.user && s.user._id.toString() === targetUserId);

      targetSockets.forEach((targetSocket) => {
        targetSocket.emit("call:ended", {
          endedBy: socket.user._id.toString(),
        });
      });
    });

    // ==================== GPS LOCATION TRACKING ====================

    socket.on("location:update", (data) => {
      try {
        const { latitude, longitude, speed, heading, altitude, accuracy, orderId, status, remainingDistance, estimatedArrival } = data;
        if (latitude == null || longitude == null) return;

        const locationData = {
          agentId: socket.user._id.toString(),
          agentName: socket.user.fullName || "Agent",
          vehicleType: socket.user.vehicleType || "",
          latitude,
          longitude,
          speed: speed || 0,
          heading: heading || 0,
          altitude: altitude || 0,
          accuracy: accuracy || 0,
          orderId: orderId || null,
          status: status || "en_route_to_customer",
          remainingDistance: remainingDistance || 0,
          estimatedArrival: estimatedArrival || 0,
          timestamp: new Date().toISOString(),
        };

        if (orderId) {
          io.to("tracking_" + orderId).emit("agent:location", locationData);
        } else {
          io.emit("location:updated", locationData);
        }
      } catch (err) {
        console.error("Location update error:", err.message);
      }
    });

    socket.on("tracking:join", ({ orderId }) => {
      if (orderId) {
        socket.join("tracking_" + orderId);
      }
    });

    socket.on("tracking:leave", ({ orderId }) => {
      if (orderId) {
        socket.leave("tracking_" + orderId);
      }
    });

    socket.on("disconnect", () => {
      console.log(`User disconnected: ${socket.user.fullName}`);
    });
  });
};

module.exports = setupSocket;
