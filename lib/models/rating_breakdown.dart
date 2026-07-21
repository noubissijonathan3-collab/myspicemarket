class RatingBreakdown {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final int fourStar;
  final int fiveStar;

  RatingBreakdown({
    this.oneStar = 0,
    this.twoStar = 0,
    this.threeStar = 0,
    this.fourStar = 0,
    this.fiveStar = 0,
  });

  int get total => oneStar + twoStar + threeStar + fourStar + fiveStar;

  double get percentageFive => total > 0 ? fiveStar / total : 0;
  double get percentageFour => total > 0 ? fourStar / total : 0;
  double get percentageThree => total > 0 ? threeStar / total : 0;
  double get percentageTwo => total > 0 ? twoStar / total : 0;
  double get percentageOne => total > 0 ? oneStar / total : 0;

  factory RatingBreakdown.fromJson(Map<String, dynamic> json) {
    return RatingBreakdown(
      oneStar: json['1'] ?? 0,
      twoStar: json['2'] ?? 0,
      threeStar: json['3'] ?? 0,
      fourStar: json['4'] ?? 0,
      fiveStar: json['5'] ?? 0,
    );
  }

  factory RatingBreakdown.fromDistribution(Map<int, int> dist) {
    return RatingBreakdown(
      oneStar: dist[1] ?? 0,
      twoStar: dist[2] ?? 0,
      threeStar: dist[3] ?? 0,
      fourStar: dist[4] ?? 0,
      fiveStar: dist[5] ?? 0,
    );
  }
}
