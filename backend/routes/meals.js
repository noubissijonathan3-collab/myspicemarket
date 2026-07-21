const express = require("express");
const router = express.Router();
const Meal = require("../models/Meal");
const MealIngredient = require("../models/MealIngredient");

router.get("/", async (req, res) => {
  try {
    const { categoryId, popular, search, page = 1, limit = 20 } = req.query;
    const filter = {};

    if (categoryId) filter.categoryId = categoryId;
    if (popular === "true") filter.isPopular = true;
    if (search) {
      filter.name = { $regex: search, $options: "i" };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const total = await Meal.countDocuments(filter);
    const meals = await Meal.find(filter)
      .populate("categoryId", "name image")
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));
    res.json({ meals, total, page: parseInt(page), pages: Math.ceil(total / parseInt(limit)) });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/popular", async (req, res) => {
  try {
    const meals = await Meal.find({ isPopular: true })
      .populate("categoryId", "name image")
      .sort({ createdAt: -1 })
      .limit(10);
    res.json({ meals });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const meal = await Meal.findById(req.params.id)
      .populate("categoryId", "name image");
    if (!meal) return res.status(404).json({ message: "Meal not found" });
    res.json(meal);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id/ingredients", async (req, res) => {
  try {
    const ingredients = await MealIngredient.find({ mealId: req.params.id })
      .populate("foodstuffId", "name price unit image");
    res.json(ingredients);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const meal = new Meal(req.body);
    const saved = await meal.save();
    res.status(201).json(saved);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.put("/:id", async (req, res) => {
  try {
    const updated = await Meal.findByIdAndUpdate(req.params.id, req.body, { returnDocument: 'after' });
    if (!updated) return res.status(404).json({ message: "Meal not found" });
    res.json(updated);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    await Meal.findByIdAndDelete(req.params.id);
    await MealIngredient.deleteMany({ mealId: req.params.id });
    res.json({ message: "Meal deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
