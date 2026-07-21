const translationService = require("../services/translationService");

exports.translate = async (req, res) => {
  try {
    const { text, targetLanguage, sourceLanguage, contextType } = req.body;
    if (!text || !targetLanguage) return res.status(400).json({ message: "Text and targetLanguage are required" });
    const result = await translationService.translate(text, targetLanguage, sourceLanguage, contextType);
    res.json({ translatedText: result });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.translateBatch = async (req, res) => {
  try {
    const { items, targetLanguage, sourceLanguage } = req.body;
    if (!items || !targetLanguage) return res.status(400).json({ message: "Items and targetLanguage are required" });
    const results = await translationService.translateBatch(items, targetLanguage, sourceLanguage);
    res.json({ translations: results });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getLanguages = async (req, res) => {
  res.json(translationService.getSupportedLanguages());
};
