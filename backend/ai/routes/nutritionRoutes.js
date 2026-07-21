const express = require("express");
const router = express.Router();
const nutritionController = require("../controllers/nutritionController");
const { protect } = require("../../middleware/auth");

router.post("/analyze", protect, nutritionController.analyze);
router.get("/history", protect, nutritionController.history);

module.exports = router;
