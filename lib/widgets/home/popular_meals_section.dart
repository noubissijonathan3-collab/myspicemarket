import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../utils/colors.dart';
import 'meal_card.dart';

class PopularMealsSection extends StatefulWidget {
  final VoidCallback? onViewAll;

  const PopularMealsSection({super.key, this.onViewAll});

  @override
  State<PopularMealsSection> createState() => _PopularMealsSectionState();
}

class _PopularMealsSectionState extends State<PopularMealsSection> {
  List<Product> _meals = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final meals = await ProductService.fetchPopularMeals();
      if (mounted) setState(() { _meals = meals; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Popular Meals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                TextButton(
                  onPressed: widget.onViewAll,
                  child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SizedBox(height: 120, child: Center(child: Text('Failed to load meals', style: TextStyle(color: AppColors.onSurfaceVariant))))
          else if (_meals.isEmpty)
            const SizedBox(height: 120, child: Center(child: Text('No meals available', style: TextStyle(color: AppColors.onSurfaceVariant))))
          else
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _meals.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => MealCard(meal: _meals[i]),
              ),
            ),
        ],
      ),
    );
  }
}
