const axios = require('axios');
const deliveryCalculator = require('../utils/deliveryCalculator');

exports.reverseGeocode = async (req, res) => {
  try {
    const { lat, lng } = req.query;
    if (!lat || !lng) return res.status(400).json({ message: 'lat and lng required' });
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    if (apiKey) {
      const response = await axios.get(
        `https://maps.googleapis.com/maps/api/geocode/json?latlng=${lat},${lng}&key=${apiKey}`
      );
      return res.json(response.data);
    }
    const response = await axios.get(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&addressdetails=1`,
      { headers: { 'User-Agent': 'MySpiceMarket/1.0' } }
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.searchLocation = async (req, res) => {
  try {
    const { q } = req.query;
    if (!q) return res.status(400).json({ message: 'Query required' });
    const apiKey = process.env.GOOGLE_MAPS_API_KEY;
    if (apiKey) {
      const response = await axios.get(
        `https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${encodeURIComponent(q)}&key=${apiKey}&components=country:cm`
      );
      return res.json(response.data);
    }
    const response = await axios.get(
      `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(q)}&countrycodes=cm&limit=5`,
      { headers: { 'User-Agent': 'MySpiceMarket/1.0' } }
    );
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getDeliveryEstimate = async (req, res) => {
  try {
    const { lat, lng, coverageRadius } = req.query;
    if (!lat || !lng) return res.status(400).json({ message: 'lat and lng required' });
    const estimate = deliveryCalculator.getFullEstimate(
      parseFloat(lat),
      parseFloat(lng),
      coverageRadius ? parseFloat(coverageRadius) : undefined,
    );
    res.json(estimate);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
