const Meal = require("../../models/Meal");
const Product = require("../../models/Product");
const AiConversation = require("../models/AiConversation");

exports.processChat = async (userId, message, context) => {
  const meals = await Meal.find().populate("categoryId").lean();
  const products = await Product.find({ type: "meal", isAvailable: true }).lean();

  let conversation = await AiConversation.findOne({ userId, context, "messages.role": "user" }).sort({ updatedAt: -1 });
  if (!conversation) {
    conversation = new AiConversation({ userId, messages: [], context });
  }

  conversation.messages.push({ role: "user", content: message, timestamp: new Date() });

  const prompt = buildPrompt(message, context, meals);
  const aiResponse = await callLLM(prompt, message, meals, products);

  conversation.messages.push({ role: "assistant", content: aiResponse, timestamp: new Date() });
  if (conversation.messages.length > 50) {
    conversation.messages = conversation.messages.slice(-50);
  }
  await conversation.save();

  return { reply: aiResponse, conversationId: conversation._id };
};

exports.getConversation = async (userId, conversationId) => {
  return AiConversation.findOne({ _id: conversationId, userId });
};

exports.getConversations = async (userId) => {
  return AiConversation.find({ userId }).sort({ updatedAt: -1 }).limit(20).select("context updatedAt");
};

exports.deleteConversation = async (userId, conversationId) => {
  return AiConversation.findOneAndDelete({ _id: conversationId, userId });
};

function buildPrompt(message, context, meals) {
  const mealList = meals.map((m) => `- ${m.name} (${m.description || "No description"}): ${m.preparationTime}min, ${m.servings} servings`).join("\n");

  let systemPrompt = "You are a helpful cooking and grocery assistant for My Spicemarket. ";
  systemPrompt += "Answer based on the available meals. Be concise and practical.\n\n";

  switch (context) {
    case "cooking":
      systemPrompt += `Available meals:\n${mealList}\n\nSuggest meals matching the user's request. Explain why. Mention key ingredients. Ask if they want to order.`;
      break;
    case "nutrition":
      systemPrompt += `Available meals:\n${mealList}\n\nAnswer nutrition questions about these meals. Provide estimates when exact data is unavailable.`;
      break;
    case "budget":
      systemPrompt += "The user wants meal suggestions within a budget. Consider the meal prices and suggest combinations.\n";
      systemPrompt += `Available meals:\n${mealList}`;
      break;
    case "shopping":
      systemPrompt += "Help the user find ingredients and products. Answer questions about availability and ordering.";
      break;
    default:
      systemPrompt += `Available meals:\n${mealList}\n\nAnswer the user's question helpfully.`;
  }

  return `${systemPrompt}\n\nUser: ${message}`;
}

async function callLLM(prompt, userMessage, meals, products) {
  const apiKey = process.env.OPENAI_API_KEY || process.env.GEMINI_API_KEY;
  const model = process.env.AI_MODEL || "openai";

  if (!apiKey) {
    return getFallbackResponse(userMessage, meals, products);
  }

  try {
    if (model === "gemini") {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
        {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] }),
        }
      );
      const data = await response.json();
      return data?.candidates?.[0]?.content?.parts?.[0]?.text || getFallbackResponse(userMessage, meals, products);
    }

    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({ model: "gpt-4o-mini", messages: [{ role: "system", content: "You are a cooking assistant." }, { role: "user", content: prompt }], max_tokens: 500 }),
    });
    const data = await response.json();
    return data?.choices?.[0]?.message?.content || getFallbackResponse(userMessage, meals, products);
  } catch (err) {
    console.error("LLM error:", err.message);
    return getFallbackResponse(userMessage, meals, products);
  }
}

function getFallbackResponse(userMessage, meals, products) {
  const lower = userMessage.toLowerCase().trim();

  if (!lower || lower.length < 2) {
    return "Hi! I'm your AI cooking assistant. Ask me things like:\n- 'What can I cook with chicken and rice?'\n- 'Suggest a healthy breakfast'\n- 'What's under 3,000 FCFA?'\n- 'Recommend a meal for 4 people'";
  }

  const budgetMatch = lower.match(/(\d[\d,.\s]*)\s*(fcfa|cfa|\$|usd|eur|£)/i);
  if (budgetMatch || lower.includes("budget") || lower.includes("affordable") || lower.includes("cheap") || lower.includes("cheapest") || lower.includes("under")) {
    let maxBudget = Infinity;
    if (budgetMatch) {
      maxBudget = parseFloat(budgetMatch[1].replace(/[,.\s]/g, ""));
    } else {
      const numMatch = lower.match(/(\d+)/);
      if (numMatch) maxBudget = parseInt(numMatch[1], 10);
    }

    const affordable = products
      .filter((p) => p.price <= maxBudget)
      .sort((a, b) => a.price - b.price);

    if (affordable.length > 0) {
      const listed = affordable.slice(0, 5).map((p) => `**${p.name}** (${p.price.toLocaleString()} FCFA)`).join("\n- ");
      return `Here are meals within your budget:\n\n- ${listed}\n\nThese are the most affordable options. Would you like to order any of them?`;
    }

    const cheapest = products.length > 0 ? products.reduce((a, b) => (a.price < b.price ? a : b)) : null;
    if (cheapest) {
      return `There are no meals under ${maxBudget.toLocaleString()} FCFA. Our cheapest option is **${cheapest.name}** at ${cheapest.price.toLocaleString()} FCFA. Would you like to go with that?`;
    }
    return "Sorry, no products are available right now.";
  }

  if (lower.includes("breakfast") || lower.includes("morning") || lower.includes("brunch")) {
    const breakfast = meals.filter((m) => {
      const n = m.name.toLowerCase();
      return n.includes("pancake") || n.includes("omelette") || n.includes("smoothie") || n.includes("egg") || n.includes("bread") || n.includes("cereal");
    });
    if (breakfast.length > 0) {
      const listed = breakfast.map((m) => `**${m.name}** — ${m.description || "Quick breakfast"} (${m.preparationTime}min)`).join("\n- ");
      return `Great for breakfast! Try:\n\n- ${listed}\n\nWould you like to know the ingredients or place an order?`;
    }
    return "For breakfast, I recommend **Pancakes**, **Omelette**, or a **Fruit Smoothie Bowl**. All are quick and delicious! Would you like me to add any to your cart?";
  }

  if (lower.includes("spicy") || lower.includes("hot") || lower.includes("pepper") || lower.includes("chilli") || lower.includes("chili")) {
    const spicy = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "")).toLowerCase();
      return text.includes("spicy") || text.includes("pepper") || text.includes("chilli") || text.includes("chili") || text.includes("hot");
    });
    if (spicy.length > 0) {
      const listed = spicy.map((m) => `**${m.name}** (${m.price ? m.price.toLocaleString() + " FCFA" : "available"})`).join("\n- ");
      return "For something spicy, try:\n\n- " + listed + "\n\nThese pack some heat! Would you like to order any?";
    }
    return "For something spicy, try **Jollof Rice**, **Pepper Soup**, or **Spicy Chicken Wings**. These are customer favorites!";
  }

  if (lower.includes("vegetarian") || lower.includes("vegan") || lower.includes("plant") || lower.includes("meatless") || lower.includes("no meat")) {
    const veggie = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "")).toLowerCase();
      return text.includes("vegetable") || text.includes("vegan") || text.includes("veggie") || text.includes("salad") || text.includes("fruit") || text.includes("plant");
    });
    if (veggie.length > 0) {
      const listed = veggie.map((m) => `**${m.name}** — ${m.description || "Plant-based option"}`).join("\n- ");
      return "Plant-based options:\n\n- " + listed + "\n\nThese are all vegetarian-friendly. Would you like more details?";
    }
    return "Try our **Vegetable Stir Fry** or **Vegan Buddha Bowl**. Both are plant-based and packed with nutrients!";
  }

  if (lower.includes("healthy") || lower.includes("low calorie") || lower.includes("diet") || lower.includes("nutritious") || lower.includes("light meal") || lower.includes("weight loss")) {
    const healthy = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return text.includes("grill") || text.includes("salad") || text.includes("steam") || text.includes("vegetable") || text.includes("quinoa") || text.includes("fruit") || text.includes("light");
    });
    if (healthy.length > 0) {
      const listed = healthy.map((m) => `**${m.name}** — ${m.description || "Healthy choice"}`).join("\n- ");
      return "Healthy options:\n\n- " + listed + "\n\nThese are nutritious and light. Would you like nutritional details?";
    }
    return "For healthy options, try **Grilled Fish with Vegetables**, **Quinoa Salad**, or **Steamed Chicken**. These are low in calories and high in nutrients!";
  }

  if (lower.includes("dinner") || lower.includes("supper") || lower.includes("evening")) {
    const dinner = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return text.includes("rice") || text.includes("soup") || text.includes("curry") || text.includes("grill") || text.includes("stew") || text.includes("roast");
    });
    if (dinner.length > 1) {
      const sample = dinner.slice(0, 4).map((m) => `**${m.name}** — ${m.description || "Hearty dinner"} (${m.preparationTime}min)`).join("\n- ");
      return "For dinner tonight, consider:\n\n- " + sample + "\n\nAll are filling and ready to order!";
    }
  }

  if (lower.includes("lunch") || lower.includes("midday") || lower.includes("afternoon")) {
    const lunch = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return (m.preparationTime || 0) <= 30;
    });
    if (lunch.length > 1) {
      const sample = lunch.slice(0, 4).map((m) => `**${m.name}** (${m.preparationTime}min prep)`).join("\n- ");
      return "Quick lunch ideas:\n\n- " + sample + "\n\nThese are ready in 30 minutes or less!";
    }
  }

  if (lower.includes("dessert") || lower.includes("sweet") || lower.includes("cake") || lower.includes("chocolate") || lower.includes("ice cream")) {
    const sweet = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return text.includes("cake") || text.includes("sweet") || text.includes("dessert") || text.includes("chocolate") || text.includes("ice cream") || text.includes("pie") || text.includes("pudding");
    });
    if (sweet.length > 0) {
      const listed = sweet.map((m) => `**${m.name}**`).join("\n- ");
      return "For something sweet:\n\n- " + listed + "\n\nThese are perfect for dessert! Would you like to order?";
    }
  }

  if (lower.includes("party") || lower.includes("group") || lower.includes("family") || lower.includes("gathering") || lower.includes("event") || lower.includes("celebration") || lower.includes("crowd")) {
    const party = meals.filter((m) => (m.servings || 1) >= 4).slice(0, 4);
    if (party.length > 0) {
      const listed = party.map((m) => `**${m.name}** (${m.servings} servings, ${m.price ? m.price.toLocaleString() + " FCFA" : "available"})`).join("\n- ");
      return "Great for groups:\n\n- " + listed + "\n\nThese serve 4+ people. Would you like to place a bulk order?";
    }
  }

  if (lower.includes("quick") || lower.includes("fast") || lower.includes("easy") || lower.includes("simple")) {
    const quick = meals.filter((m) => (m.preparationTime || 60) <= 20).slice(0, 4);
    if (quick.length > 0) {
      const listed = quick.map((m) => `**${m.name}** (${m.preparationTime}min)`).join("\n- ");
      return "Quick & easy meals:\n\n- " + listed + "\n\nThese are ready in 20 minutes or less!";
    }
  }

  const matchedMeals = meals.filter((m) => {
    const fields = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "") + " " + (m.ingredients || []).join(" ")).toLowerCase();
    const keywords = lower.split(/\s+/).filter((w) => w.length > 2);
    return keywords.some((kw) => fields.includes(kw));
  });

  if (matchedMeals.length > 0) {
    const top = matchedMeals.slice(0, 4);
    const listed = top.map((m) => `**${m.name}** — ${m.description || "Available now"} (${m.price ? m.price.toLocaleString() + " FCFA" : "check menu for price"})`).join("\n- ");
    return "I found these matching meals:\n\n- " + listed + "\n\nWould you like more details or help ordering?";
  }

  const categories = [...new Set(meals.map((m) => m.categoryId?.name).filter(Boolean))];
  if (categories.length > 0) {
    return `I have meals in these categories: **${categories.join("**, **")}**. Try asking something like:\n- 'What's in the ${categories[0]} category?'\n- 'Suggest something under 5,000 FCFA'\n- 'Do you have any spicy meals?'`;
  }

  return "Hi! I'm your AI assistant. I can help you find meals, plan budgets, check nutrition, and more. What would you like to know?";
}
