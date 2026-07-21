const mongoose = require("mongoose");

const translationSchema = new mongoose.Schema(
  {
    sourceText: { type: String, required: true },
    sourceLanguage: { type: String, required: true },
    targetLanguage: { type: String, required: true },
    translatedText: { type: String, required: true },
    contextType: { type: String, enum: ["meal", "ingredient", "review", "chat", "notification", "ui"], default: "meal" },
    usageCount: { type: Number, default: 0 },
  },
  { timestamps: true }
);

translationSchema.index({ sourceText: 1, sourceLanguage: 1, targetLanguage: 1 }, { unique: true });

module.exports = mongoose.model("Translation", translationSchema);
