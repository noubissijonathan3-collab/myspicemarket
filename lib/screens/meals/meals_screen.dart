import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/empty_widget.dart';
import '../../widgets/meals/meal_header.dart';
import '../../widgets/meals/meal_search_bar.dart';
import '../../widgets/meals/meal_filter_chips.dart';
import '../../widgets/meals/meal_card.dart';
import 'meal_details_screen.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  late Future<List<Product>> _mealsFuture;
  List<Product> _allMeals = [];
  List<Product> _filteredMeals = [];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  void _loadMeals() {
    setState(() {
      _mealsFuture = ProductService.fetchProducts(type: 'meal').then((r) => r['products'] as List<Product>);
    });
  }

  void _onSearchChanged(String query) {
    _searchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredMeals = _allMeals.where((meal) {
      final matchesSearch = meal.name.toLowerCase().contains(_searchQuery) ||
          meal.description.toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "Popular") return meal.isPopular;
      if (_selectedFilter == "Quick Meals") return meal.cookTime <= 20;
      if (_selectedFilter == "Vegetarian") return meal.categoryName == "Vegetarian";
      return meal.categoryName == _selectedFilter;
    }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: FutureBuilder<List<Product>>(
          future: _mealsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoading();
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            _allMeals = snapshot.data ?? [];
            if (_filteredMeals.isEmpty &&
                _searchQuery.isEmpty &&
                _selectedFilter == "All") {
              _filteredMeals = _allMeals;
            }

            return _buildContent();
          },
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      children: [
        const MealHeader(),
        MealSearchBar(
          controller: TextEditingController(),
          onChanged: (_) {},
        ),
        const SizedBox(height: 12),
        MealFilterChips(
          selectedFilter: _selectedFilter,
          onFilterSelected: (_) {},
        ),
        const Expanded(child: LoadingWidget()),
      ],
    );
  }

  Widget _buildError(String error) {
    return Column(
      children: [
        const MealHeader(),
        Expanded(
          child: ErrorWidgetCustom(
            message: error,
            onRetry: _loadMeals,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        MealHeader(
          onCartTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cart coming soon")),
            );
          },
        ),
        MealSearchBar(
          controller: _searchController,
          onChanged: _onSearchChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MealFilterChips(
            selectedFilter: _selectedFilter,
            onFilterSelected: _onFilterSelected,
          ),
        ),

        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                "${_filteredMeals.length} meals found",
                style: const TextStyle(
                  color: Color(0xFF6D7B6C),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.grid_view_rounded,
                color: Color(0xFF6D7B6C),
                size: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Meal cards grid
        Expanded(
          child: _filteredMeals.isEmpty
              ? const EmptyWidget(
                  title: "No meals found",
                  subtitle: "Try a different search or filter",
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _loadMeals();
                    await _mealsFuture;
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _filteredMeals[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MealCard(
                          meal: meal,
                          onTap: () => _openDetails(meal),
                          onOrder: () => _openDetails(meal),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  void _openDetails(Product meal) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealDetailsScreen(meal: meal),
      ),
    );
  }
}
