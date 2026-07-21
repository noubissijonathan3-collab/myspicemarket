const mealService = require("../services/mealService");

exports.suggest = async (req, res) => {
  try {
    const { query } = req.body;
    const suggestions = await mealService.suggestMeals(query || "", req.user._id);
    res.json({ suggestions });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.recommend = async (req, res) => {
  try {
    const recommendations = await mealService.recommendForUser(req.user._id);
    res.json({ recommendations });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.substitute = async (req, res) => {
  try {
    const { ingredient } = req.body;
    if (!ingredient) return res.status(400).json({ message: "Ingredient name is required" });
    const substitutes = await mealService.findSubstitutes(ingredient);
    res.json({ substitutes });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
