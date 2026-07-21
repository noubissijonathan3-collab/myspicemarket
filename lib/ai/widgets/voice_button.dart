import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class VoiceButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback? onPressed;
  final double size;

  const VoiceButton({
    super.key,
    this.isListening = false,
    this.onPressed,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isListening ? Colors.red : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (isListening ? Colors.red : AppColors.primary).withValues(alpha: 0.3),
              blurRadius: isListening ? 20 : 8,
              spreadRadius: isListening ? 4 : 0,
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: size * 0.45,
        ),
      ),
    );
  }
}
