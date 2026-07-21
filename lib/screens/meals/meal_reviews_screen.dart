import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rating_breakdown.dart';
import '../../providers/review_provider.dart';
import '../../services/review_service.dart';
import '../../utils/colors.dart';
import '../../widgets/meal_reviews/reviews_app_bar.dart';
import '../../widgets/meal_reviews/meal_review_summary_card.dart';
import '../../widgets/meal_reviews/overall_rating_card.dart';
import '../../widgets/meal_reviews/rating_category_card.dart';
import '../../widgets/meal_reviews/write_review_card.dart';
import '../../widgets/meal_reviews/review_filter_chips.dart';
import '../../widgets/meal_reviews/review_sort_bottom_sheet.dart';
import '../../widgets/meal_reviews/customer_review_card.dart';
import '../../widgets/meal_reviews/floating_rating_widget.dart';
import '../../widgets/meal_reviews/empty_reviews_widget.dart';
import '../../widgets/meal_reviews/loading_reviews_widget.dart';
import '../../widgets/meal_reviews/error_reviews_widget.dart';
import '../../widgets/meal_reviews/review_statistics_card.dart';
import 'write_review_screen.dart';

class MealReviewsScreen extends StatefulWidget {
  final String mealId;
  final String mealName;
  final String mealImage;
  final String mealDescription;
  final String mealCategory;
  final double initialRating;
  final int initialReviewCount;
  final String? badge;

  const MealReviewsScreen({
    super.key,
    required this.mealId,
    required this.mealName,
    required this.mealImage,
    this.mealDescription = '',
    this.mealCategory = '',
    this.initialRating = 0,
    this.initialReviewCount = 0,
    this.badge,
  });

  @override
  State<MealReviewsScreen> createState() => _MealReviewsScreenState();
}

class _MealReviewsScreenState extends State<MealReviewsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingRating = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<ReviewProvider>();
    provider.loadReviews(mealId: widget.mealId);

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 300;
    if (show != _showFloatingRating) {
      setState(() => _showFloatingRating = show);
    }

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ReviewProvider>().loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<ReviewProvider>().refresh(mealId: widget.mealId);
  }

  void _openWriteReview({String? reviewId, int? rating, String? title, String? comment}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WriteReviewScreen(
          mealId: widget.mealId,
          reviewId: reviewId,
          initialRating: rating,
          initialTitle: title,
          initialComment: comment,
        ),
      ),
    );
  }

  void _showSortSheet() {
    final provider = context.read<ReviewProvider>();
    ReviewSortBottomSheet.show(context, provider.sortBy, (sort) {
      provider.setSortBy(sort);
    });
  }

  void _showFilterSheet() {
    final provider = context.read<ReviewProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                TextButton(
                  onPressed: () {
                    provider.clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear All', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Rating', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (int i = 5; i >= 1; i--)
                  _filterChip('$i\u2605', provider.ratingFilter == i, () {
                    provider.setRatingFilter(i);
                    Navigator.of(context).pop();
                  }),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _filterChip('Verified Purchases', provider.ratingFilter == null, () {
                  provider.setVerifiedFilter(true);
                  Navigator.of(context).pop();
                }),
                _filterChip('With Photos', provider.photosFilter == true, () {
                  provider.setPhotosFilter(true);
                  Navigator.of(context).pop();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : Colors.grey[300]!),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<ReviewProvider>(
          builder: (context, provider, _) {
            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: ReviewsAppBar(
                          onFilterTap: _showFilterSheet,
                          onSortTap: _showSortSheet,
                          filterActive: provider.ratingFilter != null || provider.verifiedFilter != null || provider.photosFilter != null,
                          sortActive: provider.sortBy != 'newest',
                        ),
                      ),

                      if (provider.isLoading && provider.reviews.isEmpty)
                        const SliverFillRemaining(child: LoadingReviewsWidget()),

                      if (!provider.isLoading && provider.error != null && provider.reviews.isEmpty)
                        SliverFillRemaining(
                          child: ErrorReviewsWidget(
                            message: provider.error!,
                            onRetry: () => provider.loadReviews(mealId: widget.mealId),
                          ),
                        ),

                      if (!provider.isLoading && provider.error == null) ...[
                        SliverToBoxAdapter(
                          child: MealReviewSummaryCard(
                            image: widget.mealImage,
                            name: widget.mealName,
                            description: widget.mealDescription,
                            category: widget.mealCategory,
                            averageRating: provider.ratingSummary.averageRating > 0
                                ? provider.ratingSummary.averageRating
                                : widget.initialRating,
                            reviewCount: provider.ratingSummary.reviewCount > 0
                                ? provider.ratingSummary.reviewCount
                                : widget.initialReviewCount,
                            badge: widget.badge,
                          ),
                        ),

                        if (provider.ratingSummary.reviewCount > 0) ...[
                          SliverToBoxAdapter(
                            child: OverallRatingCard(
                              averageRating: provider.ratingSummary.averageRating,
                              reviewCount: provider.ratingSummary.reviewCount,
                              breakdown: RatingBreakdown.fromDistribution(provider.ratingSummary.distribution),
                              verifiedReviewCount: provider.ratingSummary.verifiedReviewCount,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: RatingCategoryCard(
                              categoryAverages: provider.ratingSummary.categoryAverages,
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: ReviewStatisticsCard(summary: provider.ratingSummary),
                          ),
                        ],

                        SliverToBoxAdapter(
                          child: WriteReviewCard(
                            hasReviewed: false,
                            onWriteReview: () => _openWriteReview(),
                          ),
                        ),

                        if (provider.reviews.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                              child: Row(
                                children: [
                                  Text(
                                    '${provider.ratingSummary.reviewCount} Reviews',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'Sorted: ${provider.sortBy}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: ReviewFilterChips(
                              selectedRating: provider.ratingFilter,
                              verifiedFilter: provider.verifiedFilter,
                              photosFilter: provider.photosFilter,
                              onRatingFilter: (r) => provider.setRatingFilter(r),
                              onVerifiedFilter: (v) => provider.setVerifiedFilter(v),
                              onPhotosFilter: (p) => provider.setPhotosFilter(p),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final review = provider.reviews[index];
                                return CustomerReviewCard(
                                  review: review,
                                  isHelpful: review.likedByUser,
                                  onHelpfulTap: (id) => provider.toggleHelpful(id),
                                  onReportTap: (id) => ReviewService.reportReview(id),
                                  onDeleteTap: (id) => _confirmDelete(id),
                                );
                              },
                              childCount: provider.reviews.length,
                            ),
                          ),
                          if (provider.isLoadingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                  ),
                                ),
                              ),
                            ),
                          if (!provider.hasMore && provider.reviews.length >= 5)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text(
                                    "You've reached the end of the reviews",
                                    style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                  ),
                                ),
                              ),
                            ),
                        ],

                        if (provider.reviews.isEmpty && !provider.isLoading)
                          SliverFillRemaining(
                            child: EmptyReviewsWidget(
                              onWriteReview: () => _openWriteReview(),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingRatingWidget(
                      averageRating: provider.ratingSummary.averageRating > 0
                          ? provider.ratingSummary.averageRating
                          : widget.initialRating,
                      reviewCount: provider.ratingSummary.reviewCount > 0
                          ? provider.ratingSummary.reviewCount
                          : widget.initialReviewCount,
                      visible: _showFloatingRating,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmDelete(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ReviewService.deleteReview(reviewId);
        if (mounted) context.read<ReviewProvider>().removeReviewLocally(reviewId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), behavior: SnackBarBehavior.floating),
          );
        }
      }
    }
  }
}
