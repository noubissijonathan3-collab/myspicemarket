import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../utils/colors.dart';
import '../../utils/review_helpers.dart';

class ReviewerAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  final double size;

  const ReviewerAvatar({
    super.key,
    this.imageUrl = '',
    this.name = '',
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          imageUrl.startsWith('http') ? imageUrl : '${AppConfig.baseUrl}$imageUrl',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultAvatar(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _defaultAvatar();
          },
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          ReviewHelpers.getInitials(name),
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}
