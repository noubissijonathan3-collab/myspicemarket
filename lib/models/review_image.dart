class ReviewImage {
  final String url;

  ReviewImage({required this.url});

  factory ReviewImage.fromJson(Map<String, dynamic> json) {
    return ReviewImage(
      url: json['url'] ?? json['image'] ?? '',
    );
  }
}
