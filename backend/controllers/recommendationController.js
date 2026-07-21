const Recommendation = require('../models/Recommendation');
const Product = require('../models/Product');
const Favorite = require('../models/Favorite');
const RecentlyViewed = require('../models/RecentlyViewed');
const Order = require('../models/Order');
const OrderItem = require('../models/OrderItem');
const Foodstuff = require('../models/Foodstuff');

exports.getRecommendations = async (req, res) => {
  try {
    const recommendations = await Recommendation.find({ user: req.user.id, isActive: true })
      .populate('product')
      .sort({ score: -1 })
      .limit(20);
    res.json(recommendations.filter(r => r.product));
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.generateRecommendations = async (req, res) => {
  try {
    const userId = req.user.id;
    const categoryScores = {};
    const viewedProductIds = new Set();

    // 1) Favorites → weight 3
    const favorites = await Favorite.find({ userId }).populate('mealId');
    for (const fav of favorites) {
      const meal = fav.mealId;
      if (!meal) continue;
      // Find the Product record for this meal
      const product = await Product.findOne({ name: meal.name, type: 'meal' }).select('_id categoryName');
      if (product) {
        viewedProductIds.add(product._id.toString());
        if (product.categoryName) {
          categoryScores[product.categoryName] = (categoryScores[product.categoryName] || 0) + 3;
        }
      }
    }

    // 2) Recently viewed → weight 2 (recency-weighted)
    const viewed = await RecentlyViewed.find({ user: userId })
      .populate('product')
      .sort({ viewedAt: -1 })
      .limit(15);
    viewed.forEach((item, i) => {
      if (!item.product) return;
      viewedProductIds.add(item.product._id.toString());
      const weight = Math.max(1, 2 - i * 0.1);
      if (item.product.categoryName) {
        categoryScores[item.product.categoryName] = (categoryScores[item.product.categoryName] || 0) + weight;
      }
    });

    // 3) Order history → weight 4 (strongest signal)
    const orders = await Order.find({ userId, status: { $ne: 'Cancelled' } }).sort({ createdAt: -1 }).limit(10);
    for (const order of orders) {
      const items = await OrderItem.find({ orderId: order._id });
      for (const item of items) {
        const foodstuff = await Foodstuff.findById(item.foodstuffId).select('name category');
        if (!foodstuff) continue;
        // Find Product matching this foodstuff
        const product = await Product.findOne({ name: foodstuff.name, type: 'grocery' }).select('_id categoryName');
        if (product) {
          viewedProductIds.add(product._id.toString());
          const cat = product.categoryName || foodstuff.category || 'Other';
          categoryScores[cat] = (categoryScores[cat] || 0) + 4;
        }
      }
    }

    // Pick top 5 preferred categories
    const preferredCategories = Object.entries(categoryScores)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([cat]) => cat);

    // Find products in preferred categories the user hasn't interacted with
    const query = { isAvailable: true };
    if (preferredCategories.length > 0) {
      query.$or = [
        { categoryName: { $in: preferredCategories } },
        { isPopular: true },
      ];
    } else {
      query.isPopular = true;
    }
    if (viewedProductIds.size > 0) {
      query._id = { $nin: Array.from(viewedProductIds) };
    }

    const recommendations = await Product.find(query)
      .sort({ favoritesCount: -1, isPopular: -1 })
      .limit(20);

    // Save to DB
    await Recommendation.deleteMany({ user: userId });
    const recs = recommendations.map((product, i) => ({
      user: userId,
      product: product._id,
      reason: preferredCategories.includes(product.categoryName)
        ? `Because you like ${product.categoryName}`
        : product.isPopular
          ? 'Popular with customers'
          : 'Recommended for you',
      score: recommendations.length - i,
      type: product.type,
    }));
    if (recs.length > 0) {
      await Recommendation.insertMany(recs);
    }

    res.json({ message: 'Recommendations generated', count: recs.length });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
