import 'package:flutter/material.dart';
import '../models/grocery_product.dart';
import '../services/grocery_service.dart';

class GroceryProvider with ChangeNotifier {
  List<GroceryProduct> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  List<GroceryProduct> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get hasMore => _currentPage < _totalPages;

  // ================= LOAD PRODUCTS =================
  Future<void> loadProducts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _products = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await GroceryService.fetchProducts(
        category: _selectedCategory,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        page: _currentPage,
      );

      final newProducts = (result['products'] as List)
          .map((e) => GroceryProduct.fromJson(e))
          .toList();

      if (refresh) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }

      _totalPages = result['pages'] ?? 1;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ================= LOAD MORE (pagination) =================
  Future<void> loadMore() async {
    if (_isLoading || !hasMore) return;
    _currentPage++;
    await loadProducts();
  }

  // ================= SET CATEGORY =================
  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    loadProducts(refresh: true);
  }

  // ================= SET SEARCH =================
  void setSearch(String query) {
    _searchQuery = query;
    loadProducts(refresh: true);
  }

  // ================= UPDATE PRODUCT IN LIST =================
  void updateProduct(GroceryProduct updated) {
    final index = _products.indexWhere((p) => p.id == updated.id);
    if (index >= 0) {
      _products[index] = updated;
      notifyListeners();
    }
  }
}
