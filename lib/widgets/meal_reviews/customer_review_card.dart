import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/review_helpers.dart';
import '../../models/review.dart';
import 'reviewer_avatar.dart';
import 'star_rating.dart';
import 'verified_purchase_badge.dart';
import 'review_images_gallery.dart';
import 'review_helpful_button.dart';
import 'review_reply_card.dart';

class CustomerReviewCard extends StatelessWidget {
  final Review review;
  final bool isHelpful;
  final ValueChanged<String> onHelpfulTap;
  final ValueChanged<String>? onReportTap;
  final ValueChanged<String>? onDeleteTap;

  const CustomerReviewCard({
    super.key,
    required this.review,
    required this.isHelpful,
    required this.onHelpfulTap,
    this.onReportTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 8),
          if (review.title.isNotEmpty) ...[
            Text(
              review.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 10),
            ReviewImagesGallery(images: review.images),
          ],
          if (review.reply != null) ...[
            ReviewReplyCard(reply: review.reply!),
          ],
          const SizedBox(height: 10),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReviewerAvatar(
          imageUrl: review.userImage,
          name: review.userName,
          size: 36,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    review.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  if (review.verifiedPurchase) ...[
                    const SizedBox(width: 6),
                    const VerifiedPurchaseBadge(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                ReviewHelpers.timeAgo(review.createdAt),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            StarRating(rating: review.rating.toDouble(), starSize: 12),
            if (review.updatedAt.isNotEmpty && review.updatedAt != review.createdAt)
              Text(
                'Edited',
                style: TextStyle(fontSize: 9, color: Colors.grey[400]),
              ),
          ],
        ),
        if (onReportTap != null || onDeleteTap != null) ...[
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 18,
            icon: Icon(Icons.more_vert, color: Colors.grey[400]),
            itemBuilder: (_) => [
              if (onReportTap != null)
                const PopupMenuItem(value: 'report', child: Text('Report', style: TextStyle(fontSize: 13))),
              if (onDeleteTap != null)
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(fontSize: 13, color: Colors.red))),
            ],
            onSelected: (value) {
              if (value == 'report' && onReportTap != null) onReportTap!(review.id);
              if (value == 'delete' && onDeleteTap != null) onDeleteTap!(review.id);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        ReviewHelpfulButton(
          count: review.helpfulCount,
          isHelpful: isHelpful,
          onTap: () => onHelpfulTap(review.id),
        ),
      ],
    );
  }
}
