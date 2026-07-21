import 'package:flutter/material.dart';
import '../../models/grocery_product.dart';
import 'grocery_card.dart';

class GroceryGrid extends StatelessWidget {
  final List<GroceryProduct> products;
  final ValueChanged<GroceryProduct> onProductTap;
  final ValueChanged<GroceryProduct> onAddToCart;
  final Set<String> addedIds;

  const GroceryGrid({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.addedIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 600 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.60,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) {
        final product = products[i];
        return GroceryCard(
          product: product,
          onTap: () => onProductTap(product),
          onAddToCart: () => onAddToCart(product),
          addedToCart: addedIds.contains(product.id),
        );
      },
    );
  }
}
