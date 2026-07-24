const express = require("express");
const router = express.Router();
const { protect: authMiddleware } = require("../middleware/auth");
const { registerToken, unregisterToken } = require("../utils/push");

router.post("/register", authMiddleware, async (req, res) => {
  try {
    const { token, platform, appType } = req.body;
    if (!token) return res.status(400).json({ message: "Token is required" });

    await registerToken(req.user._id, token, platform || "android", appType || "customer");
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/unregister", authMiddleware, async (req, res) => {
  try {
    const { token } = req.body;
    if (!token) return res.status(400).json({ message: "Token is required" });

    await unregisterToken(token);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
