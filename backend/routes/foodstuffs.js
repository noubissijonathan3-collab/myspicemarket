const express = require("express");
const router = express.Router();
const Foodstuff = require("../models/Foodstuff");

router.get("/", async (req, res) => {
  try {
    const { category, search, popular, page = 1, limit = 20 } = req.query;
    const filter = {};

    if (category && category !== "All") filter.category = category;
    if (search) {
      filter.$or = [
        { name: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const total = await Foodstuff.countDocuments(filter);
    const items = await Foodstuff.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(parseInt(limit));

    res.json({
      products: items,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/popular", async (req, res) => {
  try {
    const items = await Foodstuff.find({ isAvailable: true })
      .sort({ createdAt: -1 })
      .limit(10);
    res.json({ products: items });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/category/:category", async (req, res) => {
  try {
    const items = await Foodstuff.find({ category: req.params.category })
      .sort({ createdAt: -1 });
    res.json(items);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const item = await Foodstuff.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Foodstuff not found" });
    res.json(item);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/", async (req, res) => {
  try {
    const item = new Foodstuff(req.body);
    const saved = await item.save();
    res.status(201).json(saved);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.put("/:id", async (req, res) => {
  try {
    const updated = await Foodstuff.findByIdAndUpdate(req.params.id, req.body, { returnDocument: 'after' });
    if (!updated) return res.status(404).json({ message: "Foodstuff not found" });
    res.json(updated);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.delete("/:id", async (req, res) => {
  try {
    await Foodstuff.findByIdAndDelete(req.params.id);
    res.json({ message: "Foodstuff deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
