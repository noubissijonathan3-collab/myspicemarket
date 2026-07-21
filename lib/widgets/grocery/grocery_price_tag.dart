import 'package:flutter/material.dart';

class GroceryPriceTag extends StatelessWidget {
  final int price;
  final double fontSize;
  final bool showUnit;

  const GroceryPriceTag({
    super.key,
    required this.price,
    this.fontSize = 16,
    this.showUnit = false,
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
