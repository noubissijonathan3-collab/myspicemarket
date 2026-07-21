const mongoose = require('mongoose');

const bannerSchema = new mongoose.Schema({
  title: { type: String, required: true },
  subtitle: { type: String, default: '' },
  image: { type: String, default: '' },
  buttonText: { type: String, default: 'Shop Now' },
  link: { type: String, default: '' },
  linkType: { type: String, enum: ['category', 'product', 'collection', 'url'], default: 'category' },
  linkValue: { type: String, default: '' },
  isActive: { type: Boolean, default: true },
  sortOrder: { type: Number, default: 0 },
  startDate: { type: Date },
  endDate: { type: Date },
  backgroundColor: { type: String, default: '#22c55e' },
}, { timestamps: true });

module.exports = mongoose.model('Banner', bannerSchema);
