const mongoose = require("mongoose");

const reviewLikeSchema = new mongoose.Schema(
  {
    reviewId: { type: mongoose.Schema.Types.ObjectId, ref: "Review", required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  },
  { timestamps: true }
);

reviewLikeSchema.index({ reviewId: 1, userId: 1 }, { unique: true });

module.exports = mongoose.model("ReviewLike", reviewLikeSchema);
