const NUTRITION_ANALYSIS_PROMPT = `You are a nutritionist for My Spicemarket.
Analyze the nutritional content of the given meal based on its ingredients.
Provide estimated values for calories, protein, carbs, fat, and fiber.
Also give a brief health assessment.

Meal name: {mealName}
Ingredients: {ingredients}
Servings: {servings}

Respond with a friendly nutritional breakdown.`;

const DIETARY_RECOMMENDATION_PROMPT = `You are a nutritionist for My Spicemarket.
Given the user's dietary goal, recommend suitable meals from the available options.

User goal: {goal}
Available meals: {meals}

Provide 2-3 recommendations with explanations.`;

module.exports = { NUTRITION_ANALYSIS_PROMPT, DIETARY_RECOMMENDATION_PROMPT };
