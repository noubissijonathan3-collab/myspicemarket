class RatingSummary {
  final double averageRating;
  final int reviewCount;
  final double recommendationPercentage;
  final int verifiedReviewCount;
  final Map<int, int> distribution;
  final Map<String, double> categoryAverages;

  RatingSummary({
    this.averageRating = 0,
    this.reviewCount = 0,
    this.recommendationPercentage = 0,
    this.verifiedReviewCount = 0,
    this.distribution = const {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
    this.categoryAverages = const {},
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    Map<int, int> dist = {};
    if (json['distribution'] is Map) {
      (json['distribution'] as Map).forEach((k, v) {
        dist[int.parse(k.toString())] = (v as num).toInt();
      });
    }

    Map<String, double> cats = {};
    if (json['categoryAverages'] is Map) {
      cats = (json['categoryAverages'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      );
    }

    return RatingSummary(
      averageRating: (json['averageRating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      recommendationPercentage: (json['recommendationPercentage'] ?? 0).toDouble(),
      verifiedReviewCount: json['verifiedReviewCount'] ?? 0,
      distribution: dist,
      categoryAverages: cats,
    );
  }
}
