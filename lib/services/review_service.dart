import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/review.dart';
import 'auth_service.dart';

class ReviewService {
  static const String baseUrl = '${AppConfig.baseUrl}/api/reviews';

  static Future<List<Review>> fetchReviews({int limit = 10}) async {
    final response = await http.get(Uri.parse('$baseUrl?limit=$limit')).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data['reviews'] ?? [];
      return list.map((e) => Review.fromJson(e)).toList();
    }
    throw data['message'] ?? 'Failed to fetch reviews';
  }

  static Future<Map<String, dynamic>> fetchMealReviews({
    required String mealId,
    int page = 1,
    int limit = 10,
    int? rating,
    bool? verified,
    bool? hasPhotos,
    String sort = 'newest',
  }) async {
    final params = {'page': page.toString(), 'limit': limit.toString(), 'sort': sort};
    if (rating != null) params['rating'] = rating.toString();
    if (verified == true) params['verified'] = 'true';
    if (hasPhotos == true) params['hasPhotos'] = 'true';

    final uri = Uri.parse('$baseUrl/meal/$mealId').replace(queryParameters: params);
    final response = await http.get(uri).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final List list = data['reviews'] ?? [];
      return {
        'reviews': list.map((e) => Review.fromJson(e)).toList(),
        'total': data['total'] ?? 0,
        'page': data['page'] ?? 1,
        'pages': data['pages'] ?? 1,
        'hasMore': data['hasMore'] ?? false,
      };
    }
    throw data['message'] ?? 'Failed to fetch reviews';
  }

  static Future<Review> fetchReview(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id')).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return Review.fromJson(data);
    throw data['message'] ?? 'Failed to fetch review';
  }

  static Future<Review> createReview({
    required String mealId,
    required int rating,
    String title = '',
    String comment = '',
    List<String> images = const [],
    bool verifiedPurchase = false,
    Map<String, dynamic>? categoryRatings,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{
      'mealId': mealId,
      'rating': rating,
      'title': title,
      'comment': comment,
      'images': images,
      'verifiedPurchase': verifiedPurchase,
    };
    if (categoryRatings != null) body['categoryRatings'] = categoryRatings;
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) return Review.fromJson(data);
    throw data['message'] ?? 'Failed to create review';
  }

  static Future<Review> updateReview({
    required String id,
    int? rating,
    String? title,
    String? comment,
    List<String>? images,
    Map<String, dynamic>? categoryRatings,
  }) async {
    final token = await AuthService.getToken();
    final body = <String, dynamic>{};
    if (rating != null) body['rating'] = rating;
    if (title != null) body['title'] = title;
    if (comment != null) body['comment'] = comment;
    if (images != null) body['images'] = images;
    if (categoryRatings != null) body['categoryRatings'] = categoryRatings;

    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return Review.fromJson(data);
    throw data['message'] ?? 'Failed to update review';
  }

  static Future<void> deleteReview(String id) async {
    final token = await AuthService.getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to delete review';
    }
  }

  static Future<Map<String, dynamic>> toggleHelpful(String reviewId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$reviewId/helpful'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) return data;
    throw data['message'] ?? 'Failed to toggle helpful';
  }

  static Future<bool> getHelpfulStatus(String reviewId) async {
    final token = await AuthService.getToken();
    if (token == null) return false;
    final response = await http.get(
      Uri.parse('$baseUrl/$reviewId/helpful-status'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['helpful'] ?? false;
    }
    return false;
  }

  static Future<void> reportReview(String reviewId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$reviewId/report'),
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(const Duration(seconds: 60));
    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw data['message'] ?? 'Failed to report review';
    }
  }
}
