import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../config/app_config.dart';
import 'favorite_button.dart';
import 'ingredients_button.dart';

class MealCard extends StatelessWidget {
  final Product meal;
  final VoidCallback? onTap;
  final VoidCallback? onOrder;

  const MealCard({
    super.key,
    required this.meal,
    this.onTap,
    this.onOrder,
  });

  String _imageUrl() {
    final img = meal.image;
    if (img.startsWith("http")) return img;
    final path = img.startsWith("/") ? img.substring(1) : img;
    return "${AppConfig.baseUrl}/${Uri.encodeFull(path)}";
  }

  bool _isAssetImage() {
    return meal.image.startsWith("assets/");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ================= IMAGE =================
            _buildImageSection(),

            // ================= DETAILS =================
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Image with aspect ratio
        AspectRatio(
          aspectRatio: 4 / 3,
          child: _isAssetImage()
              ? Image.asset(
                  meal.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _imagePlaceholder(),
                )
              : Image.network(
                  _imageUrl(),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _imagePlaceholder(),
                ),
        ),

        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Favorite button — top-right
        Positioned(
          top: 8,
          right: 8,
          child: FavoriteButton(mealId: meal.id, size: 30, favoritesCount: meal.favoritesCount),
        ),

        // Cook time & serves — bottom-left over gradient
        Positioned(
          bottom: 8,
          left: 8,
          child: Row(
            children: [
              _InfoChip(
                icon: Icons.timer_outlined,
                label: "${meal.cookTime} min",
              ),
              const SizedBox(width: 6),
              _InfoChip(
                icon: Icons.people_outline,
                label: "${meal.serves} serves",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEFF4FF),
      child: const Center(
        child: Icon(Icons.restaurant, size: 40, color: Color(0xFFBCCBB9)),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Name
          Text(
            meal.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF121C2A),
            ),
          ),
          const SizedBox(height: 3),

          // Description
          Text(
            meal.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6D7B6C),
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Ingredients count
          Row(
            children: [
              Icon(
                Icons.eco_outlined,
                size: 14,
                color: const Color(0xFF22C55E),
              ),
              const SizedBox(width: 4),
              Text(
                "${meal.ingredientsCount} ingredients",
                style: const TextStyle(
                  color: Color(0xFF3D4A3D),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Full-width Order Ingredients button
          IngredientsButton(onPressed: onOrder),
        ],
      ),
    );
  }
}

// ================= Info Chip (image overlay) =================
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
