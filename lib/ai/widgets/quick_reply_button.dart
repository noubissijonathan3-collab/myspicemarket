import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class QuickReplyButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const QuickReplyButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
      backgroundColor: AppColors.surfaceContainerLow,
      side: BorderSide(color: AppColors.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
