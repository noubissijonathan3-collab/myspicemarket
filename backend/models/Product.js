const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true },
  description: { type: String, default: '' },
  type: { type: String, enum: ['meal', 'grocery'], required: true },
  category: { type: mongoose.Schema.Types.ObjectId, ref: 'Category' },
  categoryName: { type: String, default: '' },
  price: { type: Number, required: true },
  unit: { type: String, default: '' },
  stock: { type: Number, default: 0 },
  image: { type: String, default: '' },
  isAvailable: { type: Boolean, default: true },
  isPopular: { type: Boolean, default: false },
  badge: { type: String, default: '' },
  preparationTime: { type: Number, default: 0 },
  difficulty: { type: String, default: 'Easy' },
  servings: { type: Number, default: 1 },
  ingredientsCount: { type: Number, default: 0 },
  favoritesCount: { type: Number, default: 0 },
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
