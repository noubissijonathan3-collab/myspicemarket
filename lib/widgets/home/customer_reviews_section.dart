import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../utils/colors.dart';
import 'review_card.dart';

class CustomerReviewsSection extends StatelessWidget {
  const CustomerReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<HomeProvider>().reviews;
    final isLoading = context.watch<HomeProvider>().isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('What Our Customers Say', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                if (reviews.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: isLoading && reviews.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : reviews.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: Center(child: Text('No reviews yet', style: TextStyle(color: AppColors.onSurfaceVariant))),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: reviews.length,
                        itemBuilder: (_, i) => ReviewCard(review: reviews[i]),
                      ),
          ),
        ],
      ),
    );
  }
}
