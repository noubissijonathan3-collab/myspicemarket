import 'package:flutter/material.dart';

class MealPriceTag extends StatelessWidget {
  final int price;
  final double fontSize;

  const MealPriceTag({
    super.key,
    required this.price,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "$price FCFA",
      maxLines: 1,
      overflow: TextOverflow.fade,
      softWrap: false,
      style: TextStyle(
        color: const Color(0xFF006E2F),
        fontWeight: FontWeight.w800,
        fontSize: fontSize,
      ),
    );
  }
}
