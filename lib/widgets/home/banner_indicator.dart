import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class BannerIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const BannerIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: currentIndex == index ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: currentIndex == index ? AppColors.primary : AppColors.outlineVariant,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
