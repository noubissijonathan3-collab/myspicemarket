const nutritionService = require("../services/nutritionService");

exports.analyze = async (req, res) => {
  try {
    const { mealId, query } = req.body;
    const result = await nutritionService.analyzeMeal(mealId, query || "", req.user._id);
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.history = async (req, res) => {
  try {
    const history = await nutritionService.getHistory(req.user._id);
    res.json(history);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
