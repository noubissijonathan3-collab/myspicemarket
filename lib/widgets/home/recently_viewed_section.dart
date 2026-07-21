import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../utils/colors.dart';
import 'meal_card.dart';
import 'grocery_card.dart';

class RecentlyViewedSection extends StatelessWidget {
  const RecentlyViewedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<HomeProvider>().recentlyViewed;
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.onSurfaceVariant, size: 20),
              const SizedBox(width: 8),
              const Text('Recently Viewed',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final product = items[i];
              if (product.type == 'grocery') {
                return SizedBox(width: 150, child: GroceryCard(product: product));
              }
              return MealCard(meal: product);
            },
          ),
        ),
      ],
    );
  }
}
