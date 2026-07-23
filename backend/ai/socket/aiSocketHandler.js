const aiService = require("../services/aiService");
const translationService = require("../services/translationService");

const setupAiSocket = (io) => {
  const aiNamespace = io.of("/ai");

  aiNamespace.use(async (socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.query.token;
    if (!token) return next(new Error("Authentication required"));

    try {
      const jwt = require("jsonwebtoken");
      const User = require("../../models/User");
      const decoded = jwt.verify(token, process.env.JWT_SECRET || "spicemarket_jwt_secret");
      const user = await User.findById(decoded.userId).select("-password");
      if (!user) return next(new Error("User not found"));
      socket.user = user;
      next();
    } catch (err) {
      next(new Error("Invalid token"));
    }
  });

  aiNamespace.on("connection", (socket) => {
    console.log(`AI socket connected: ${socket.user.fullName || socket.user.name} (${socket.user._id})`);

    socket.on("ai_chat", async ({ message, context }, callback) => {
      try {
        const result = await aiService.processChat(socket.user._id, message, context || "general");
        if (typeof callback === "function") callback({ success: true, ...result });
      } catch (err) {
        if (typeof callback === "function") callback({ error: err.message });
      }
    });

    socket.on("ai_translate", async ({ text, targetLanguage, sourceLanguage, contextType }, callback) => {
      try {
        const translated = await translationService.translate(text, targetLanguage, sourceLanguage, contextType);
        if (typeof callback === "function") callback({ success: true, translatedText: translated });
      } catch (err) {
        if (typeof callback === "function") callback({ error: err.message });
      }
    });

    socket.on("disconnect", () => {
      console.log(`AI socket disconnected: ${socket.user.fullName || socket.user.name}`);
    });
  });
};

module.exports = setupAiSocket;
