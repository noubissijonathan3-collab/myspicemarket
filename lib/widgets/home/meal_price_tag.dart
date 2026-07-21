import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';

class MealPriceTag extends StatelessWidget {
  final double price;
  final double fontSize;
  final Color color;

  const MealPriceTag({
    super.key,
    required this.price,
    this.fontSize = 16,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      Helpers.formatPrice(price),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.02,
      ),
    );
  }
}
