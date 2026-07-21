import 'package:flutter/material.dart';
import '../models/banner_model.dart';
import '../models/benefit_model.dart';
import '../models/product.dart';
import '../models/recommendation_model.dart';
import '../models/review.dart';
import '../services/banner_service.dart';
import '../services/benefit_service.dart';
import '../services/recommendation_service.dart';
import '../services/recently_viewed_service.dart';
import '../services/review_service.dart';

class HomeProvider with ChangeNotifier {
  List<BannerModel> _banners = [];
  List<BenefitModel> _benefits = [];
  List<Review> _reviews = [];
  List<RecommendationModel> _recommendations = [];
  List<Product> _recentlyViewed = [];
  bool _isLoading = false;
  String? _error;

  List<BannerModel> get banners => _banners;
  List<BenefitModel> get benefits => _benefits;
  List<Review> get reviews => _reviews;
  List<RecommendationModel> get recommendations => _recommendations;
  List<Product> get recentlyViewed => _recentlyViewed;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        BannerService.fetchBanners(),
        BenefitService.fetchBenefits(),
        ReviewService.fetchReviews(),
        _loadRecommendations(),
        _loadRecentlyViewed(),
      ]);

      _banners = results[0] as List<BannerModel>;
      _benefits = results[1] as List<BenefitModel>;
      _reviews = results[2] as List<Review>;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadRecommendations() async {
    try {
      await RecommendationService.generateRecommendations();
      _recommendations = await RecommendationService.fetchRecommendations();
    } catch (_) {
      _recommendations = [];
    }
  }

  Future<void> _loadRecentlyViewed() async {
    try {
      _recentlyViewed = await RecentlyViewedService.fetchRecentlyViewed();
    } catch (_) {
      _recentlyViewed = [];
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}
