import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyWidget({
    super.key,
    this.title = "No meals found",
    this.subtitle = "Try adjusting your search or filter",
    this.icon = Icons.restaurant_menu_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: const Color(0xFFDEE9FC)),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF121C2A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6D7B6C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
