const Favorite = require('../models/Favorite');
const Product = require('../models/Product');

exports.getFavorites = async (req, res) => {
  try {
    const favorites = await Favorite.find({ user: req.user.id })
      .populate('product')
      .sort({ createdAt: -1 });
    res.json(favorites);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.toggleFavorite = async (req, res) => {
  try {
    const { productId } = req.body;
    const existing = await Favorite.findOne({ user: req.user.id, product: productId });
    if (existing) {
      await Favorite.findByIdAndDelete(existing._id);
      await Product.findByIdAndUpdate(productId, { $inc: { favoritesCount: -1 } });
      res.json({ favorited: false });
    } else {
      await Favorite.create({ user: req.user.id, product: productId });
      await Product.findByIdAndUpdate(productId, { $inc: { favoritesCount: 1 } });
      res.json({ favorited: true });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.checkFavorite = async (req, res) => {
  try {
    const fav = await Favorite.findOne({ user: req.user.id, product: req.params.productId });
    res.json({ favorited: !!fav });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
