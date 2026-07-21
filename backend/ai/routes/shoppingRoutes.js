const express = require("express");
const router = express.Router();
const shoppingAssistantController = require("../controllers/shoppingAssistantController");
const { protect } = require("../../middleware/auth");

router.post("/budget", protect, shoppingAssistantController.budgetPlan);
router.post("/weekly-plan", protect, shoppingAssistantController.weeklyPlan);
router.get("/add-ons/:orderId", protect, shoppingAssistantController.addOns);
router.post("/search", protect, shoppingAssistantController.search);
router.post("/assistant", protect, shoppingAssistantController.assistantChat);

module.exports = router;
