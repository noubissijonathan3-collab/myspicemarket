import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/benefit_model.dart';
import '../../providers/home_provider.dart';
import '../../utils/colors.dart';

class WhyChooseSection extends StatelessWidget {
  const WhyChooseSection({super.key});

  IconData _iconFromString(String name) {
    switch (name) {
      case 'local_shipping': return Icons.local_shipping;
      case 'spa': return Icons.spa;
      case 'payments': return Icons.payments;
      case 'verified': return Icons.verified;
      case 'security': return Icons.security;
      case 'support_agent': return Icons.support_agent;
      case 'restaurant_menu': return Icons.restaurant_menu;
      case 'bolt': return Icons.bolt;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final benefits = context.watch<HomeProvider>().benefits;
    final isLoading = context.watch<HomeProvider>().isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Why Choose My SpiceMarket?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
          const SizedBox(height: 14),
          if (isLoading && benefits.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else
            ...List.generate(benefits.length, (i) {
              final benefit = benefits[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < benefits.length - 1 ? 10 : 0),
                child: _BenefitCard(benefit: benefit, icon: _iconFromString(benefit.icon)),
              );
            }),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final BenefitModel benefit;
  final IconData icon;

  const _BenefitCard({required this.benefit, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary.withValues(alpha: 0.12),
            child: Icon(icon, size: 22, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benefit.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Text(benefit.description, style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
