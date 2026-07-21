const Cart = require('../models/Cart');
const Product = require('../models/Product');
const Foodstuff = require('../models/Foodstuff');

exports.getCart = async (req, res) => {
  try {
    let cart = await Cart.findOne({ user: req.user.id });
    if (!cart) {
      cart = await Cart.create({ user: req.user.id, items: [], subtotal: 0, deliveryFee: 0, total: 0 });
    }
    res.json(cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.addToCart = async (req, res) => {
  try {
    const { productId, quantity = 1 } = req.body;
    let product = await Product.findById(productId);
    let type = 'meal';
    if (!product) {
      product = await Foodstuff.findById(productId);
      type = 'grocery';
    }
    if (!product) return res.status(404).json({ message: 'Product not found' });
    let cart = await Cart.findOne({ user: req.user.id });
    if (!cart) {
      cart = await Cart.create({ user: req.user.id, items: [], subtotal: 0, deliveryFee: 0, total: 0 });
    }
    const existingIndex = cart.items.findIndex(i => i.product.toString() === productId);
    if (existingIndex >= 0) {
      cart.items[existingIndex].quantity += quantity;
    } else {
      cart.items.push({
        product: productId,
        quantity,
        price: product.price,
        name: product.name,
        image: product.image,
        type,
      });
    }
    cart.subtotal = cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
    cart.deliveryFee = cart.subtotal >= 5000 ? 0 : 1500;
    cart.total = cart.subtotal + cart.deliveryFee;
    await cart.save();
    res.json(cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateCartItem = async (req, res) => {
  try {
    const { productId, quantity } = req.body;
    const cart = await Cart.findOne({ user: req.user.id });
    if (!cart) return res.status(404).json({ message: 'Cart not found' });
    const item = cart.items.find(i => i.product.toString() === productId);
    if (!item) return res.status(404).json({ message: 'Item not in cart' });
    item.quantity = quantity;
    if (item.quantity <= 0) {
      cart.items.pull({ _id: item._id });
    }
    cart.subtotal = cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
    cart.deliveryFee = cart.subtotal >= 5000 ? 0 : 1500;
    cart.total = cart.subtotal + cart.deliveryFee;
    await cart.save();
    res.json(cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.removeFromCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id });
    if (!cart) return res.status(404).json({ message: 'Cart not found' });
    cart.items.pull({ product: req.params.productId });
    cart.subtotal = cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
    cart.deliveryFee = cart.subtotal >= 5000 ? 0 : 1500;
    cart.total = cart.subtotal + cart.deliveryFee;
    await cart.save();
    res.json(cart);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.clearCart = async (req, res) => {
  try {
    const cart = await Cart.findOne({ user: req.user.id });
    if (cart) {
      cart.items = [];
      cart.subtotal = 0;
      cart.deliveryFee = 0;
      cart.total = 0;
      await cart.save();
    }
    res.json({ message: 'Cart cleared' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
