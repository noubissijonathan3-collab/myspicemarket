const express = require("express");
const router = express.Router();

const supportedLanguages = [
  { code: "en", name: "English", nativeName: "English" },
  { code: "fr", name: "French", nativeName: "Fran\u00e7ais" },
  { code: "es", name: "Spanish", nativeName: "Espa\u00f1ol" },
  { code: "de", name: "German", nativeName: "Deutsch" },
  { code: "pt", name: "Portuguese", nativeName: "Portugu\u00eas" },
  { code: "it", name: "Italian", nativeName: "Italiano" },
  { code: "ar", name: "Arabic", nativeName: "\u0627\u0644\u0639\u0631\u0628\u064a\u0629" },
  { code: "zh", name: "Chinese", nativeName: "\u4e2d\u6587" },
  { code: "ja", name: "Japanese", nativeName: "\u65e5\u672c\u8a9e" },
  { code: "ko", name: "Korean", nativeName: "\ud55c\uad6d\uc5b4" },
  { code: "hi", name: "Hindi", nativeName: "\u0939\u093f\u0928\u094d\u0926\u0940" },
  { code: "ru", name: "Russian", nativeName: "\u0420\u0443\u0441\u0441\u043a\u0438\u0439" },
  { code: "tr", name: "Turkish", nativeName: "T\u00fcrk\u00e7e" },
  { code: "nl", name: "Dutch", nativeName: "Nederlands" },
  { code: "pl", name: "Polish", nativeName: "Polski" },
  { code: "sv", name: "Swedish", nativeName: "Svenska" },
  { code: "el", name: "Greek", nativeName: "\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac" },
  { code: "th", name: "Thai", nativeName: "\u0e44\u0e17\u0e22" },
  { code: "vi", name: "Vietnamese", nativeName: "Ti\u1ebfng Vi\u1ec7t" },
  { code: "he", name: "Hebrew", nativeName: "\u05e2\u05d1\u05e8\u05d9\u05ea" },
];

router.get("/", (req, res) => {
  res.json(supportedLanguages);
});

router.get("/default", (req, res) => {
  res.json({ code: "en", name: "English", nativeName: "English" });
});

module.exports = router;
