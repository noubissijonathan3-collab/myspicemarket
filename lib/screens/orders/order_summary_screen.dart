import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/order_summary_data.dart';
import '../../utils/colors.dart';
import 'checkout_screen.dart';

class OrderSummaryScreen extends StatelessWidget {
  final OrderSummaryData data;

  const OrderSummaryScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Summary'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildMealHeader(),
                const SizedBox(height: 16),
                _buildSectionTitle('Ingredients & Items'),
                const SizedBox(height: 8),
                ...data.items.map(_buildItemCard),
                const SizedBox(height: 16),
                _buildTotalSection(),
              ],
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildMealHeader() {
    final imageUrl = data.meal.image.startsWith('http')
        ? data.meal.image
        : '${AppConfig.baseUrl}/${Uri.encodeFull(data.meal.image)}';

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(width: 100, height: 100, color: AppColors.surfaceContainerHighest,
                child: const Icon(Icons.restaurant, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.meal.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${data.meal.servings} servings · ${data.meal.cookTime} min',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(height: 4),
                  Text('${data.items.length} items', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.onSurface));
  }

  Widget _buildItemCard(OrderItem item) {
    final imageUrl = item.image.startsWith('http')
        ? item.image
        : '${AppConfig.baseUrl}/${Uri.encodeFull(item.image)}';
    final lineTotal = item.price * item.quantity;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(width: 48, height: 48, color: AppColors.surfaceContainerHighest,
                  child: const Icon(Icons.inventory_2_outlined, size: 20, color: AppColors.primary)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text('${item.quantity} × ${item.price} FCFA / ${item.unit}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Text('$lineTotal FCFA', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _totalRow('Subtotal', '${data.subtotal} FCFA'),
            const SizedBox(height: 10),
            _totalRow('Delivery Fee', '${data.deliveryFee} FCFA'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(),
            ),
            _totalRow('Grand Total', '${data.total} FCFA', bold: true, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool bold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: bold ? 16 : 14, fontWeight: bold ? FontWeight.w600 : FontWeight.normal, color: Colors.grey.shade700)),
        Text(value, style: TextStyle(fontSize: bold ? 16 : 14, fontWeight: FontWeight.w600, color: color ?? AppColors.onSurface)),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -4))],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CheckoutScreen(data: data))),
          icon: const Icon(Icons.delivery_dining, size: 20),
          label: Text('Proceed to Checkout — ${data.total} FCFA'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
