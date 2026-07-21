import 'package:flutter/material.dart';

class GroceryLoadingWidget extends StatelessWidget {
  const GroceryLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Color(0xFF22C55E)),
          ),
          SizedBox(height: 16),
          Text(
            "Loading groceries...",
            style: TextStyle(
              color: Color(0xFF6D7B6C),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
