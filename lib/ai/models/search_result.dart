class SearchResult {
  final String id;
  final String name;
  final String image;
  final String description;
  final double price;
  final String reason;
  final int score;

  SearchResult({
    this.id = '',
    this.name = '',
    this.image = '',
    this.description = '',
    this.price = 0,
    this.reason = '',
    this.score = 0,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final meal = json['meal'] as Map<String, dynamic>?;
    return SearchResult(
      id: meal?['_id'] ?? json['_id'] ?? json['id'] ?? '',
      name: meal?['name'] ?? json['name'] ?? '',
      image: meal?['image'] ?? json['image'] ?? '',
      description: meal?['description'] ?? json['description'] ?? '',
      price: (meal?['price'] ?? json['price'] ?? 0).toDouble(),
      reason: json['reason'] ?? '',
      score: json['score'] ?? 0,
    );
  }
}
