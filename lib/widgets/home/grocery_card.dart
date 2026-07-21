import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../utils/helpers.dart';
import 'favorite_button.dart';
import 'meal_price_tag.dart';
import 'product_image.dart';

class GroceryCard extends StatelessWidget {
  final Product product;

  const GroceryCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMd),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppDimensions.groceryCardImageHeight,
              child: Stack(
                children: [
                  ProductImage(
                    image: product.image,
                    width: double.infinity,
                    height: AppDimensions.groceryCardImageHeight,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.borderRadiusMd)),
                  ),
                  if (product.badge.isNotEmpty)
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(product.badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: FavoriteButton(productId: product.id, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(product.unit.isNotEmpty ? product.unit : 'Fresh item', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(child: MealPriceTag(price: product.price, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: product.stock > 5 ? AppColors.secondaryContainer : AppColors.errorContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            product.stock > 5 ? 'In Stock' : 'Low Stock',
                            style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: product.stock > 5 ? AppColors.onSecondaryContainer : AppColors.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartProvider>().addItem(product.id);
                          Helpers.showSnackBar(context, 'Added ${product.name} to cart');
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryContainer,
                          foregroundColor: AppColors.onSecondaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
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

