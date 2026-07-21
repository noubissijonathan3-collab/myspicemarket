exports.processCommand = async (transcript) => {
  const lower = transcript.toLowerCase();

  if (lower.includes("order") || lower.includes("buy") || lower.includes("purchase")) {
    const product = extractProduct(lower);
    return { intent: "order", product, response: product ? `I'll help you order ${product}. Shall I add it to your cart?` : "What would you like to order?" };
  }

  if (lower.includes("search") || lower.includes("find") || lower.includes("looking for")) {
    const query = extractQuery(lower);
    return { intent: "search", query, response: `Searching for "${query}"...` };
  }

  if (lower.includes("track") || lower.includes("where is my order") || lower.includes("delivery status")) {
    return { intent: "track", response: "Let me check your order status." };
  }

  if (lower.includes("add") && (lower.includes("cart") || lower.includes("basket"))) {
    const product = extractProduct(lower, true);
    return { intent: "add_to_cart", product, response: product ? `Added ${product} to your cart.` : "What would you like to add to your cart?" };
  }

  if (lower.includes("recipe") || lower.includes("cook") || lower.includes("suggest") || lower.includes("recommend")) {
    const ingredients = extractIngredients(lower);
    return { intent: "recipe", ingredients, response: ingredients.length > 0 ? `Looking for recipes with ${ingredients.join(", ")}...` : "What ingredients do you have?" };
  }

  if (lower.includes("help") || lower.includes("how") || lower.includes("what can you")) {
    return { intent: "help", response: "I can help you order meals, search for products, track deliveries, suggest recipes, and more! Try saying 'Search for rice' or 'Order Chicken Curry'." };
  }

  return { intent: "unknown", response: "I didn't quite catch that. Try saying 'Search for rice', 'Order Chicken Curry', or 'Help'." };
};

function extractProduct(text) {
  const knownProducts = ["rice", "chicken", "fish", "tomato", "onion", "garlic", "oil", "bread", "milk", "eggs", "butter", "vegetables", "fruits"];
  const found = knownProducts.find((p) => text.includes(p));
  if (found) return found.charAt(0).toUpperCase() + found.slice(1);
  return null;
}

function extractQuery(text) {
  const patterns = [/(?:search|find|looking for)\s+(.+)/i, /(?:show|display|get)\s+(.+)/i];
  for (const p of patterns) {
    const match = text.match(p);
    if (match) return match[1].trim();
  }
  return text.replace(/(search|find|looking for|show|display|get|please|for)/g, "").trim() || "all products";
}

function extractIngredients(text) {
  const known = ["chicken", "fish", "rice", "tomato", "onion", "garlic", "potato", "vegetables", "beans", "meat", "eggs", "milk", "cheese", "bread", "pasta", "shrimp", "beef", "pork", "lamb"];
  return known.filter((i) => text.includes(i));
}
