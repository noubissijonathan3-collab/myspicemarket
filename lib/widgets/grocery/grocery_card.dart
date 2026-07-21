import 'package:flutter/material.dart';
import '../../models/grocery_product.dart';
import '../../config/app_config.dart';
import 'grocery_price_tag.dart';
import 'grocery_favorite_button.dart';
import 'add_to_cart_button.dart';

class GroceryCard extends StatelessWidget {
  final GroceryProduct product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool addedToCart;

  const GroceryCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.addedToCart = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            _buildImage(),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF121C2A),
                    ),
                  ),
                  const SizedBox(height: 2),

                  // Description
                  Text(
                    product.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6D7B6C),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Price
                  GroceryPriceTag(price: product.price, fontSize: 14),

                  const SizedBox(height: 6),

                  // Add to cart row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.unit,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6D7B6C),
                        ),
                      ),
                      AddToCartButton(
                        onPressed: onAddToCart,
                        added: addedToCart,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _imageUrl() {
    final img = product.image;
    if (img.startsWith("http")) return img;
    final path = img.startsWith("/") ? img.substring(1) : img;
    return "${AppConfig.baseUrl}/${Uri.encodeFull(path)}";
  }

  Widget _buildImage() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 14.5,
          child: Container(
            color: const Color(0xFFEFF4FF),
            child: product.image.isNotEmpty
                ? Image.network(
                    _imageUrl(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _placeholder(),
                  )
                : _placeholder(),
          ),
        ),

        // Favorite
        Positioned(
          top: 8,
          right: 8,
          child: GroceryFavoriteButton(
            product: product,
            size: 28,
          ),
        ),

        // Stock indicator
        if (product.stock <= 5 && product.stock > 0)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "Only ${product.stock} left",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(
        Icons.eco_outlined,
        color: Color(0xFF22C55E),
        size: 36,
      ),
    );
  }
}
