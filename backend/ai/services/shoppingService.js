const Product = require("../../models/Product");
const Meal = require("../../models/Meal");
const Order = require("../../models/Order");
const BudgetPlan = require("../models/BudgetPlan");
const WeeklyMealPlan = require("../models/WeeklyMealPlan");

exports.planBudget = async (userId, budget) => {
  const meals = await Meal.find().lean();
  const products = await Product.find({ type: "meal", isAvailable: true }).lean();

  const affordable = products.filter((p) => p.price <= budget);
  affordable.sort((a, b) => a.price - b.price);

  let totalCost = 0;
  const recommendations = [];

  for (const item of affordable) {
    if (totalCost + item.price <= budget && recommendations.length < 8) {
      recommendations.push({
        mealId: item._id,
        name: item.name,
        price: item.price,
        reason: `Affordable option at ${item.price.toLocaleString()} FCFA.`,
      });
      totalCost += item.price;
    }
  }

  if (recommendations.length === 0 && products.length > 0) {
    const cheapest = products.reduce((a, b) => (a.price < b.price ? a : b));
    recommendations.push({
      mealId: cheapest._id,
      name: cheapest.name,
      price: cheapest.price,
      reason: `The most budget-friendly option at ${cheapest.price.toLocaleString()} FCFA.`,
    });
    totalCost = cheapest.price;
  }

  const plan = await BudgetPlan.create({ userId, budget, recommendations, totalCost, savings: budget - totalCost });
  return plan;
};

exports.generateWeeklyPlan = async (userId, familySize, budget, preferences) => {
  const meals = await Meal.find().lean();
  const products = await Product.find({ type: "meal", isAvailable: true }).lean();
  const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  let candidates = meals;
  if (budget && budget > 0) {
    const priceMap = {};
    for (const p of products) {
      for (const m of meals) {
        if (p.name.toLowerCase() === m.name.toLowerCase()) {
          priceMap[m._id] = p.price;
        }
      }
    }
    candidates = meals.filter((m) => !priceMap[m._id] || priceMap[m._id] <= budget / 2);
  }

  const prefList = (preferences || []).map((p) => p.toLowerCase());
  if (prefList.length > 0) {
    const filtered = candidates.filter((m) => {
      const text = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "")).toLowerCase();
      return prefList.some((p) => text.includes(p));
    });
    if (filtered.length >= 2) candidates = filtered;
  }

  const shuffled = [...candidates].sort(() => Math.random() - 0.5);
  const usedNames = new Set();
  const dayPlans = days.map((day, i) => {
    const dayMeals = [];
    for (let j = 0; j < 2 && i * 2 + j < shuffled.length; j++) {
      const meal = shuffled[i * 2 + j];
      if (meal && !usedNames.has(meal.name)) {
        usedNames.add(meal.name);
        dayMeals.push({
          mealId: meal._id,
          name: meal.name,
          servings: Math.max(1, familySize),
        });
      }
    }
    if (dayMeals.length === 0) {
      const fallback = shuffled[0];
      dayMeals.push({
        mealId: fallback._id,
        name: fallback.name,
        servings: Math.max(1, familySize),
      });
    }
    return { day, meals: dayMeals };
  });

  const shoppingList = [];
  const seen = new Set();
  for (const day of dayPlans) {
    for (const m of day.meals) {
      if (!seen.has(m.name)) {
        seen.add(m.name);
        const product = products.find((p) => p.name.toLowerCase() === m.name.toLowerCase());
        shoppingList.push({
          name: `Ingredients for ${m.name}`,
          quantity: `${m.servings}`,
          unit: "servings",
          estimatedCost: product ? product.price * m.servings : 0,
        });
      }
    }
  }

  const plan = await WeeklyMealPlan.create({ userId, familySize, budget, preferences, days: dayPlans, shoppingList });
  return plan;
};

exports.suggestAddOns = async (orderId) => {
  const order = await Order.findById(orderId).populate("items.mealId").lean();
  if (!order) return [];

  const orderedNames = new Set(order.items?.map((i) => i.mealId?.name?.toLowerCase()).filter(Boolean) || []);
  const suggestions = [];

  const pairings = {
    rice: ["Tomato sauce", "Seasoning", "Cooking oil", " Vegetables"],
    chicken: ["Seasoning", "Cooking oil", "Onions", "Garlic"],
    fish: ["Lemon", "Seasoning", "Cooking oil", "Pepper"],
    spaghetti: ["Tomato sauce", "Seasoning", "Cheese", "Cooking oil"],
    salad: ["Salad dressing", "Olive oil", "Croutons"],
    soup: ["Bread", "Seasoning", "Pepper"],
  };

  for (const [key, addons] of Object.entries(pairings)) {
    if (Array.from(orderedNames).some((n) => n.includes(key))) {
      for (const addon of addons) {
        if (!Array.from(orderedNames).some((n) => n.includes(addon.toLowerCase()))) {
          suggestions.push({ name: addon, reason: `Pairs well with your ${key} order.` });
        }
      }
    }
  }

  return suggestions.slice(0, 4);
};
