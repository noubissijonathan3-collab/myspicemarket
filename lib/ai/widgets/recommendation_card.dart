import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/colors.dart';
import '../models/meal_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  final MealRecommendation recommendation;
  final VoidCallback? onTap;
  final VoidCallback? onOrder;

  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
    this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = recommendation.image.isNotEmpty
        ? (recommendation.image.startsWith('http') ? recommendation.image : '${AppConfig.baseUrl}${recommendation.image}')
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(height: 80, color: Colors.grey.shade100)),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(recommendation.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('${recommendation.score}%', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                      ),
                    ],
                  ),
                  if (recommendation.reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(recommendation.reason, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                  if (recommendation.price > 0) ...[
                    const SizedBox(height: 4),
                    Text('${recommendation.price.toStringAsFixed(0)} FCFA', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                  if (onOrder != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onOrder,
                        icon: const Icon(Icons.shopping_cart, size: 16),
                        label: const Text('Order Ingredients', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
