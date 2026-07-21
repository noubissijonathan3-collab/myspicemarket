const voiceService = require("../services/voiceService");

exports.processVoice = async (req, res) => {
  try {
    const { transcript } = req.body;
    if (!transcript) return res.status(400).json({ message: "Transcript is required" });
    const result = await voiceService.processCommand(transcript);
    res.json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
