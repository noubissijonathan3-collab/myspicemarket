class Review {
  final String id;
  final String mealId;
  final String userId;
  final String userName;
  final String userImage;
  final int rating;
  final String title;
  final String comment;
  final List<String> images;
  final bool verifiedPurchase;
  final int helpfulCount;
  final bool likedByUser;
  final ReviewReply? reply;
  final Map<String, double> categoryRatings;
  final String createdAt;
  final String updatedAt;

  Review({
    required this.id,
    required this.mealId,
    required this.userId,
    this.userName = '',
    this.userImage = '',
    required this.rating,
    this.title = '',
    this.comment = '',
    this.images = const [],
    this.verifiedPurchase = false,
    this.helpfulCount = 0,
    this.likedByUser = false,
    this.reply,
    this.categoryRatings = const {},
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] is Map
        ? json['userId'] as Map<String, dynamic>
        : null;

    Map<String, dynamic>? replyJson = json['reply'] is Map
        ? json['reply'] as Map<String, dynamic>
        : null;
    if (replyJson != null && (replyJson['text'] == null || replyJson['text'] == '')) {
      replyJson = null;
    }

    Map<String, double> catRatings = {};
    if (json['categoryRatings'] is Map) {
      catRatings = (json['categoryRatings'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      );
    }

    List<String> imageList = [];
    if (json['images'] is List) {
      imageList = (json['images'] as List).map((e) => e.toString()).toList();
    }

    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      mealId: json['mealId'] ?? '',
      userId: user != null
          ? (user['_id'] ?? user['id'] ?? '')
          : (json['userId'] ?? ''),
      userName: user?['fullName'] ?? '',
      userImage: user?['profileImage'] ?? '',
      rating: json['rating'] ?? 5,
      title: json['title'] ?? '',
      comment: json['comment'] ?? '',
      images: imageList,
      verifiedPurchase: json['verifiedPurchase'] ?? false,
      helpfulCount: json['helpfulCount'] ?? 0,
      likedByUser: json['likedByUser'] ?? false,
      reply: replyJson != null ? ReviewReply.fromJson(replyJson) : null,
      categoryRatings: catRatings,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class ReviewReply {
  final String text;
  final String createdAt;

  ReviewReply({required this.text, this.createdAt = ''});

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      text: json['text'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
