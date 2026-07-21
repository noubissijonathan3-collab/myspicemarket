import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/grocery_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/grocery_product.dart';
import '../../widgets/grocery/grocery_header.dart';
import '../../widgets/grocery/grocery_search_bar.dart';
import '../../widgets/grocery/grocery_filter_chips.dart';
import '../../widgets/grocery/grocery_grid.dart';
import '../../widgets/grocery/grocery_loading_widget.dart';
import '../../widgets/grocery/grocery_error_widget.dart';
import '../../widgets/grocery/grocery_empty_widget.dart';
import 'grocery_details_screen.dart';

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<String> _addedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GroceryProvider>().loadProducts(refresh: true);
      context.read<CartProvider>().loadCart();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<GroceryProvider>().setSearch(query);
  }

  void _onFilterSelected(String filter) {
    _searchCtrl.clear();
    context.read<GroceryProvider>().setCategory(filter);
  }

  Future<void> _onRefresh() async {
    _addedIds.clear();
    await context.read<GroceryProvider>().loadProducts(refresh: true);
  }

  void _onProductTap(GroceryProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroceryDetailsScreen(product: product),
      ),
    );
  }

  void _onAddToCart(GroceryProduct product) async {
    final cartProvider = context.read<CartProvider>();
    await cartProvider.addItem(product.id, quantity: 1);

    setState(() => _addedIds.add(product.id));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _addedIds.remove(product.id));
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${product.name} added to cart"),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF006E2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GroceryProvider, CartProvider>(
      builder: (context, grocery, cart, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FF),
          body: SafeArea(
            child: Column(
              children: [
                GroceryHeader(
                  cartItemCount: cart.itemCount,
                  onCartTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cart coming soon")),
                    );
                  },
                ),
                GrocerySearchBar(
                  controller: _searchCtrl,
                  onChanged: _onSearchChanged,
                ),
                GroceryFilterChips(
                  selectedFilter: grocery.selectedCategory,
                  onFilterSelected: _onFilterSelected,
                ),
                const SizedBox(height: 8),
                Expanded(child: _buildBody(grocery)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(GroceryProvider grocery) {
    if (grocery.isLoading && grocery.products.isEmpty) {
      return const GroceryLoadingWidget();
    }

    if (grocery.error != null && grocery.products.isEmpty) {
      return GroceryErrorWidget(
        message: grocery.error!,
        onRetry: () => grocery.loadProducts(refresh: true),
      );
    }

    if (grocery.products.isEmpty) {
      return const GroceryEmptyWidget();
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
          grocery.loadMore();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: GroceryGrid(
          products: grocery.products,
          onProductTap: _onProductTap,
          onAddToCart: _onAddToCart,
          addedIds: _addedIds,
        ),
      ),
    );
  }
}
