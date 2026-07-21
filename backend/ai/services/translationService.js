const Translation = require("../models/Translation");

exports.translate = async (text, targetLanguage, sourceLanguage, contextType) => {
  if (!text || !targetLanguage) return text;
  if (sourceLanguage === targetLanguage) return text;

  const cached = await Translation.findOne({ sourceText: text, targetLanguage, sourceLanguage: sourceLanguage || "en" });
  if (cached) {
    await Translation.findByIdAndUpdate(cached._id, { $inc: { usageCount: 1 } });
    return cached.translatedText;
  }

  const translated = await callTranslationLLM(text, targetLanguage, sourceLanguage, contextType);

  try {
    await Translation.create({ sourceText: text, sourceLanguage: sourceLanguage || "en", targetLanguage, translatedText: translated, contextType: contextType || "meal" });
  } catch (_) {}

  return translated;
};

exports.translateBatch = async (items, targetLanguage, sourceLanguage) => {
  return Promise.all(items.map((item) => this.translate(item, targetLanguage, sourceLanguage)));
};

exports.getSupportedLanguages = () => {
  return [
    { code: "en", name: "English", native: "English" },
    { code: "fr", name: "French", native: "Français" },
    { code: "es", name: "Spanish", native: "Español" },
    { code: "de", name: "German", native: "Deutsch" },
    { code: "it", name: "Italian", native: "Italiano" },
    { code: "pt", name: "Portuguese", native: "Português" },
    { code: "ar", name: "Arabic", native: "العربية" },
    { code: "zh", name: "Chinese", native: "中文" },
    { code: "ja", name: "Japanese", native: "日本語" },
    { code: "ko", name: "Korean", native: "한국어" },
    { code: "hi", name: "Hindi", native: "हिन्दी" },
    { code: "ru", name: "Russian", native: "Русский" },
    { code: "nl", name: "Dutch", native: "Nederlands" },
    { code: "tr", name: "Turkish", native: "Türkçe" },
    { code: "pl", name: "Polish", native: "Polski" },
  ];
};

async function callTranslationLLM(text, targetLanguage, sourceLanguage, contextType) {
  const apiKey = process.env.OPENAI_API_KEY || process.env.GEMINI_API_KEY;

  if (!apiKey) {
    return text;
  }

  const prompt = `Translate the following ${contextType || "text"} from ${sourceLanguage || "English"} to ${targetLanguage}. Only return the translation, nothing else.\n\nText: ${text}`;

  try {
    const response = await fetch("https://api.openai.com/v1/chat/completions", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${apiKey}` },
      body: JSON.stringify({ model: "gpt-4o-mini", messages: [{ role: "user", content: prompt }], max_tokens: 300 }),
    });
    const data = await response.json();
    return data?.choices?.[0]?.message?.content?.trim() || text;
  } catch (err) {
    console.error("Translation error:", err.message);
    return text;
  }
}
