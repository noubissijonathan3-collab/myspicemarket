import 'package:flutter/foundation.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<String> _favoriteIds = {};
  final Set<String> _togglingIds = {};
  bool _isLoading = false;

  Set<String> get favoriteIds => _favoriteIds;
  Set<String> get togglingIds => _togglingIds;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final ids = await FavoriteService.fetchFavoriteIds();
      _favoriteIds.clear();
      _favoriteIds.addAll(ids);
    } catch (e) {
      debugPrint('loadFavorites error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  bool isToggling(String mealId) => _togglingIds.contains(mealId);

  Future<bool> toggle(String mealId) async {
    if (_togglingIds.contains(mealId)) return _favoriteIds.contains(mealId);

    _togglingIds.add(mealId);
    notifyListeners();

    try {
      if (_favoriteIds.contains(mealId)) {
        await FavoriteService.removeFavorite(mealId);
        _favoriteIds.remove(mealId);
      } else {
        await FavoriteService.addFavorite(mealId);
        _favoriteIds.add(mealId);
      }
      _togglingIds.remove(mealId);
      notifyListeners();
      return _favoriteIds.contains(mealId);
    } catch (e) {
      _togglingIds.remove(mealId);
      notifyListeners();
      debugPrint('toggleFavorite error: $e');
      rethrow;
    }
  }

  bool isFavorite(String mealId) => _favoriteIds.contains(mealId);

  void clear() {
    _favoriteIds.clear();
    _togglingIds.clear();
    _isLoading = false;
    notifyListeners();
  }
}
