import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double starSize;
  final int starCount;
  final bool interactive;
  final ValueChanged<int>? onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;

  const StarRating({
    super.key,
    this.rating = 0,
    this.starSize = 16,
    this.starCount = 5,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final starValue = index + 1;
        final isFull = rating >= starValue;
        final isHalf = !isFull && rating >= starValue - 0.5;

        return GestureDetector(
          onTap: interactive ? () => onRatingChanged?.call(starValue) : null,
          child: Padding(
            padding: EdgeInsets.only(right: index < starCount - 1 ? 2 : 0),
            child: Icon(
              isFull ? Icons.star : (isHalf ? Icons.star_half : Icons.star_border),
              size: starSize,
              color: isFull || isHalf ? activeColor : inactiveColor,
            ),
          ),
        );
      }),
    );
  }
}
