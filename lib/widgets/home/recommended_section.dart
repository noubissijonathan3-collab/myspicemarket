import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recommendation_model.dart';
import '../../providers/home_provider.dart';
import '../../utils/colors.dart';
import 'meal_card.dart';
import 'grocery_card.dart';

class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key});

  @override
  Widget build(BuildContext context) {
    final recs = context.watch<HomeProvider>().recommendations;
    if (recs.isEmpty) return const SizedBox.shrink();

    final meals = recs.where((r) => r.product != null && r.product!.type == 'meal').toList();
    final groceries = recs.where((r) => r.product != null && r.product!.type == 'grocery').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text('Recommended for You',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
            ],
          ),
        ),
        if (meals.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: meals.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => MealCard(meal: meals[i].product!),
            ),
          ),
        ],
        if (groceries.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: groceries.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => SizedBox(
                width: 150,
                child: GroceryCard(product: groceries[i].product!),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
