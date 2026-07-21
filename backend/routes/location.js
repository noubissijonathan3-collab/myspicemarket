const express = require('express');
const router = express.Router();
const { reverseGeocode, searchLocation, getDeliveryEstimate } = require('../controllers/locationController');

router.get('/reverse-geocode', reverseGeocode);
router.get('/search', searchLocation);
router.get('/delivery-estimate', getDeliveryEstimate);

module.exports = router;
