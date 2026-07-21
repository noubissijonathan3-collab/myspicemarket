import 'package:flutter/material.dart';

class GroceryFilterChips extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  static const filters = [
    'All',
    'Vegetables',
    'Fruits',
    'Meat',
    'Fish',
    'Spices',
    'Grains',
    'Dairy',
  ];

  const GroceryFilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = filters[i];
          final active = f == selectedFilter;
          return GestureDetector(
            onTap: () => onFilterSelected(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF99F899).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: active
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFBCCBB9),
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? Colors.white
                      : const Color(0xFF0F7427),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
