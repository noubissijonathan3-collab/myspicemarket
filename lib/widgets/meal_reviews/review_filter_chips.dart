import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ReviewFilterChips extends StatelessWidget {
  final int? selectedRating;
  final bool? verifiedFilter;
  final bool? photosFilter;
  final ValueChanged<int?> onRatingFilter;
  final ValueChanged<bool?> onVerifiedFilter;
  final ValueChanged<bool?> onPhotosFilter;

  const ReviewFilterChips({
    super.key,
    this.selectedRating,
    this.verifiedFilter,
    this.photosFilter,
    required this.onRatingFilter,
    required this.onVerifiedFilter,
    required this.onPhotosFilter,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildChip('All', selectedRating == null && verifiedFilter == null && photosFilter == null, () {
            onRatingFilter(null);
            onVerifiedFilter(null);
            onPhotosFilter(null);
          }),
          const SizedBox(width: 8),
          for (int i = 5; i >= 1; i--) ...[
            _buildChip('$i\u2605', selectedRating == i, () => onRatingFilter(i)),
            const SizedBox(width: 8),
          ],
          _buildChip('Verified', verifiedFilter == true, () => onVerifiedFilter(true)),
          const SizedBox(width: 8),
          _buildChip('With Photos', photosFilter == true, () => onPhotosFilter(true)),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? AppColors.primary : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              color: active ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
