const express = require("express");
const router = express.Router();
const voiceController = require("../controllers/voiceController");
const { protect } = require("../../middleware/auth");

router.post("/process", protect, voiceController.processVoice);

module.exports = router;
