const Address = require('../models/Address');

exports.getAddresses = async (req, res) => {
  try {
    const addresses = await Address.find({ user: req.user.id, isActive: true }).sort({ isDefault: -1, createdAt: -1 });
    res.json(addresses);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getDefaultAddress = async (req, res) => {
  try {
    const address = await Address.findOne({ user: req.user.id, isDefault: true, isActive: true });
    res.json(address);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.createAddress = async (req, res) => {
  try {
    if (req.body.isDefault) {
      await Address.updateMany({ user: req.user.id }, { isDefault: false });
    }
    const address = await Address.create({ ...req.body, user: req.user.id });
    res.status(201).json(address);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateAddress = async (req, res) => {
  try {
    if (req.body.isDefault) {
      await Address.updateMany({ user: req.user.id, _id: { $ne: req.params.id } }, { isDefault: false });
    }
    const address = await Address.findByIdAndUpdate(req.params.id, req.body, { returnDocument: 'after' });
    res.json(address);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteAddress = async (req, res) => {
  try {
    await Address.findByIdAndUpdate(req.params.id, { isActive: false });
    res.json({ message: 'Address deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
