import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../config/app_config.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import 'notification_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final greeting = Helpers.getGreeting();
    final firstName = user.firstName;

    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: AppColors.surface.withValues(alpha: 0.8),
          child: Row(
            children: [
              const Icon(Icons.menu, color: AppColors.primary),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'My SpiceMarket',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              NotificationButton(
                onTap: () => Navigator.pushNamed(context, '/notifications'),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryContainer, width: 2),
                    color: AppColors.surfaceContainerHighest,
                  ),
                  child: ClipOval(
                    child: user.user?.avatar.isNotEmpty == true
                        ? Image.network(
                            user.user!.avatar.startsWith('http') ? user.user!.avatar : '${AppConfig.baseUrl}${user.user!.avatar}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(Icons.person, size: 20, color: AppColors.primary))
                        : const Icon(Icons.person, size: 20, color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '$firstName 👋',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
                const SizedBox(height: 4),
                const Text(
                  'What would you like to cook today?',
                  style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
