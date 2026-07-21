import 'package:flutter/foundation.dart';
import '../models/rating_summary.dart';
import '../services/rating_service.dart';

class RatingProvider with ChangeNotifier {
  RatingSummary _ratingSummary = RatingSummary();
  bool _isLoading = false;
  String? _error;

  RatingSummary get ratingSummary => _ratingSummary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRatingSummary(String mealId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _ratingSummary = await RatingService.fetchRatingSummary(mealId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
