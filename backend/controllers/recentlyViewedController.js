const RecentlyViewed = require('../models/RecentlyViewed');

exports.getRecentlyViewed = async (req, res) => {
  try {
    const items = await RecentlyViewed.find({ user: req.user.id })
      .populate('product')
      .sort({ viewedAt: -1 })
      .limit(20);
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addRecentlyViewed = async (req, res) => {
  try {
    const { productId, type } = req.body;
    await RecentlyViewed.findOneAndUpdate(
      { user: req.user.id, product: productId },
      { viewedAt: Date.now() },
      { upsert: true }
    );
    const count = await RecentlyViewed.countDocuments({ user: req.user.id });
    if (count > 50) {
      const oldest = await RecentlyViewed.find({ user: req.user.id }).sort({ viewedAt: 1 }).limit(count - 50);
      const ids = oldest.map(o => o._id);
      await RecentlyViewed.deleteMany({ _id: { $in: ids } });
    }
    res.json({ message: 'Added to recently viewed' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.clearRecentlyViewed = async (req, res) => {
  try {
    await RecentlyViewed.deleteMany({ user: req.user.id });
    res.json({ message: 'Recently viewed cleared' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
