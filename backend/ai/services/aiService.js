const Meal = require("../../models/Meal");
const Product = require("../../models/Product");
const AiConversation = require("../models/AiConversation");

exports.processChat = async (userId, message, context) => {
  const meals = await Meal.find().populate("categoryId").lean();
  const products = await Product.find({ isAvailable: true }).lean();

  let conversation = await AiConversation.findOne({ userId, context, "messages.role": "user" }).sort({ updatedAt: -1 });
  if (!conversation) {
    conversation = new AiConversation({ userId, messages: [], context });
  }

  conversation.messages.push({ role: "user", content: message, timestamp: new Date() });

  const prompt = buildPrompt(message, context, meals);
  const aiResponse = await callLLM(prompt, message, meals, products);

  conversation.messages.push({ role: "assistant", content: aiResponse.text, timestamp: new Date() });
  if (conversation.messages.length > 50) {
    conversation.messages = conversation.messages.slice(-50);
  }
  await conversation.save();

  return {
    reply: aiResponse.text,
    conversationId: conversation._id,
    suggestedActions: aiResponse.suggestedActions || [],
    productId: aiResponse.productId || null,
    productName: aiResponse.productName || null,
    productPrice: aiResponse.productPrice || null,
    productImage: aiResponse.productImage || null,
  };
};

exports.getConversation = async (userId, conversationId) => {
  return AiConversation.findOne({ _id: conversationId, userId });
};

exports.getConversations = async (userId) => {
  return AiConversation.find({ userId }).sort({ updatedAt: -1 }).limit(20).select("context updatedAt messages");
};

exports.deleteConversation = async (userId, conversationId) => {
  return AiConversation.findOneAndDelete({ _id: conversationId, userId });
};

function buildPrompt(message, context, meals) {
  const mealList = meals.map((m) => `- ${m.name} (${m.description || "No description"}): ${m.preparationTime}min, ${m.servings} servings, ${m.price || "N/A"} FCFA, ID:${m._id}`).join("\n");

  let systemPrompt = "You are a helpful cooking and grocery assistant for My Spicemarket. ";
  systemPrompt += "Answer based on the available meals. Be concise and practical. ";
  systemPrompt += "When recommending a specific meal, include its exact ID in format [PRODUCT:id] on a new line.\n\n";

  switch (context) {
    case "cooking":
      systemPrompt += `Available meals:\n${mealList}\n\nSuggest meals matching the user's request. Explain why. Mention key ingredients. Include [PRODUCT:id] for your top recommendation.`;
      break;
    case "nutrition":
      systemPrompt += `Available meals:\n${mealList}\n\nAnswer nutrition questions about these meals. Provide estimates when exact data is unavailable.`;
      break;
    case "budget":
      systemPrompt += "The user wants meal suggestions within a budget. Consider the meal prices and suggest combinations.\n";
      systemPrompt += `Available meals:\n${mealList}\n\nInclude [PRODUCT:id] for your top recommendation.`;
      break;
    case "shopping":
      systemPrompt += "Help the user find ingredients and products. Answer questions about availability and ordering.\n";
      systemPrompt += `Available meals:\n${mealList}\n\nInclude [PRODUCT:id] for your top recommendation.`;
      break;
    default:
      systemPrompt += `Available meals:\n${mealList}\n\nAnswer the user's question helpfully. Include [PRODUCT:id] for your top recommendation when applicable.`;
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
    let rawText;
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
      rawText = data?.candidates?.[0]?.content?.parts?.[0]?.text;
    } else {
      const response = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
        body: JSON.stringify({
          model: "gpt-4o-mini",
          messages: [{ role: "system", content: "You are a cooking assistant for My Spicemarket. When recommending a specific meal, include its exact ID in format [PRODUCT:id] on a new line." }, { role: "user", content: prompt }],
          max_tokens: 500,
        }),
      });
      const data = await response.json();
      rawText = data?.choices?.[0]?.message?.content;
    }

    if (!rawText) return getFallbackResponse(userMessage, meals, products);

    const result = parseAiResponse(rawText, meals, products);
    return result;
  } catch (err) {
    console.error("LLM error:", err.message);
    return getFallbackResponse(userMessage, meals, products);
  }
}

function parseAiResponse(text, meals, products) {
  const productMatch = text.match(/\[PRODUCT:([a-f0-9]{24})\]/i);
  let productId = null;
  let productName = null;
  let productPrice = null;
  let productImage = null;

  if (productMatch) {
    const found = meals.find((m) => m._id.toString() === productMatch[1]) || products.find((p) => p._id.toString() === productMatch[1]);
    if (found) {
      productId = found._id.toString();
      productName = found.name;
      productPrice = found.price || null;
      productImage = found.image || found.imageUrl || null;
    }
  }

  const cleanText = text.replace(/\[PRODUCT:[a-f0-9]{24}\]/gi, '').trim();

  const suggestedActions = [];
  if (productName) {
    suggestedActions.push('Add $productName to cart');
    suggestedActions.push('Tell me more');
  }
  if (suggestedActions.length < 3) {
    suggestedActions.push('Something else');
  }

  return { text: cleanText, suggestedActions, productId, productName, productPrice, productImage };
}

function getFallbackResponse(userMessage, meals, products) {
  const lower = userMessage.toLowerCase().trim();

  if (!lower || lower.length < 2) {
    return { text: "Hi! I'm your AI cooking assistant. Ask me things like:\n- 'What can I cook with chicken and rice?'\n- 'Suggest a healthy breakfast'\n- 'What's under 3,000 FCFA?'\n- 'Recommend a meal for 4 people'", suggestedActions: ['Suggest a meal', 'Budget options', 'Healthy food'] };
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
      const top = affordable[0];
      const rest = affordable.slice(1, 5).map((p) => `- **${p.name}** (${p.price.toLocaleString()} FCFA) [PRODUCT:${p._id}]`).join("\n");
      return {
        text: `Best budget pick: **${top.name}** at ${top.price.toLocaleString()} FCFA [PRODUCT:${top._id}]\n\nOther affordable options:\n${rest}\n\nWould you like to order any of these?`,
        suggestedActions: [`Add ${top.name} to cart`, 'Show more options', 'Something cheaper'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }

    const cheapest = products.length > 0 ? products.reduce((a, b) => (a.price < b.price ? a : b)) : null;
    if (cheapest) {
      return {
        text: `There are no meals under ${maxBudget.toLocaleString()} FCFA. Our cheapest option is **${cheapest.name}** at ${cheapest.price.toLocaleString()} FCFA [PRODUCT:${cheapest._id}]. Would you like to go with that?`,
        suggestedActions: [`Add ${cheapest.name} to cart`, 'Show all meals'],
        productId: cheapest._id.toString(),
        productName: cheapest.name,
        productPrice: cheapest.price,
        productImage: cheapest.image || cheapest.imageUrl || null,
      };
    }
    return { text: "Sorry, no products are available right now.", suggestedActions: [] };
  }

  if (lower.includes("breakfast") || lower.includes("morning") || lower.includes("brunch")) {
    const breakfast = meals.filter((m) => {
      const n = m.name.toLowerCase();
      return n.includes("pancake") || n.includes("omelette") || n.includes("smoothie") || n.includes("egg") || n.includes("bread") || n.includes("cereal");
    });
    if (breakfast.length > 0) {
      const top = breakfast[0];
      const rest = breakfast.slice(1, 4).map((m) => `- **${m.name}** — ${m.description || "Quick breakfast"} (${m.preparationTime}min) [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Great for breakfast! Try **${top.name}** [PRODUCT:${top._id}]\n\n${rest}\n\nWould you like to know more or place an order?`,
        suggestedActions: [`Add ${top.name} to cart`, 'Show healthy options', 'Quick recipes'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
    return { text: "For breakfast, I recommend **Pancakes**, **Omelette**, or a **Fruit Smoothie Bowl**. All are quick and delicious! Would you like me to add any to your cart?", suggestedActions: ['Show breakfast menu', 'Healthy options'] };
  }

  if (lower.includes("spicy") || lower.includes("hot") || lower.includes("pepper") || lower.includes("chilli") || lower.includes("chili")) {
    const spicy = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "")).toLowerCase();
      return text.includes("spicy") || text.includes("pepper") || text.includes("chilli") || text.includes("chili") || text.includes("hot");
    });
    if (spicy.length > 0) {
      const top = spicy[0];
      const rest = spicy.slice(1, 4).map((m) => `- **${m.name}** (${m.price ? m.price.toLocaleString() + " FCFA" : "available"}) [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `For something spicy, try **${top.name}** [PRODUCT:${top._id}]\n\n${rest}\n\nThese pack some heat! Would you like to order?`,
        suggestedActions: [`Add ${top.name} to cart`, 'More spicy options', 'Milder alternatives'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
    return { text: "For something spicy, try **Jollof Rice**, **Pepper Soup**, or **Spicy Chicken Wings**. These are customer favorites!", suggestedActions: ['Show all spicy meals', 'Milder options'] };
  }

  if (lower.includes("vegetarian") || lower.includes("vegan") || lower.includes("plant") || lower.includes("meatless") || lower.includes("no meat")) {
    const veggie = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "")).toLowerCase();
      return text.includes("vegetable") || text.includes("vegan") || text.includes("veggie") || text.includes("salad") || text.includes("fruit") || text.includes("plant");
    });
    if (veggie.length > 0) {
      const top = veggie[0];
      const rest = veggie.slice(1, 4).map((m) => `- **${m.name}** — ${m.description || "Plant-based option"} [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Plant-based pick: **${top.name}** [PRODUCT:${top._id}]\n\n${rest}\n\nWould you like more details?`,
        suggestedActions: [`Add ${top.name} to cart`, 'More vegan options', 'Nutrition info'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
    return { text: "Try our **Vegetable Stir Fry** or **Vegan Buddha Bowl**. Both are plant-based and packed with nutrients!", suggestedActions: ['Show all vegetarian', 'Nutrition info'] };
  }

  if (lower.includes("healthy") || lower.includes("low calorie") || lower.includes("diet") || lower.includes("nutritious") || lower.includes("light meal") || lower.includes("weight loss")) {
    const healthy = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return text.includes("grill") || text.includes("salad") || text.includes("steam") || text.includes("vegetable") || text.includes("quinoa") || text.includes("fruit") || text.includes("light");
    });
    if (healthy.length > 0) {
      const top = healthy[0];
      const rest = healthy.slice(1, 4).map((m) => `- **${m.name}** — ${m.description || "Healthy choice"} [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Healthy pick: **${top.name}** [PRODUCT:${top._id}]\n\n${rest}\n\nWould you like nutritional details?`,
        suggestedActions: [`Add ${top.name} to cart`, 'Nutrition info', 'More healthy options'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
    return { text: "For healthy options, try **Grilled Fish with Vegetables**, **Quinoa Salad**, or **Steamed Chicken**. These are low in calories and high in nutrients!", suggestedActions: ['Show healthy meals', 'Nutrition info'] };
  }

  if (lower.includes("dinner") || lower.includes("supper") || lower.includes("evening")) {
    const dinner = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return text.includes("rice") || text.includes("soup") || text.includes("curry") || text.includes("grill") || text.includes("stew") || text.includes("roast");
    });
    if (dinner.length > 1) {
      const top = dinner[0];
      const sample = dinner.slice(1, 4).map((m) => `**${m.name}** — ${m.description || "Hearty dinner"} (${m.preparationTime}min) [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `For dinner tonight, try **${top.name}** [PRODUCT:${top._id}]\n\n${sample}\n\nAll are filling and ready to order!`,
        suggestedActions: [`Add ${top.name} to cart`, 'Budget dinner options', 'Quick dinners'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
  }

  if (lower.includes("lunch") || lower.includes("midday") || lower.includes("afternoon")) {
    const lunch = meals.filter((m) => (m.preparationTime || 0) <= 30);
    if (lunch.length > 1) {
      const top = lunch[0];
      const sample = lunch.slice(1, 4).map((m) => `- **${m.name}** (${m.preparationTime}min prep) [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Quick lunch pick: **${top.name}** (${top.preparationTime}min) [PRODUCT:${top._id}]\n\n${sample}\n\nReady in 30 minutes or less!`,
        suggestedActions: [`Add ${top.name} to cart`, 'More quick meals'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
  }

  if (lower.includes("dessert") || lower.includes("sweet") || lower.includes("cake") || lower.includes("chocolate") || lower.includes("ice cream")) {
    const sweet = meals.filter((m) => {
      const text = (m.name + " " + (m.description || "")).toLowerCase();
      return text.includes("cake") || text.includes("sweet") || text.includes("dessert") || text.includes("chocolate") || text.includes("ice cream") || text.includes("pie") || text.includes("pudding");
    });
    if (sweet.length > 0) {
      const top = sweet[0];
      const listed = sweet.slice(1, 4).map((m) => `- **${m.name}** [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Sweet treat: **${top.name}** [PRODUCT:${top._id}]\n\n${listed}\n\nWould you like to order?`,
        suggestedActions: [`Add ${top.name} to cart`, 'More desserts'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
  }

  if (lower.includes("party") || lower.includes("group") || lower.includes("family") || lower.includes("gathering") || lower.includes("event") || lower.includes("celebration") || lower.includes("crowd")) {
    const party = meals.filter((m) => (m.servings || 1) >= 4).slice(0, 4);
    if (party.length > 0) {
      const top = party[0];
      const rest = party.slice(1).map((m) => `- **${m.name}** (${m.servings} servings, ${m.price ? m.price.toLocaleString() + " FCFA" : "available"}) [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Great for groups: **${top.name}** (${top.servings} servings) [PRODUCT:${top._id}]\n\n${rest}\n\nWould you like to place a bulk order?`,
        suggestedActions: [`Add ${top.name} to cart`, 'Show all group meals', 'Get a quote'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
  }

  if (lower.includes("quick") || lower.includes("fast") || lower.includes("easy") || lower.includes("simple")) {
    const quick = meals.filter((m) => (m.preparationTime || 60) <= 20).slice(0, 4);
    if (quick.length > 0) {
      const top = quick[0];
      const listed = quick.slice(1).map((m) => `- **${m.name}** (${m.preparationTime}min) [PRODUCT:${m._id}]`).join("\n");
      return {
        text: `Quick & easy: **${top.name}** (${top.preparationTime}min) [PRODUCT:${top._id}]\n\n${listed}\n\nReady in 20 minutes or less!`,
        suggestedActions: [`Add ${top.name} to cart`, 'More quick meals'],
        productId: top._id.toString(),
        productName: top.name,
        productPrice: top.price,
        productImage: top.image || top.imageUrl || null,
      };
    }
  }

  const matchedMeals = meals.filter((m) => {
    const fields = (m.name + " " + (m.description || "") + " " + (m.categoryId?.name || "") + " " + (m.ingredients || []).join(" ")).toLowerCase();
    const keywords = lower.split(/\s+/).filter((w) => w.length > 2);
    return keywords.some((kw) => fields.includes(kw));
  });

  if (matchedMeals.length > 0) {
    const top = matchedMeals[0];
    const rest = matchedMeals.slice(1, 4).map((m) => `- **${m.name}** — ${m.description || "Available now"} (${m.price ? m.price.toLocaleString() + " FCFA" : "check menu"}) [PRODUCT:${m._id}]`).join("\n");
    return {
      text: `I found: **${top.name}** [PRODUCT:${top._id}]\n\n${rest}\n\nWould you like more details or help ordering?`,
      suggestedActions: [`Add ${top.name} to cart`, 'Tell me more', 'Show similar meals'],
      productId: top._id.toString(),
      productName: top.name,
      productPrice: top.price,
      productImage: top.image || top.imageUrl || null,
    };
  }

  const categories = [...new Set(meals.map((m) => m.categoryId?.name).filter(Boolean))];
  if (categories.length > 0) {
    return {
      text: `I have meals in these categories: **${categories.join("**, **")}**. Try asking something like:\n- 'What's in the ${categories[0]} category?'\n- 'Suggest something under 5,000 FCFA'\n- 'Do you have any spicy meals?'`,
      suggestedActions: ['Suggest a meal', 'Budget options', 'Quick meals'],
    };
  }

  return {
    text: "Hi! I'm your AI assistant. I can help you find meals, plan budgets, check nutrition, and more. What would you like to know?",
    suggestedActions: ['Suggest a meal', 'Budget options', 'Healthy food'],
  };
}
