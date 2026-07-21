import 'package:flutter/material.dart';

class GroceryEmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const GroceryEmptyWidget({
    super.key,
    this.title = "No grocery items found",
    this.subtitle = "Try adjusting your search or filter",
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_basket_outlined,
                size: 72, color: Color(0xFFDEE9FC)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121C2A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6D7B6C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
