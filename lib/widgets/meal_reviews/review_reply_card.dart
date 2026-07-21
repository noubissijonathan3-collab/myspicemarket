import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/review_helpers.dart';
import '../../models/review.dart';

class ReviewReplyCard extends StatelessWidget {
  final ReviewReply reply;

  const ReviewReplyCard({super.key, required this.reply});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primaryContainer.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Response from My SpiceMarket',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reply.text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          if (reply.createdAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              ReviewHelpers.timeAgo(reply.createdAt),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
