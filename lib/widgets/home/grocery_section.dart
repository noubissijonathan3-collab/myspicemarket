import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../utils/colors.dart';
import 'grocery_card.dart';

class GrocerySection extends StatefulWidget {
  final VoidCallback? onViewAll;

  const GrocerySection({super.key, this.onViewAll});

  @override
  State<GrocerySection> createState() => _GrocerySectionState();
}

class _GrocerySectionState extends State<GrocerySection> {
  List<Product> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final products = await ProductService.fetchPopularGroceries();
      if (mounted) setState(() { _products = products; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Groceries', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                TextButton(
                  onPressed: widget.onViewAll,
                  child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            SizedBox(height: 160, child: Center(child: Text('Failed to load groceries', style: TextStyle(color: AppColors.onSurfaceVariant))))
          else if (_products.isEmpty)
            const SizedBox(height: 160, child: Center(child: Text('No groceries available', style: TextStyle(color: AppColors.onSurfaceVariant))))
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _products.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (_, i) => SizedBox(
                  width: 150,
                  child: GroceryCard(product: _products[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
