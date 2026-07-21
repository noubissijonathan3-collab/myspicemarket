const Meal = require("../../models/Meal");
const Favorite = require("../../models/Favorite");
const Order = require("../../models/Order");
const MealRecommendation = require("../models/MealRecommendation");

exports.suggestMeals = async (query, userId) => {
  const meals = await Meal.find().populate("categoryId").lean();
  const lower = query.toLowerCase();

  const keywordMatches = meals.filter((m) => {
    const nameMatch = m.name.toLowerCase().includes(lower);
    const descMatch = m.description?.toLowerCase().includes(lower);
    const catMatch = m.categoryId?.name?.toLowerCase().includes(lower);
    const ingredients = (m.ingredients || []).map((i) => (i.foodstuffId?.name || i.name || "").toLowerCase());
    const ingredMatch = ingredients.some((i) => lower.split(" ").some((w) => i.includes(w)));
    return nameMatch || descMatch || catMatch || ingredMatch;
  });

  if (keywordMatches.length > 0) {
    return keywordMatches.slice(0, 5).map((m) => ({
      meal: m,
      reason: "This meal matches your search criteria.",
      score: 95,
    }));
  }

  const semanticMatches = meals.slice(0, 3).map((m) => ({
    meal: m,
    reason: "Popular meal that you might enjoy.",
    score: 70,
  }));

  return semanticMatches;
};

exports.recommendForUser = async (userId) => {
  const preferences = await MealRecommendation.find({ userId }).sort({ score: -1 }).limit(10);

  if (preferences.length > 0) {
    const meals = await Meal.find({ _id: { $in: preferences.map((p) => p.mealId) } }).lean();
    return meals.map((m) => ({
      meal: m,
      reason: "Recommended based on your preferences.",
      score: 90,
    }));
  }

  const recentOrders = await Order.find({ customerId: userId }).sort({ createdAt: -1 }).limit(5).populate("items.mealId").lean();
  const orderedMealIds = recentOrders.flatMap((o) => o.items?.map((i) => i.mealId?._id?.toString()).filter(Boolean) || []);

  if (orderedMealIds.length > 0) {
    const similar = await Meal.find({ _id: { $nin: orderedMealIds } }).limit(5).lean();
    return similar.map((m) => ({
      meal: m,
      reason: "Because you enjoyed similar meals before.",
      score: 80,
    }));
  }

  const popular = await Meal.find().sort({ favoritesCount: -1 }).limit(5).lean();
  return popular.map((m) => ({
    meal: m,
    reason: "One of our most popular meals!",
    score: 85,
  }));
};

exports.findSubstitutes = async (ingredientName) => {
  const substitutes = {
    tomato: ["Tomato paste", "Cherry tomatoes", "Canned tomatoes", "Red bell peppers"],
    onion: ["Shallots", "Leeks", "Green onions", "Onion powder"],
    garlic: ["Garlic powder", "Shallots", "Asafoetida"],
    butter: ["Margarine", "Coconut oil", "Olive oil", "Ghee"],
    milk: ["Evaporated milk", "Coconut milk", "Almond milk", "Soy milk"],
    egg: ["Flax egg", "Banana (mashed)", "Applesauce", "Silken tofu"],
    flour: ["Rice flour", "Almond flour", "Coconut flour", "Oat flour"],
    sugar: ["Honey", "Maple syrup", "Stevia", "Coconut sugar"],
    rice: ["Quinoa", "Couscous", "Cauliflower rice", "Bulgur"],
    chicken: ["Turkey", "Tofu", "Fish", "Beef strips"],
    fish: ["Shrimp", "Chicken", "Tofu", "Mushrooms"],
    beef: ["Lamb", "Chicken", "Turkey", "Mushrooms"],
  };

  const key = Object.keys(substitutes).find((k) => ingredientName.toLowerCase().includes(k));
  if (key) {
    return substitutes[key].map((s) => ({ name: s, reason: `Common substitute for ${ingredientName}` }));
  }

  return [
    { name: `${ingredientName} (similar variety)`, reason: "Try a different variety of the same ingredient." },
    { name: `Dried ${ingredientName}`, reason: "Dried versions can often replace fresh ones." },
    { name: `${ingredientName} paste/puree`, reason: "Concentrated forms work well in most recipes." },
  ];
};
