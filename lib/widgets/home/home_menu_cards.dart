import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class HomeMenuCards extends StatelessWidget {
  final VoidCallback? onMealsTap;
  final VoidCallback? onGroceriesTap;

  const HomeMenuCards({super.key, this.onMealsTap, this.onGroceriesTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _MenuCard(
              title: "Meals",
              subtitle: "Cook complete recipes",
              icon: Icons.restaurant_menu,
              color: AppColors.primary,
              gradientColors: const [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              onTap: onMealsTap ?? () {},
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _MenuCard(
              title: "Groceries",
              subtitle: "Fresh ingredients",
              icon: Icons.shopping_basket_outlined,
              color: const Color(0xFF1565C0),
              gradientColors: const [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              onTap: onGroceriesTap ?? () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(22),
      elevation: 3,
      shadowColor: color.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          height: 140,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppColors.onSurface,
                  letterSpacing: -0.3,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
