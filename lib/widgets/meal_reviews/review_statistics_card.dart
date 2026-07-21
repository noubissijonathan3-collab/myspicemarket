import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/rating_summary.dart';

class ReviewStatisticsCard extends StatelessWidget {
  final RatingSummary summary;

  const ReviewStatisticsCard({super.key, required this.summary});

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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Total Reviews', summary.reviewCount.toString(), Icons.rate_review_outlined),
          _buildDivider(),
          _buildStat('Avg. Rating', summary.averageRating.toStringAsFixed(1), Icons.star_outline),
          _buildDivider(),
          _buildStat('Recommend', '${summary.recommendationPercentage}%', Icons.thumb_up_outlined),
          _buildDivider(),
          _buildStat('Verified', summary.verifiedReviewCount.toString(), Icons.verified_outlined),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryContainer),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[200],
    );
  }
}
