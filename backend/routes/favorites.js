const express = require("express");
const router = express.Router();
const Favorite = require("../models/Favorite");
const Meal = require("../models/Meal");
const { protect: authMiddleware } = require("../middleware/auth");

router.get("/", authMiddleware, async (req, res) => {
  try {
    const favorites = await Favorite.find({ userId: req.user._id })
      .populate({
        path: "mealId",
        populate: { path: "categoryId", select: "name" },
      });
    res.json(favorites);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { mealId } = req.body;
    const existing = await Favorite.findOne({ userId: req.user._id, mealId });
    if (existing) {
      return res.status(400).json({ message: "Already favorited" });
    }
    const fav = new Favorite({ userId: req.user._id, mealId });
    await fav.save();
    await Meal.findByIdAndUpdate(mealId, { $inc: { favoritesCount: 1 } });
    res.status(201).json(fav);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.delete("/:mealId", authMiddleware, async (req, res) => {
  try {
    await Favorite.findOneAndDelete({ userId: req.user._id, mealId: req.params.mealId });
    await Meal.findByIdAndUpdate(req.params.mealId, { $inc: { favoritesCount: -1 } });
    res.json({ message: "Favorite removed" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
