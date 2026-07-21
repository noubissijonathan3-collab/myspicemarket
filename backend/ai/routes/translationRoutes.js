const express = require("express");
const router = express.Router();
const translationController = require("../controllers/translationController");
const { protect } = require("../../middleware/auth");

router.post("/translate", protect, translationController.translate);
router.post("/translate-batch", protect, translationController.translateBatch);
router.get("/languages", translationController.getLanguages);

module.exports = router;
