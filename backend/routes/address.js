const express = require('express');
const router = express.Router();
const { getAddresses, getDefaultAddress, createAddress, updateAddress, deleteAddress } = require('../controllers/addressController');
const { protect } = require('../middleware/auth');

router.use(protect);
router.get('/', getAddresses);
router.get('/default', getDefaultAddress);
router.post('/', createAddress);
router.put('/:id', updateAddress);
router.delete('/:id', deleteAddress);

module.exports = router;
