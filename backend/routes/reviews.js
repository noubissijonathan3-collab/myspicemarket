const express = require("express");
const router = express.Router();
const Review = require("../models/Review");
const ReviewLike = require("../models/ReviewLike");
const Rating = require("../models/Rating");
const { protect: authMiddleware } = require("../middleware/auth");

async function recalculateRating(mealId) {
  const reviews = await Review.find({ mealId });
  const count = reviews.length;
  if (count === 0) {
    await Rating.findOneAndUpdate(
      { mealId },
      {
        averageRating: 0,
        reviewCount: 0,
        distribution: { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 },
        categoryAverages: {
          taste: 0, freshness: 0, packaging: 0, deliveryExperience: 0,
          portionSize: 0, valueForMoney: 0, overallSatisfaction: 0,
        },
        recommendationPercentage: 0,
        verifiedReviewCount: 0,
      },
      { upsert: true }
    );
    return;
  }

  const sum = reviews.reduce((acc, r) => acc + r.rating, 0);
  const dist = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  const catSums = { taste: 0, freshness: 0, packaging: 0, deliveryExperience: 0, portionSize: 0, valueForMoney: 0, overallSatisfaction: 0 };
  let verifiedCount = 0;
  let catCount = 0;

  for (const r of reviews) {
    dist[r.rating] = (dist[r.rating] || 0) + 1;
    if (r.verifiedPurchase) verifiedCount++;
    if (r.categoryRatings) {
      for (const key of Object.keys(catSums)) {
        if (r.categoryRatings[key] && r.categoryRatings[key] > 0) {
          catSums[key] += r.categoryRatings[key];
          catCount++;
        }
      }
    }
  }

  const categoryAverages = {};
  for (const key of Object.keys(catSums)) {
    categoryAverages[key] = count > 0 ? Math.round((catSums[key] / count) * 10) / 10 : 0;
  }

  const fourOrMore = (dist[4] || 0) + (dist[5] || 0);
  const recommendationPercentage = count > 0 ? Math.round((fourOrMore / count) * 100) : 0;

  await Rating.findOneAndUpdate(
    { mealId },
    {
      averageRating: Math.round((sum / count) * 10) / 10,
      reviewCount: count,
      distribution: dist,
      categoryAverages,
      recommendationPercentage,
      verifiedReviewCount: verifiedCount,
    },
    { upsert: true }
  );
}

router.get("/", async (req, res) => {
  try {
    const { limit = 10 } = req.query;
    const reviews = await Review.find({})
      .populate("userId", "fullName profileImage")
      .sort({ createdAt: -1 })
      .limit(parseInt(limit));
    res.json({ reviews });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/meal/:mealId", async (req, res) => {
  try {
    const { page = 1, limit = 10, rating, verified, hasPhotos, sort = "newest" } = req.query;
    const filter = { mealId: req.params.mealId };

    if (rating) filter.rating = parseInt(rating);
    if (verified === "true") filter.verifiedPurchase = true;
    if (hasPhotos === "true") filter.images = { $exists: true, $not: { $size: 0 } };

    let sortOption = {};
    switch (sort) {
      case "newest": sortOption = { createdAt: -1 }; break;
      case "oldest": sortOption = { createdAt: 1 }; break;
      case "highest": sortOption = { rating: -1, createdAt: -1 }; break;
      case "lowest": sortOption = { rating: 1, createdAt: -1 }; break;
      case "helpful": sortOption = { helpfulCount: -1, createdAt: -1 }; break;
      default: sortOption = { createdAt: -1 };
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const total = await Review.countDocuments(filter);
    const reviews = await Review.find(filter)
      .populate("userId", "fullName profileImage")
      .sort(sortOption)
      .skip(skip)
      .limit(parseInt(limit));

    res.json({
      reviews,
      total,
      page: parseInt(page),
      pages: Math.ceil(total / parseInt(limit)),
      hasMore: skip + reviews.length < total,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id", async (req, res) => {
  try {
    const review = await Review.findById(req.params.id).populate("userId", "fullName profileImage");
    if (!review) return res.status(404).json({ message: "Review not found" });
    res.json(review);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/", authMiddleware, async (req, res) => {
  try {
    const { mealId, rating, title, comment, images, verifiedPurchase, categoryRatings } = req.body;
    const existing = await Review.findOne({ mealId, userId: req.user._id });
    if (existing) {
      return res.status(400).json({ message: "You have already reviewed this meal" });
    }
    const review = new Review({
      mealId,
      userId: req.user._id,
      rating,
      title: title || "",
      comment: comment || "",
      images: images || [],
      verifiedPurchase: verifiedPurchase || false,
      categoryRatings: categoryRatings || {},
    });
    await review.save();
    await recalculateRating(mealId);
    res.status(201).json(review);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.put("/:id", authMiddleware, async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) return res.status(404).json({ message: "Review not found" });
    if (review.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Not authorized to edit this review" });
    }
    const { rating, title, comment, images, categoryRatings } = req.body;
    if (rating !== undefined) review.rating = rating;
    if (title !== undefined) review.title = title;
    if (comment !== undefined) review.comment = comment;
    if (images !== undefined) review.images = images;
    if (categoryRatings !== undefined) review.categoryRatings = categoryRatings;
    await review.save();
    await recalculateRating(review.mealId);
    res.json(review);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
});

router.delete("/:id", authMiddleware, async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) return res.status(404).json({ message: "Review not found" });
    if (review.userId.toString() !== req.user._id.toString() && req.user.role !== "admin") {
      return res.status(403).json({ message: "Not authorized to delete this review" });
    }
    const mealId = review.mealId;
    await Review.findByIdAndDelete(req.params.id);
    await ReviewLike.deleteMany({ reviewId: req.params.id });
    await recalculateRating(mealId);
    res.json({ message: "Review deleted" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/:id/helpful", authMiddleware, async (req, res) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) return res.status(404).json({ message: "Review not found" });

    const existing = await ReviewLike.findOne({ reviewId: req.params.id, userId: req.user._id });
    if (existing) {
      await ReviewLike.findByIdAndDelete(existing._id);
      review.helpfulCount = Math.max(0, review.helpfulCount - 1);
      await review.save();
      return res.json({ helpful: false, helpfulCount: review.helpfulCount });
    }

    await new ReviewLike({ reviewId: req.params.id, userId: req.user._id }).save();
    review.helpfulCount = (review.helpfulCount || 0) + 1;
    await review.save();
    res.json({ helpful: true, helpfulCount: review.helpfulCount });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.post("/:id/report", authMiddleware, async (req, res) => {
  try {
    res.json({ message: "Report submitted. Our team will review this content." });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

router.get("/:id/helpful-status", authMiddleware, async (req, res) => {
  try {
    const like = await ReviewLike.findOne({ reviewId: req.params.id, userId: req.user._id });
    res.json({ helpful: !!like });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
