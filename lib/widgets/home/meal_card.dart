import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import 'favorite_button.dart';
import 'meal_price_tag.dart';
import 'product_image.dart';

class MealCard extends StatelessWidget {
  final Product meal;
  final VoidCallback? onOrder;

  const MealCard({
    super.key,
    required this.meal,
    this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/meal-detail', arguments: meal.id),
      child: Container(
        width: AppDimensions.mealCardWidth,
        margin: const EdgeInsets.only(right: AppDimensions.gutter),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ProductImage(
                  image: meal.image,
                  height: AppDimensions.mealCardImageHeight,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.borderRadiusMd)),
                ),
                if (meal.badge.isNotEmpty)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                      child: Text(meal.badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: FavoriteButton(productId: meal.id),
                  ),
                ),
                if (meal.favoritesCount > 0)
                  Positioned(
                    bottom: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.favorite, size: 10, color: Colors.white),
                          const SizedBox(width: 3),
                          Text('${meal.favoritesCount}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meal.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(
                      meal.description.isNotEmpty ? meal.description : '${meal.ingredientsCount} ingredients included',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 12, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('${meal.preparationTime} min', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                        const SizedBox(width: 12),
                        Icon(Icons.people_outline, size: 12, color: AppColors.outline),
                        const SizedBox(width: 4),
                        Text('${meal.servings} servings', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: MealPriceTag(price: meal.price)),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: onOrder ?? () => Navigator.pushNamed(context, '/meal-detail', arguments: meal.id),
                          child: const Text('Order', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
