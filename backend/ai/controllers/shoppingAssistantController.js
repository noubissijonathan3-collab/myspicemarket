const shoppingService = require("../services/shoppingService");
const mealService = require("../services/mealService");
const aiService = require("../services/aiService");

exports.budgetPlan = async (req, res) => {
  try {
    const { budget } = req.body;
    if (!budget) return res.status(400).json({ message: "Budget is required" });
    const plan = await shoppingService.planBudget(req.user._id, budget);
    res.json(plan);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.weeklyPlan = async (req, res) => {
  try {
    const { familySize, budget, preferences } = req.body;
    const plan = await shoppingService.generateWeeklyPlan(req.user._id, familySize || 1, budget || 0, preferences || []);
    res.json(plan);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addOns = async (req, res) => {
  try {
    const { orderId } = req.params;
    const suggestions = await shoppingService.suggestAddOns(orderId);
    res.json({ suggestions });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.search = async (req, res) => {
  try {
    const { query } = req.body;
    const results = await mealService.suggestMeals(query || "", req.user._id);
    res.json({ results });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.assistantChat = async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) return res.status(400).json({ message: "Message is required" });
    const result = await aiService.processChat(req.user._id, message, "shopping");
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
