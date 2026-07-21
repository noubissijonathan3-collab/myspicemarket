import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  double _subtotal = 0;
  double _deliveryFee = 0;
  double _total = 0;

  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _subtotal;
  double get deliveryFee => _deliveryFee;
  double get total => _total;
  double get totalPrice => _total;
  bool get isLoading => _isLoading;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await CartService.fetchCart();
      _items = (data['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ?? [];
      _subtotal = (data['subtotal'] ?? 0).toDouble();
      _deliveryFee = (data['deliveryFee'] ?? 0).toDouble();
      _total = (data['total'] ?? 0).toDouble();
    } catch (_) {
      _items = [];
      _subtotal = 0;
      _deliveryFee = 0;
      _total = 0;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(String productId, {int quantity = 1}) async {
    try {
      await CartService.addToCart(productId, quantity: quantity);
      await loadCart();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      await CartService.updateQuantity(productId, quantity);
      await loadCart();
    } catch (_) {
      rethrow;
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      await CartService.removeFromCart(productId);
      await loadCart();
    } catch (_) {
      rethrow;
    }
  }

  void clear() {
    _items = [];
    _subtotal = 0;
    _deliveryFee = 0;
    _total = 0;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> clearCart() async {
    try {
      await CartService.clearCart();
      _items = [];
      _subtotal = 0;
      _deliveryFee = 0;
      _total = 0;
      notifyListeners();
    } catch (_) {
      rethrow;
    }
  }
}
