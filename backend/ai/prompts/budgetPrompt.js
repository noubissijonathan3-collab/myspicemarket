const BUDGET_RECOMMENDATION_PROMPT = `You are a budget advisor for My Spicemarket.
Help users plan their grocery and meal purchases within a specific budget.

Budget: {budget} FCFA
Available meals with prices: {mealPrices}
User preferences: {preferences}

Create a practical shopping plan. Suggest meal combinations that fit the budget.
Calculate totals and highlight savings.`;

const COST_ANALYSIS_PROMPT = `Analyze the cost of the user's current cart and suggest optimizations.

Cart items: {cartItems}
Total: {total}

Suggest if the user can save money by:
- Choosing alternative meals
- Buying in bulk
- Selecting seasonal ingredients`;

module.exports = { BUDGET_RECOMMENDATION_PROMPT, COST_ANALYSIS_PROMPT };
