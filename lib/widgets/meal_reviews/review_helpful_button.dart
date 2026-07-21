import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ReviewHelpfulButton extends StatelessWidget {
  final int count;
  final bool isHelpful;
  final VoidCallback onTap;

  const ReviewHelpfulButton({
    super.key,
    required this.count,
    required this.isHelpful,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isHelpful ? AppColors.primaryContainer.withValues(alpha: 0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHelpful ? AppColors.primaryContainer : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHelpful ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
              size: 14,
              color: isHelpful ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              count > 0 ? 'Helpful ($count)' : 'Helpful',
              style: TextStyle(
                fontSize: 12,
                color: isHelpful ? AppColors.primary : Colors.grey[600],
                fontWeight: isHelpful ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
