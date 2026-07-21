import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'star_rating.dart';
import 'rating_distribution_chart.dart';
import '../../models/rating_breakdown.dart';

class OverallRatingCard extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final RatingBreakdown breakdown;
  final int verifiedReviewCount;

  const OverallRatingCard({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    required this.breakdown,
    this.verifiedReviewCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                StarRating(rating: averageRating, starSize: 20),
                const SizedBox(height: 6),
                Text(
                  'Based on $reviewCount ${reviewCount == 1 ? 'review' : 'reviews'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (verifiedReviewCount > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$verifiedReviewCount verified',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 3,
            child: RatingDistributionChart(
              breakdown: breakdown,
              totalReviews: reviewCount,
            ),
          ),
        ],
      ),
    );
  }
}
