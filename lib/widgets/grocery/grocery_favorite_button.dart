import 'package:flutter/material.dart';
import '../../models/grocery_product.dart';
import '../../services/grocery_service.dart';

class GroceryFavoriteButton extends StatefulWidget {
  final GroceryProduct product;
  final double size;

  const GroceryFavoriteButton({
    super.key,
    required this.product,
    this.size = 32,
  });

  @override
  State<GroceryFavoriteButton> createState() => _GroceryFavoriteButtonState();
}

class _GroceryFavoriteButtonState extends State<GroceryFavoriteButton> {
  late bool _isFavorite;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.product.isFavorite;
  }

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final updated = await GroceryService.toggleFavorite(
        widget.product.id,
        !_isFavorite,
      );
      if (mounted) {
        setState(() => _isFavorite = updated.isFavorite);
      }
    } catch (_) {
      if (mounted) setState(() => _isFavorite = _isFavorite);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isFavorite ? const Color(0xFF22C55E) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          _isFavorite ? Icons.favorite : Icons.favorite_border,
          size: widget.size * 0.55,
          color: _isFavorite ? Colors.white : const Color(0xFF006E2F),
        ),
      ),
    );
  }
}
