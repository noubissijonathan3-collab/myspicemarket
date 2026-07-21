import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class WriteReviewCard extends StatelessWidget {
  final bool hasReviewed;
  final VoidCallback onWriteReview;
  final VoidCallback? onEditReview;

  const WriteReviewCard({
    super.key,
    required this.hasReviewed,
    required this.onWriteReview,
    this.onEditReview,
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
      child: hasReviewed
          ? Column(
              children: [
                const Icon(Icons.check_circle, size: 40, color: AppColors.primaryContainer),
                const SizedBox(height: 8),
                const Text(
                  'You already reviewed this meal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                if (onEditReview != null)
                  ElevatedButton.icon(
                    onPressed: onEditReview,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit Review'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
            )
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share Your Experience',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your feedback helps other food lovers!',
                        style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: onWriteReview,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Write Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
    );
  }
}
