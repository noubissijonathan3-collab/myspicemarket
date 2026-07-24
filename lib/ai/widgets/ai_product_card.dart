import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../providers/cart_provider.dart';
import '../../utils/colors.dart';

class AiProductCard extends StatelessWidget {
  final String? productId;
  final String? productName;
  final double? productPrice;
  final String? productImage;
  final String? description;

  const AiProductCard({
    super.key,
    this.productId,
    this.productName,
    this.productPrice,
    this.productImage,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    if (productName == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: [
          if (productImage != null && productImage!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                productImage!.startsWith('http')
                    ? productImage!
                    : '${AppConfig.baseUrl}/$productImage',
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 56,
                  height: 56,
                  color: AppColors.surfaceContainerLow,
                  child: const Icon(Icons.restaurant, color: Colors.grey, size: 24),
                ),
              ),
            )
          else
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.restaurant, color: AppColors.primary, size: 24),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description != null && description!.isNotEmpty)
                  Text(
                    description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (productPrice != null)
                  Text(
                    '${productPrice!.toInt()} FCFA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (productId != null)
            IconButton(
              icon: Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 20),
              onPressed: () async {
                final cart = context.read<CartProvider>();
                await cart.addItem(productId!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$productName added to cart'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              tooltip: 'Add to cart',
            ),
        ],
      ),
    );
  }
}
