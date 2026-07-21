import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/review_constants.dart';

class ReviewSortBottomSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortSelected;

  const ReviewSortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortSelected,
  });

  static Future<void> show(BuildContext context, String currentSort, ValueChanged<String> onSortSelected) {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ReviewSortBottomSheet(
        currentSort: currentSort,
        onSortSelected: (sort) {
          Navigator.of(context).pop();
          onSortSelected(sort);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort Reviews',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < ReviewConstants.sortOptions.length; i++) ...[
            _buildSortOption(
              ReviewConstants.sortOptions[i],
              ReviewConstants.sortValues[i],
            ),
            if (i < ReviewConstants.sortOptions.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = currentSort == value;
    return InkWell(
      onTap: () => onSortSelected(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
