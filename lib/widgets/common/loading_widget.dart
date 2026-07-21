import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double height;

  const LoadingWidget({super.key, this.height = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(const Color(0xFF22C55E)),
            ),
            const SizedBox(height: 16),
            Text(
              "Loading meals...",
              style: TextStyle(
                color: const Color(0xFF6D7B6C),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
