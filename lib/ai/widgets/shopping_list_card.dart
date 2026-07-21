import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class ShoppingListItem {
  final String name;
  final String quantity;
  final String unit;
  final bool checked;

  ShoppingListItem({required this.name, this.quantity = '', this.unit = '', this.checked = false});
}

class ShoppingListCard extends StatelessWidget {
  final String title;
  final List<ShoppingListItem> items;

  const ShoppingListCard({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 20,
                    color: item.checked ? AppColors.primary : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name, style: TextStyle(
                    fontSize: 14,
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                    color: item.checked ? Colors.grey.shade500 : AppColors.onSurface,
                  ))),
                  if (item.quantity.isNotEmpty)
                    Text('${item.quantity} ${item.unit}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
