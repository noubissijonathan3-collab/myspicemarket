import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../models/rating_breakdown.dart';

class RatingDistributionChart extends StatelessWidget {
  final RatingBreakdown breakdown;
  final int totalReviews;

  const RatingDistributionChart({
    super.key,
    required this.breakdown,
    required this.totalReviews,
  });

  @override
  Widget build(BuildContext context) {
    final bars = [
      _buildBar(5, breakdown.fiveStar, breakdown.percentageFive, '\u2605\u2605\u2605\u2605\u2605'),
      _buildBar(4, breakdown.fourStar, breakdown.percentageFour, '\u2605\u2605\u2605\u2605\u2606'),
      _buildBar(3, breakdown.threeStar, breakdown.percentageThree, '\u2605\u2605\u2605\u2606\u2606'),
      _buildBar(2, breakdown.twoStar, breakdown.percentageTwo, '\u2605\u2605\u2606\u2606\u2606'),
      _buildBar(1, breakdown.oneStar, breakdown.percentageOne, '\u2605\u2606\u2606\u2606\u2606'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final bar in bars) ...[
          if (bars.indexOf(bar) > 0) const SizedBox(height: 6),
          bar,
        ],
      ],
    );
  }

  Widget _buildBar(int star, int count, double percentage, String label) {
    return Row(
      children: [
        SizedBox(
          width: 30,
          child: Text(
            '$star',
            style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.star, size: 12, color: const Color(0xFFFFB800)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                star >= 4 ? AppColors.primaryContainer : (star == 3 ? Colors.orange[300]! : Colors.red[300]!),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '$count',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
        ),
      ],
    );
  }
}
