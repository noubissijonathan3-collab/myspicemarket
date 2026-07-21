import 'package:flutter/material.dart';

class GroceryHeader extends StatelessWidget {
  final int cartItemCount;
  final VoidCallback? onCartTap;

  const GroceryHeader({
    super.key,
    this.cartItemCount = 0,
    this.onCartTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Grocery Items",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF121C2A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Fresh foodstuffs delivered daily",
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6D7B6C),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              IconButton(
                onPressed: onCartTap,
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Color(0xFF121C2A),
                  size: 26,
                ),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Color(0xFF22C55E),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "$cartItemCount",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
