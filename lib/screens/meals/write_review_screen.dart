import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../utils/review_constants.dart';
import '../../widgets/meal_reviews/star_rating.dart';
import '../../services/review_service.dart';
import '../../providers/review_provider.dart';

class WriteReviewScreen extends StatefulWidget {
  final String mealId;
  final String? reviewId;
  final int? initialRating;
  final String? initialTitle;
  final String? initialComment;
  final Map<String, double>? initialCategoryRatings;

  const WriteReviewScreen({
    super.key,
    required this.mealId,
    this.reviewId,
    this.initialRating,
    this.initialTitle,
    this.initialComment,
    this.initialCategoryRatings,
  });

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  int _rating = 0;
  final _titleController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isEdit = false;
  bool _showCategories = false;

  late Map<String, int> _categoryRatings;

  @override
  void initState() {
    super.initState();
    _isEdit = widget.reviewId != null;
    if (widget.initialRating != null) _rating = widget.initialRating!;
    if (widget.initialTitle != null) _titleController.text = widget.initialTitle!;
    if (widget.initialComment != null) _commentController.text = widget.initialComment!;
    _categoryRatings = {
      for (final key in ReviewConstants.categoryKeys)
        key: widget.initialCategoryRatings?[key]?.toInt() ?? 0,
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? get _nonZeroCategoryRatings {
    final result = <String, dynamic>{};
    for (final key in ReviewConstants.categoryKeys) {
      if (_categoryRatings[key]! > 0) result[key] = _categoryRatings[key];
    }
    return result.isEmpty ? null : result;
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      _showSnack('Please select a rating');
      return;
    }
    if (_commentController.text.trim().isEmpty) {
      _showSnack('Please write a review');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      if (_isEdit) {
        await ReviewService.updateReview(
          id: widget.reviewId!,
          rating: _rating,
          title: _titleController.text.trim(),
          comment: _commentController.text.trim(),
          categoryRatings: _nonZeroCategoryRatings,
        );
      } else {
        await ReviewService.createReview(
          mealId: widget.mealId,
          rating: _rating,
          title: _titleController.text.trim(),
          comment: _commentController.text.trim(),
          categoryRatings: _nonZeroCategoryRatings,
        );
      }

      if (mounted) {
        final provider = context.read<ReviewProvider>();
        provider.refresh(mealId: widget.mealId);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Review' : 'Write a Review'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tap a star to rate',
              style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Center(
              child: StarRating(
                rating: _rating.toDouble(),
                starSize: 40,
                interactive: true,
                onRatingChanged: (r) => setState(() => _rating = r),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Review title (optional)',
                labelText: 'Title',
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Share your experience with this meal...',
                labelText: 'Your Review',
                alignLabelWithHint: true,
              ),
              maxLines: 6,
              maxLength: 1000,
            ),
            const SizedBox(height: 20),
            InkWell(
              onTap: () => setState(() => _showCategories = !_showCategories),
              child: Row(
                children: [
                  Icon(
                    _showCategories ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Category Ratings (optional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (_showCategories) ...[
              const SizedBox(height: 12),
              ...List.generate(ReviewConstants.categoryKeys.length, (i) {
                final key = ReviewConstants.categoryKeys[i];
                final label = ReviewConstants.categoryLabels[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Spacer(),
                      StarRating(
                        rating: _categoryRatings[key]!.toDouble(),
                        starSize: 24,
                        interactive: true,
                        onRatingChanged: (r) {
                          setState(() => _categoryRatings[key] = r);
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? 'Update Review' : 'Submit Review', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
