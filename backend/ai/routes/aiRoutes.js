const express = require("express");
const router = express.Router();
const aiController = require("../controllers/aiController");
const { protect } = require("../../middleware/auth");

router.post("/chat", protect, aiController.chat);
router.get("/conversations", protect, aiController.getConversations);
router.get("/conversations/:id", protect, aiController.getConversation);
router.delete("/conversations/:id", protect, aiController.deleteConversation);

module.exports = router;
