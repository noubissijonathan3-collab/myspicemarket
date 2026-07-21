const Meal = require("../../models/Meal");
const NutritionLog = require("../models/NutritionLog");

const nutritionDB = {
  "Chicken Curry": { calories: 450, protein: "28g", carbs: "35g", fat: "18g", fiber: "4g" },
  "Jollof Rice": { calories: 380, protein: "10g", carbs: "55g", fat: "12g", fiber: "3g" },
  "Grilled Fish": { calories: 320, protein: "35g", carbs: "5g", fat: "15g", fiber: "1g" },
  "Fried Rice": { calories: 420, protein: "12g", carbs: "50g", fat: "16g", fiber: "2g" },
  "Vegetable Soup": { calories: 180, protein: "6g", carbs: "20g", fat: "8g", fiber: "8g" },
  "Pancakes": { calories: 350, protein: "8g", carbs: "45g", fat: "14g", fiber: "2g" },
  "Omelette": { calories: 280, protein: "20g", carbs: "3g", fat: "20g", fiber: "1g" },
  "Fruit Smoothie": { calories: 200, protein: "5g", carbs: "35g", fat: "5g", fiber: "5g" },
  "Pepper Soup": { calories: 250, protein: "22g", carbs: "8g", fat: "12g", fiber: "2g" },
  "Spicy Chicken Wings": { calories: 400, protein: "30g", carbs: "10g", fat: "25g", fiber: "1g" },
};

exports.analyzeMeal = async (mealId, query, userId) => {
  let meal = null;
  if (mealId) {
    meal = await Meal.findById(mealId).lean();
  }

  if (meal && nutritionDB[meal.name]) {
    const info = nutritionDB[meal.name];
    const log = await NutritionLog.create({ userId, mealId, query, analysis: info });
    return { meal: meal.name, ...info, summary: `${meal.name} contains approximately ${info.calories} calories per serving. It has ${info.protein} of protein, ${info.carbs} of carbohydrates, and ${info.fat} of fat.` };
  }

  if (meal) {
    const estimated = estimateNutrition(meal);
    await NutritionLog.create({ userId, mealId, query, analysis: estimated });
    return { meal: meal.name, ...estimated, note: "Values are estimated based on typical ingredients." };
  }

  if (query && query.trim()) {
    const meals = await Meal.find().lean();
    return analyzeQuery(query, meals, userId);
  }

  return { suggestion: "I can check the nutritional information for any meal. Just tell me which meal you're interested in!" };
};

exports.getHistory = async (userId) => {
  return NutritionLog.find({ userId }).sort({ createdAt: -1 }).limit(20).lean();
};

function analyzeQuery(query, allMeals, userId) {
  const lower = query.toLowerCase();

  const matchedMeal = allMeals.find((m) => lower.includes(m.name.toLowerCase()));
  if (matchedMeal) {
    const info = nutritionDB[matchedMeal.name] || estimateNutrition(matchedMeal);
    const summary = nutritionDB[matchedMeal.name]
      ? `${matchedMeal.name} contains approximately ${info.calories} calories per serving.`
      : `${matchedMeal.name} has an estimated ${info.calories} calories per serving (based on typical ingredients).`;
    return { meal: matchedMeal.name, ...info, summary };
  }

  if (lower.includes("low calorie") || lower.includes("weight loss") || lower.includes("diet")) {
    const lowCal = allMeals
      .filter((m) => {
        const info = nutritionDB[m.name] || estimateNutrition(m);
        return info.calories < 300;
      })
      .slice(0, 3);
    if (lowCal.length > 0) {
      const listed = lowCal.map((m) => `**${m.name}** (${(nutritionDB[m.name] || estimateNutrition(m)).calories} cal)`).join(", ");
      return { suggestion: `For weight loss, try ${listed}. These are low in calories and high in nutrients!` };
    }
    return { suggestion: "For weight loss, try **Vegetable Soup** (180 cal), **Grilled Fish** (320 cal), or **Fruit Smoothie Bowl** (200 cal)." };
  }

  if (lower.includes("protein") || lower.includes("muscle")) {
    const highProtein = allMeals
      .filter((m) => {
        const info = nutritionDB[m.name] || estimateNutrition(m);
        return parseInt(info.protein) > 15;
      })
      .slice(0, 3);
    if (highProtein.length > 0) {
      const listed = highProtein.map((m) => `**${m.name}** (${(nutritionDB[m.name] || estimateNutrition(m)).protein} protein)`).join(", ");
      return { suggestion: `High-protein options include ${listed}. These are great for muscle building!` };
    }
    return { suggestion: "High-protein options include **Grilled Fish** (35g protein), **Spicy Chicken Wings** (30g), and **Chicken Curry** (28g)." };
  }

  if (lower.includes("healthy") || lower.includes("nutritious")) {
    return { suggestion: "Our healthiest options are **Vegetable Soup** (packed with fiber and vitamins), **Grilled Fish with Vegetables**, and **Quinoa Salad**. Would you like nutritional details for any of these?" };
  }

  const categoryHits = allMeals.filter((m) => {
    const text = (m.name + " " + (m.description || "")).toLowerCase();
    const keywords = lower.split(/\s+/).filter((w) => w.length > 3);
    return keywords.some((kw) => text.includes(kw));
  });

  if (categoryHits.length > 0) {
    const info = nutritionDB[categoryHits[0].name] || estimateNutrition(categoryHits[0]);
    return { meal: categoryHits[0].name, ...info, summary: `${categoryHits[0].name} has approximately ${info.calories} calories per serving.` };
  }

  return { suggestion: "I can check the nutritional information for any meal. Just tell me which meal you're interested in!" };
}

function estimateNutrition(meal) {
  const baseCalories = Math.round((meal.servings || 1) * 200);
  return {
    calories: baseCalories,
    protein: `${Math.round((meal.servings || 1) * 8)}g`,
    carbs: `${Math.round((meal.servings || 1) * 25)}g`,
    fat: `${Math.round((meal.servings || 1) * 10)}g`,
    fiber: `${Math.round((meal.servings || 1) * 2)}g`,
  };
}
