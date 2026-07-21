import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'star_rating.dart';

class FloatingRatingWidget extends StatelessWidget {
  final double averageRating;
  final int reviewCount;
  final bool visible;

  const FloatingRatingWidget({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    this.visible = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StarRating(rating: averageRating, starSize: 14),
            const SizedBox(width: 6),
            Text(
              averageRating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($reviewCount)',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
