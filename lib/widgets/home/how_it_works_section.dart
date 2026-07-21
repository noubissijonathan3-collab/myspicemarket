import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXxl),
        ),
        child: Column(
          children: [
            const Text(
              'How It Works',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StepItem(icon: Icons.restaurant_menu, label: 'Browse Meals', index: 0),
                _StepArrow(),
                _StepItem(icon: Icons.visibility, label: 'View Ingredients', index: 1),
                _StepArrow(),
                _StepItem(icon: Icons.tune, label: 'Adjust Quantities', index: 2),
                _StepArrow(),
                _StepItem(icon: Icons.add_shopping_cart, label: 'Add To Cart', index: 3),
                _StepArrow(),
                _StepItem(icon: Icons.local_shipping, label: 'Get Delivered', index: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;

  const _StepItem({required this.icon, required this.label, required this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurface), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _StepArrow extends StatelessWidget {
  const _StepArrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary.withValues(alpha: 0.3)),
    );
  }
}
