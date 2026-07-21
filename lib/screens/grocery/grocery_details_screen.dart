import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/grocery_product.dart';
import '../../config/app_config.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/grocery/grocery_price_tag.dart';
import '../../widgets/grocery/grocery_favorite_button.dart';
import '../../widgets/grocery/grocery_quantity_selector.dart';

class GroceryDetailsScreen extends StatefulWidget {
  final GroceryProduct product;

  const GroceryDetailsScreen({super.key, required this.product});

  @override
  State<GroceryDetailsScreen> createState() => _GroceryDetailsScreenState();
}

class _GroceryDetailsScreenState extends State<GroceryDetailsScreen> {
  late GroceryProduct _product;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  int get _totalPrice => _product.price * _quantity;

  String _imageUrl() {
    final img = _product.image;
    if (img.startsWith("http")) return img;
    final path = img.startsWith("/") ? img.substring(1) : img;
    return "${AppConfig.baseUrl}/${Uri.encodeFull(path)}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    _buildInfo(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 26),
          ),
          const Spacer(),
          const Icon(Icons.shopping_cart_outlined, size: 24),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: const Color(0xFFEFF4FF),
                child: _product.image.isNotEmpty
                    ? Image.network(
                        _imageUrl(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: GroceryFavoriteButton(
                product: _product,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Icon(Icons.eco_outlined, size: 48, color: Color(0xFF22C55E)),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(
            _product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF121C2A),
            ),
          ),
          const SizedBox(height: 8),

          // Category + stock
          Row(
            children: [
              _Chip(label: _product.category),
              const SizedBox(width: 8),
              _Chip(
                label: _product.stock > 0
                    ? "In Stock (${_product.stock})"
                    : "Out of Stock",
                color: _product.stock > 0
                    ? const Color(0xFF22C55E)
                    : Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Price + unit
          Row(
            children: [
              GroceryPriceTag(price: _product.price, fontSize: 22),
              const SizedBox(width: 8),
              Text(
                "/ ${_product.unit}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6D7B6C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            _product.description.isNotEmpty
                ? _product.description
                : "Fresh ${_product.name.toLowerCase()} sourced directly from local farms.",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3D4A3D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Quantity
          Row(
            children: [
              const Text(
                "Quantity:",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF121C2A),
                ),
              ),
              const SizedBox(width: 12),
              GroceryQuantitySelector(
                quantity: _quantity,
                onIncrement: () => setState(() => _quantity++),
                onDecrement: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Total",
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6D7B6C),
                    ),
                  ),
                  GroceryPriceTag(price: _totalPrice, fontSize: 18),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<CartProvider>().addItem(_product.id, quantity: _quantity);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "${_product.name} x$_quantity added to cart"),
                    backgroundColor: const Color(0xFF006E2F),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006E2F),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Add to Cart",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color? color;

  const _Chip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFF006E2F)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color ?? const Color(0xFF006E2F),
        ),
      ),
    );
  }
}
