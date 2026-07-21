import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class VerifiedPurchaseBadge extends StatelessWidget {
  const VerifiedPurchaseBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 10, color: AppColors.primary),
          const SizedBox(width: 2),
          Text(
            'Verified Purchase',
            style: TextStyle(
              fontSize: 9,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
