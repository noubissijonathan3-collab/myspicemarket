import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/review_constants.dart';
import 'star_rating.dart';

class RatingCategoryCard extends StatelessWidget {
  final Map<String, double> categoryAverages;

  const RatingCategoryCard({super.key, required this.categoryAverages});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rating Categories',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < ReviewConstants.categoryLabels.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _buildCategoryRow(
              ReviewConstants.categoryLabels[i],
              ReviewConstants.categoryKeys[i],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String label, String key) {
    final rating = categoryAverages[key] ?? 0;
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        StarRating(rating: rating, starSize: 12),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: rating > 0 ? rating / 5 : 0,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                rating >= 4 ? AppColors.primaryContainer : (rating >= 3 ? Colors.orange[300]! : Colors.red[300]!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            rating > 0 ? rating.toStringAsFixed(1) : '-',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
