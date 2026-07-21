import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/search_service.dart';
import '../../utils/colors.dart';

class SearchSuggestions extends StatefulWidget {
  final String query;
  final VoidCallback onSelect;

  const SearchSuggestions({
    super.key,
    required this.query,
    required this.onSelect,
  });

  @override
  State<SearchSuggestions> createState() => _SearchSuggestionsState();
}

class _SearchSuggestionsState extends State<SearchSuggestions> {
  List<Product> _meals = [];
  List<Product> _groceries = [];
  bool _isLoading = false;

  @override
  void didUpdateWidget(covariant SearchSuggestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query && widget.query.isNotEmpty) {
      _search();
    }
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      final result = await SearchService.search(widget.query);
      final products = result['products'] as List<Product>;
      setState(() {
        _meals = products.where((p) => p.type == 'meal').toList();
        _groceries = products.where((p) => p.type == 'grocery').toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(20),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_meals.isEmpty && _groceries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      constraints: const BoxConstraints(maxHeight: 360),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_meals.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text('Meals', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.outline)),
              ),
              ..._meals.map((m) => _ResultItem(
                name: m.name,
                subtitle: '${m.price.toStringAsFixed(0)} FCFA',
                image: m.image,
                onTap: widget.onSelect,
              )),
            ],
            if (_groceries.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('Products', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.outline)),
              ),
              ..._groceries.map((g) => _ResultItem(
                name: g.name,
                subtitle: '${g.price.toStringAsFixed(0)} FCFA',
                image: g.image,
                onTap: widget.onSelect,
              )),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String name;
  final String subtitle;
  final String image;
  final VoidCallback onTap;

  const _ResultItem({
    required this.name,
    required this.subtitle,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.surfaceContainerLow,
              ),
              child: image.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(image, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.image, color: AppColors.outline)),
                    )
                  : const Icon(Icons.image, color: AppColors.outline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
