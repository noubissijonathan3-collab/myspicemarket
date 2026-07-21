const mongoose = require('mongoose');

const seasonalCollectionSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: '' },
  image: { type: String, default: '' },
  startDate: { type: Date },
  endDate: { type: Date },
  isActive: { type: Boolean, default: true },
  products: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Product' }],
  theme: { type: String, default: '' },
  sortOrder: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('SeasonalCollection', seasonalCollectionSchema);
