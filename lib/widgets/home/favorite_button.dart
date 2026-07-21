import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorite_provider.dart';
import '../../utils/colors.dart';

class FavoriteButton extends StatelessWidget {
  final String productId;
  final double size;

  const FavoriteButton({
    super.key,
    required this.productId,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FavoriteProvider>();
    final isFav = provider.isFavorite(productId);
    final toggling = provider.isToggling(productId);

    return GestureDetector(
      onTap: toggling
          ? null
          : () async {
              try {
                await provider.toggle(productId);
              } catch (e) {
                  if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$e'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: toggling
            ? SizedBox(
                key: const ValueKey('loading'),
                width: size,
                height: size,
                child: const Center(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : Icon(
                isFav ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFav),
                color: isFav ? AppColors.error : AppColors.primary,
                size: size,
              ),
      ),
    );
  }
}
