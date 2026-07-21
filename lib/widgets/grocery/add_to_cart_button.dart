import 'package:flutter/material.dart';

class AddToCartButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool added;

  const AddToCartButton({
    super.key,
    this.onPressed,
    this.added = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: added ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: added ? const Color(0xFF006E2F) : const Color(0xFF99F899),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          added ? Icons.check : Icons.add_shopping_cart,
          size: 20,
          color: added ? Colors.white : const Color(0xFF0F7427),
        ),
      ),
    );
  }
}
