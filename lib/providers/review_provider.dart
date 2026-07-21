import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../models/rating_summary.dart';
import '../services/review_service.dart';
import '../services/rating_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  RatingSummary _ratingSummary = RatingSummary();
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _mealId = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;

  String _sortBy = 'newest';
  int? _ratingFilter;
  bool? _verifiedFilter;
  bool? _photosFilter;

  List<Review> get reviews => _reviews;
  RatingSummary get ratingSummary => _ratingSummary;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  String get sortBy => _sortBy;
  int? get ratingFilter => _ratingFilter;
  bool? get verifiedFilter => _verifiedFilter;
  bool? get photosFilter => _photosFilter;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  void setSortBy(String sort) {
    if (_sortBy == sort) return;
    _sortBy = sort;
    _reviews.clear();
    _currentPage = 1;
    notifyListeners();
    loadReviews(mealId: _mealId, refresh: true);
  }

  void setRatingFilter(int? rating) {
    if (_ratingFilter == rating) return;
    _ratingFilter = _ratingFilter == rating ? null : rating;
    _reviews.clear();
    _currentPage = 1;
    notifyListeners();
    loadReviews(mealId: _mealId, refresh: true);
  }

  void setVerifiedFilter(bool? verified) {
    if (_verifiedFilter == verified) return;
    _verifiedFilter = _verifiedFilter == verified ? null : verified;
    _reviews.clear();
    _currentPage = 1;
    notifyListeners();
    loadReviews(mealId: _mealId, refresh: true);
  }

  void setPhotosFilter(bool? photos) {
    if (_photosFilter == photos) return;
    _photosFilter = _photosFilter == photos ? null : photos;
    _reviews.clear();
    _currentPage = 1;
    notifyListeners();
    loadReviews(mealId: _mealId, refresh: true);
  }

  void clearFilters() {
    _ratingFilter = null;
    _verifiedFilter = null;
    _photosFilter = null;
    _sortBy = 'newest';
    _reviews.clear();
    _currentPage = 1;
    notifyListeners();
    loadReviews(mealId: _mealId, refresh: true);
  }

  Future<void> loadReviews({required String mealId, bool refresh = false}) async {
    _mealId = mealId;
    if (refresh || _currentPage == 1) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        ReviewService.fetchMealReviews(
          mealId: mealId,
          page: _currentPage,
          sort: _sortBy,
          rating: _ratingFilter,
          verified: _verifiedFilter,
          hasPhotos: _photosFilter,
        ),
        RatingService.fetchRatingSummary(mealId),
      ]);

      final reviewData = results[0] as Map<String, dynamic>;
      final newReviews = reviewData['reviews'] as List<Review>;
      _totalPages = reviewData['pages'] as int;
      _hasMore = reviewData['hasMore'] as bool;

      if (_currentPage == 1) {
        _reviews = newReviews;
      } else {
        _reviews.addAll(newReviews);
      }

      _ratingSummary = results[1] as RatingSummary;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    _currentPage++;
    notifyListeners();
    await loadReviews(mealId: _mealId);
  }

  Future<void> refresh({required String mealId}) async {
    _currentPage = 1;
    _hasMore = true;
    _reviews.clear();
    notifyListeners();
    await loadReviews(mealId: mealId, refresh: true);
  }

  Future<void> toggleHelpful(String reviewId) async {
    try {
      final result = await ReviewService.toggleHelpful(reviewId);
      final helpful = result['helpful'] as bool;
      final count = result['helpfulCount'] as int;
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final old = _reviews[index];
        _reviews[index] = Review(
          id: old.id,
          mealId: old.mealId,
          userId: old.userId,
          userName: old.userName,
          userImage: old.userImage,
          rating: old.rating,
          title: old.title,
          comment: old.comment,
          images: old.images,
          verifiedPurchase: old.verifiedPurchase,
          helpfulCount: count,
          likedByUser: helpful,
          reply: old.reply,
          categoryRatings: old.categoryRatings,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('toggleHelpful error: $e');
    }
  }

  void removeReviewLocally(String reviewId) {
    _reviews.removeWhere((r) => r.id == reviewId);
    notifyListeners();
  }
}
