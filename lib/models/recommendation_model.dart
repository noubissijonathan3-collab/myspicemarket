import 'product.dart';

class RecommendationModel {
  final String id;
  final Product? product;
  final String reason;
  final double score;
  final String type;
  final bool isActive;

  RecommendationModel({
    required this.id,
    this.product,
    this.reason = '',
    this.score = 0,
    this.type = 'meal',
    this.isActive = true,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: json['_id'] ?? json['id'] ?? '',
      product: json['product'] != null ? Product.fromJson(json['product']) : null,
      reason: json['reason'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      type: json['type'] ?? 'meal',
      isActive: json['isActive'] ?? true,
    );
  }
}
