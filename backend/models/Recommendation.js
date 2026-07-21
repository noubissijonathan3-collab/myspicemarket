const mongoose = require('mongoose');

const recommendationSchema = new mongoose.Schema({
  user: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  product: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  reason: { type: String, default: '' },
  score: { type: Number, default: 0 },
  type: { type: String, enum: ['meal', 'grocery'], required: true },
  isActive: { type: Boolean, default: true },
}, { timestamps: true });

recommendationSchema.index({ user: 1, score: -1 });

module.exports = mongoose.model('Recommendation', recommendationSchema);
