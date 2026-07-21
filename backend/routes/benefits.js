const express = require("express");
const router = express.Router();
const Benefit = require("../models/Benefit");

router.get("/", async (req, res) => {
  try {
    const benefits = await Benefit.find({ isActive: true }).sort({ sortOrder: 1 });
    res.json({ benefits });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
