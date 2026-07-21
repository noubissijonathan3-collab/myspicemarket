import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ReviewsAppBar extends StatelessWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final bool filterActive;
  final bool sortActive;

  const ReviewsAppBar({
    super.key,
    required this.onFilterTap,
    required this.onSortTap,
    this.filterActive = false,
    this.sortActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 20, color: AppColors.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Meal Reviews',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ),
            GestureDetector(
              onTap: onFilterTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: filterActive ? AppColors.primaryContainer.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.filter_list_rounded,
                  size: 20,
                  color: filterActive ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSortTap,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: sortActive ? AppColors.primaryContainer.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.swap_vert_rounded,
                  size: 20,
                  color: sortActive ? AppColors.primary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
