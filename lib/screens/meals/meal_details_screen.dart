import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../models/meal_ingredient.dart';
import '../../models/grocery_product.dart';
import '../../services/meal_detail_service.dart';
import '../../services/grocery_service.dart';
import '../../services/rating_service.dart';
import '../../providers/favorite_provider.dart';
import '../../config/app_config.dart';
import '../../models/order_summary_data.dart';
import '../../theme/app_theme.dart';
import '../orders/order_summary_screen.dart';
import 'meal_reviews_screen.dart';

class MealDetailsScreen extends StatefulWidget {
  final Product meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  late Product _meal;
  List<MealIngredient> _ingredients = [];
  List<GroceryProduct> _recommended = [];
  List<Product> _relatedMeals = [];
  int _deliveryFee = 1500;

  bool _loadingIngredients = true;
  bool _loadingRelated = true;
  String? _ingredientsError;

  double _averageRating = 0;
  int _reviewCount = 0;

  final Map<String, int> _ingredientQtys = {};
  final Set<String> _removedIngredientIds = {};
  final List<GroceryProduct> _extraItems = [];
  final Map<String, int> _extraQtys = {};

  final ScrollController _scrollCtrl = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _meal = widget.meal;
    _scrollCtrl.addListener(_onScroll);
    _loadAll();
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = _scrollCtrl.offset > 200;
    if (shouldShow != _showTitle) {
      setState(() => _showTitle = shouldShow);
    }
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _loadMeal(),
      _loadIngredients(),
      _loadRecommended(),
      _loadRelated(),
      _loadDeliveryFee(),
      _loadRating(),
    ]);
  }

  Future<void> _loadRating() async {
    try {
      final summary = await RatingService.fetchRatingSummary(_meal.id);
      if (mounted) {
        setState(() {
          _averageRating = summary.averageRating;
          _reviewCount = summary.reviewCount;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadMeal() async {
    try {
      final meal = await MealDetailService.fetchMeal(_meal.id);
      if (mounted) setState(() => _meal = meal);
    } catch (_) {}
  }

  Future<void> _loadIngredients() async {
    try {
      final ingredients = await MealDetailService.fetchIngredients(_meal.id);
      if (mounted) {
        setState(() {
          _ingredients = ingredients;
          _loadingIngredients = false;
          for (final ing in ingredients) {
            _ingredientQtys[ing.foodstuffId] = ing.quantity.ceil();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _ingredientsError = e.toString();
          _loadingIngredients = false;
        });
      }
    }
  }

  Future<void> _loadRecommended() async {
    try {
      final products = await MealDetailService.fetchRecommendedProducts();
      if (mounted) setState(() => _recommended = products);
    } catch (_) {}
  }

  Future<void> _loadRelated() async {
    try {
      final meals = await MealDetailService.fetchRelatedMeals(_meal.categoryId);
      if (mounted) {
        setState(() {
          _relatedMeals = meals
              .where((m) => m.id != _meal.id)
              .take(10)
              .toList();
          _loadingRelated = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingRelated = false);
    }
  }

  Future<void> _loadDeliveryFee() async {
    final fee = await MealDetailService.fetchDeliveryFee();
    if (mounted) setState(() => _deliveryFee = fee);
  }

  void _toggleFavorite() {
    context.read<FavoriteProvider>().toggle(_meal.id);
  }

  void _updateIngredientQty(String foodstuffId, int delta) {
    setState(() {
      final current = _ingredientQtys[foodstuffId] ?? 1;
      _ingredientQtys[foodstuffId] = max(1, current + delta);
    });
  }

  void _removeIngredient(String foodstuffId) async {
    final removed = _ingredients.firstWhere(
      (i) => i.foodstuffId == foodstuffId,
    );
    setState(() => _removedIngredientIds.add(foodstuffId));
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Remove Ingredient?"),
        content: Text("Remove ${removed.foodstuffName} from your list?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Keep"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Remove"),
          ),
        ],
      ),
    );
    if (result != true) {
      setState(() => _removedIngredientIds.remove(foodstuffId));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${removed.foodstuffName} removed"),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "Undo",
            textColor: Colors.white,
            onPressed: () {
              if (mounted) {
                setState(() => _removedIngredientIds.remove(foodstuffId));
              }
            },
          ),
        ),
      );
    }
  }

  void _updateExtraQty(String productId, int delta) {
    setState(() {
      final current = _extraQtys[productId] ?? 1;
      _extraQtys[productId] = max(1, current + delta);
    });
  }

  void _removeExtra(String productId) {
    setState(() {
      _extraItems.removeWhere((e) => e.id == productId);
      _extraQtys.remove(productId);
    });
  }

  Future<void> _openFoodstuffPicker() async {
    final result = await Navigator.push<List<GroceryProduct>>(
      context,
      MaterialPageRoute(builder: (_) => const _GroceryPickerScreen()),
    );
    if (result != null && mounted) {
      setState(() {
        for (final product in result) {
          if (!_extraItems.any((e) => e.id == product.id)) {
            _extraItems.add(product);
            _extraQtys[product.id] = 1;
          }
        }
      });
    }
  }

  int get _ingredientsTotal {
    int total = 0;
    for (final ing in _ingredients) {
      if (_removedIngredientIds.contains(ing.foodstuffId)) continue;
      final qty = _ingredientQtys[ing.foodstuffId] ?? ing.quantity.ceil();
      total += ing.foodstuffPrice * qty;
    }
    return total;
  }

  int get _extrasTotal {
    int total = 0;
    for (final item in _extraItems) {
      final qty = _extraQtys[item.id] ?? 1;
      total += item.price * qty;
    }
    return total;
  }

  int get _grandTotal => _ingredientsTotal + _extrasTotal + _deliveryFee;

  String _imageUrl(String img) {
    if (img.startsWith("http")) return img;
    if (img.startsWith("assets/")) return img;
    final path = img.startsWith("/") ? img.substring(1) : img;
    return "${AppConfig.baseUrl}/${Uri.encodeFull(path)}";
  }

  bool _isAssetImage(String img) => img.startsWith("assets/");

  Widget _networkImage(
    String img, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (img.isEmpty) return _imgPlaceholder();
    if (_isAssetImage(img)) {
      return Image.asset(
        img,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _imgPlaceholder(),
      );
    }
    return Image.network(
      _imageUrl(img),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _imgPlaceholder(),
    );
  }

  Widget _imgPlaceholder() {
    return Container(
      color: const Color(0xFFE6EEFF),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Color(0xFF6D7B6C),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFav = context.watch<FavoriteProvider>().isFavorite(_meal.id);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            _buildScrollContent(),
            _buildAppBar(isFav),
            _buildStickyBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isFav) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        decoration: BoxDecoration(
          color: _showTitle ? Colors.white : Colors.transparent,
          boxShadow: _showTitle
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: _buildAppBarContent(isFav),
      ),
    );
  }

  Widget _buildAppBarContent(bool isFav) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _showTitle
                    ? AppTheme.background
                    : Colors.white.withValues(alpha: 0.85),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_rounded, size: 20),
                color: AppTheme.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            ),
            if (_showTitle)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    _meal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            if (!_showTitle) const Spacer(),
            Row(
              children: [
                _buildIconBtn(
                  Icons.share_outlined,
                  _showTitle ? null : 0.85,
                  _onShare,
                ),
                const SizedBox(width: 4),
                _buildIconBtn(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  _showTitle ? null : 0.85,
                  _toggleFavorite,
                  color: isFav ? AppTheme.primaryContainer : null,
                ),
                const SizedBox(width: 4),
                _buildIconBtn(
                  Icons.more_vert,
                  _showTitle ? null : 0.85,
                  _showMoreMenu,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(
    IconData icon,
    double? bgOpacity,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgOpacity != null
              ? Colors.white.withValues(alpha: bgOpacity)
              : Colors.transparent,
        ),
        child: Icon(icon, size: 20, color: color ?? AppTheme.textPrimary),
      ),
    );
  }

  void _onShare() {
    HapticFeedback.mediumImpact();
    Clipboard.setData(
      ClipboardData(text: "Check out ${_meal.name} on My SpiceMarket!"),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Link copied!"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showMoreMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            _menuTile(Icons.bookmark_outline, "Save Recipe"),
            _menuTile(Icons.flag_outlined, "Report Incorrect Info"),
            _menuTile(Icons.bar_chart_rounded, "Nutritional Details"),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildScrollContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) _onScroll();
        return false;
      },
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroImage(),
            _buildMealInfoCard(),
            const SizedBox(height: 12),
            _buildNutritionSection(),
            const SizedBox(height: 12),
            _buildIngredientsSection(),
            const SizedBox(height: 12),
            _buildExtraSection(),
            const SizedBox(height: 12),
            _buildOrderSummary(),
            const SizedBox(height: 12),
            _buildRecommendedSection(),
            const SizedBox(height: 12),
            _buildRelatedSection(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            width: double.infinity,
            child: _networkImage(
              _meal.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _floatingBadge(
                Icons.timer_outlined,
                "${_meal.preparationTime} min",
              ),
              _floatingBadge(Icons.people_outline, "${_meal.servings} serves"),
              _floatingBadge(
                Icons.eco_outlined,
                _meal.categoryName.isNotEmpty ? _meal.categoryName : "Meal",
              ),
              if (_meal.isPopular)
                _floatingBadge(Icons.trending_up, "Popular", filled: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _floatingBadge(IconData icon, String label, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? AppTheme.primary : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: filled ? Colors.white : AppTheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: filled ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  _meal.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "Est. Total",
                    style: TextStyle(fontSize: 11, color: Color(0xFF6D7B6C)),
                  ),
                  const SizedBox(height: 2),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                    child: Text("$_ingredientsTotal FCFA"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _meal.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3D4A3D),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: _openReviewsScreen,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...List.generate(5, (i) {
                    return Icon(
                      i < _averageRating.floor() ? Icons.star : (i < _averageRating.ceil() && _averageRating - i > 0 ? Icons.star_half : Icons.star_border),
                      size: 16,
                      color: const Color(0xFFFFB800),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '—',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (_reviewCount > 0) ...[
                    const SizedBox(width: 4),
                    Text(
                      '($_reviewCount ${_reviewCount == 1 ? 'review' : 'reviews'})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6D7B6C),
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right, size: 16, color: Color(0xFF6D7B6C)),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  void _openReviewsScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealReviewsScreen(
          mealId: _meal.id,
          mealName: _meal.name,
          mealImage: _meal.image.startsWith('http') ? _meal.image : '${AppConfig.baseUrl}/$_meal.image',
          mealDescription: _meal.description,
          mealCategory: _meal.categoryName,
          initialRating: _averageRating,
          initialReviewCount: _reviewCount,
          badge: _meal.isPopular ? 'Popular' : null,
        ),
      ),
    );
  }

  Widget _buildNutritionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Nutritional Overview",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                "per serving",
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _nutritionRing("Calories", "320", "kcal", 0.65),
              _nutritionRing("Protein", "24", "g", 0.55),
              _nutritionRing("Carbs", "42", "g", 0.45),
              _nutritionRing("Fat", "18", "g", 0.35),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dietBadge(
                Icons.eco_outlined,
                "High Protein",
                const Color(0xFF22C55E),
              ),
              const SizedBox(width: 8),
              _dietBadge(
                Icons.whatshot_outlined,
                "Moderate Spice",
                Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nutritionRing(
    String label,
    String value,
    String unit,
    double progress,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 5,
                backgroundColor: const Color(0xFFE6EEFF),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    unit,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6D7B6C),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6D7B6C)),
        ),
      ],
    );
  }

  Widget _dietBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection() {
    return _buildSection(
      title: "Ingredients Required",
      subtitle:
          "${_ingredients.length - _removedIngredientIds.length} of ${_ingredients.length} ingredients — tap quantities to adjust",
      loading: _loadingIngredients,
      error: _ingredientsError,
      onRetry: () {
        setState(() => _loadingIngredients = true);
        _loadIngredients();
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppTheme.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Quantities are recommended defaults. Adjust freely before ordering.",
                    style: TextStyle(fontSize: 12, color: AppTheme.textVariant),
                  ),
                ),
              ],
            ),
          ),
          ..._ingredients
              .where((ing) => !_removedIngredientIds.contains(ing.foodstuffId))
              .map(
                (ing) => _IngredientCard(
                  ingredient: ing,
                  quantity:
                      _ingredientQtys[ing.foodstuffId] ?? ing.quantity.ceil(),
                  imageUrl: _imageUrl(ing.foodstuffImage),
                  onIncrement: () => _updateIngredientQty(ing.foodstuffId, 1),
                  onDecrement: () => _updateIngredientQty(ing.foodstuffId, -1),
                  onRemove: () => _removeIngredient(ing.foodstuffId),
                ),
              ),
          if (_removedIngredientIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "${_removedIngredientIds.length} ingredient(s) removed",
                style: const TextStyle(fontSize: 12, color: Color(0xFF6D7B6C)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtraSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSectionCard(
            child: Column(
              children: [
                Icon(
                  Icons.shopping_basket_outlined,
                  size: 40,
                  color: AppTheme.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Need more groceries?",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Add extra foodstuffs beyond the recipe",
                  style: TextStyle(fontSize: 12, color: Color(0xFF6D7B6C)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _openFoodstuffPicker,
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text("Add Extra Foodstuffs"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_extraItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildSection(
              title: "Additional Items",
              subtitle: "${_extraItems.length} item(s) added",
              child: Column(
                children: _extraItems
                    .map(
                      (item) => _ExtraItemCard(
                        product: item,
                        quantity: _extraQtys[item.id] ?? 1,
                        imageUrl: _imageUrl(item.image),
                        onIncrement: () => _updateExtraQty(item.id, 1),
                        onDecrement: () => _updateExtraQty(item.id, -1),
                        onRemove: () => _removeExtra(item.id),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    final totalIngredients = _ingredients
        .where((i) => !_removedIngredientIds.contains(i.foodstuffId))
        .length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow(
            "Ingredients ($totalIngredients items)",
            "$_ingredientsTotal FCFA",
          ),
          if (_extraItems.isNotEmpty) ...[
            const SizedBox(height: 6),
            _summaryRow(
              "Extra items (${_extraItems.length})",
              "$_extrasTotal FCFA",
            ),
          ],
          const SizedBox(height: 6),
          _summaryRow("Delivery fee", "$_deliveryFee FCFA"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                "$_grandTotal FCFA",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.textVariant),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSection() {
    if (_recommended.isEmpty) return const SizedBox.shrink();
    return _buildSection(
      title: "Recommended Products",
      child: SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _recommended.length,
          separatorBuilder: (_, _) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final product = _recommended[index];
            return _RecommendedCard(
              product: product,
              imageUrl: _imageUrl(product.image),
              onAdd: () {
                setState(() {
                  if (!_extraItems.any((e) => e.id == product.id)) {
                    _extraItems.add(product);
                    _extraQtys[product.id] = 1;
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${product.name} added"),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRelatedSection() {
    if (_loadingRelated) return const SizedBox.shrink();
    if (_relatedMeals.isEmpty) return const SizedBox.shrink();
    return _buildSection(
      title: "Related Meals",
      child: SizedBox(
        height: 200,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _relatedMeals.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final meal = _relatedMeals[index];
            return _RelatedMealCard(
              meal: meal,
              imageUrl: _imageUrl(meal.image),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MealDetailsScreen(meal: meal),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStickyBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: _openFoodstuffPicker,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  "Add Extra",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: ElevatedButton.icon(
                onPressed: _placeOrder,
                icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                label: Text(
                  "Order Now  $_grandTotal FCFA",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _placeOrder() {
    final summaryData = OrderSummaryData.fromMealDetails(
      meal: _meal,
      ingredients: _ingredients,
      ingredientQtys: _ingredientQtys,
      removedIds: _removedIngredientIds,
      extraItems: _extraItems,
      extraQtys: _extraQtys,
      deliveryFee: _deliveryFee,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderSummaryScreen(data: summaryData),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    String? subtitle,
    bool loading = false,
    String? error,
    VoidCallback? onRetry,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6D7B6C),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(strokeWidth: 3)),
            )
          else if (error != null)
            _buildErrorCard(error, onRetry)
          else
            child,
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EEFF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildErrorCard(String message, VoidCallback? onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off, color: Colors.red.shade300, size: 32),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(fontSize: 12, color: Colors.red.shade700),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// INGREDIENT CARD
// =============================================================================
class _IngredientCard extends StatelessWidget {
  final MealIngredient ingredient;
  final int quantity;
  final String imageUrl;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _IngredientCard({
    required this.ingredient,
    required this.quantity,
    required this.imageUrl,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = ingredient.foodstuffPrice * quantity;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF4FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: ingredient.foodstuffImage.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imgFallback(),
                    )
                  : _imgFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.foodstuffName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${ingredient.foodstuffPrice} FCFA / ${ingredient.foodstuffUnit}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6D7B6C),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "In Stock",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.delete_outline,
                size: 16,
                color: Colors.red.shade400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _QuantityControl(
            quantity: quantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              "$subtotal FCFA",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() {
    return Container(
      color: const Color(0xFFE6EEFF),
      child: const Icon(Icons.eco_outlined, size: 20, color: Color(0xFF22C55E)),
    );
  }
}

// =============================================================================
// EXTRA ITEM CARD
// =============================================================================
class _ExtraItemCard extends StatelessWidget {
  final GroceryProduct product;
  final int quantity;
  final String imageUrl;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _ExtraItemCard({
    required this.product,
    required this.quantity,
    required this.imageUrl,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final subtotal = product.price * quantity;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFF4FF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: product.image.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imgFallback(),
                    )
                  : _imgFallback(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${product.price} FCFA / ${product.unit}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6D7B6C),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.close, size: 16, color: Colors.red.shade400),
            ),
          ),
          const SizedBox(width: 8),
          _QuantityControl(
            quantity: quantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              "$subtotal FCFA",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imgFallback() {
    return Container(
      color: const Color(0xFFE6EEFF),
      child: const Icon(
        Icons.inventory_2_outlined,
        size: 20,
        color: Color(0xFF22C55E),
      ),
    );
  }
}

// =============================================================================
// QUANTITY CONTROL
// =============================================================================
class _QuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityControl({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$quantity",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// REVIEW CARD
// =============================================================================
// =============================================================================
// RECOMMENDED PRODUCT CARD
// =============================================================================
class _RecommendedCard extends StatelessWidget {
  final GroceryProduct product;
  final String imageUrl;
  final VoidCallback onAdd;

  const _RecommendedCard({
    required this.product,
    required this.imageUrl,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6EEFF)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            width: double.infinity,
            child: product.image.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _fallback(),
                  )
                : _fallback(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${product.price} FCFA",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: onAdd,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE6EEFF),
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 24,
          color: Color(0xFF22C55E),
        ),
      ),
    );
  }
}

// =============================================================================
// RELATED MEAL CARD
// =============================================================================
class _RelatedMealCard extends StatelessWidget {
  final Product meal;
  final String imageUrl;
  final VoidCallback onTap;

  const _RelatedMealCard({
    required this.meal,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6EEFF)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 100,
              width: double.infinity,
              child: meal.image.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _fallback(),
                    )
                  : _fallback(),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 11,
                        color: Color(0xFF6D7B6C),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${meal.preparationTime} min",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6D7B6C),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.people_outline,
                        size: 11,
                        color: Color(0xFF6D7B6C),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${meal.servings} serves",
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6D7B6C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFE6EEFF),
      child: const Center(
        child: Icon(Icons.restaurant, size: 28, color: Color(0xFF22C55E)),
      ),
    );
  }
}

// =============================================================================
// GROCERY PICKER SCREEN  (for "Add Extra Foodstuffs")
// =============================================================================
class _GroceryPickerScreen extends StatefulWidget {
  const _GroceryPickerScreen();

  @override
  State<_GroceryPickerScreen> createState() => _GroceryPickerScreenState();
}

class _GroceryPickerScreenState extends State<_GroceryPickerScreen> {
  final Set<String> _selectedIds = {};
  List<GroceryProduct> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await GroceryService.fetchProducts();
      if (mounted) {
        setState(() {
          _products = (result['products'] as List)
              .map((e) => GroceryProduct.fromJson(e))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Select Extra Items"),
        actions: [
          TextButton(
            onPressed: _selectedIds.isNotEmpty
                ? () {
                    final selected = _products
                        .where((p) => _selectedIds.contains(p.id))
                        .toList();
                    Navigator.pop(context, selected);
                  }
                : null,
            child: Text(
              "Done (${_selectedIds.length})",
              style: TextStyle(
                color: _selectedIds.isNotEmpty ? AppTheme.primary : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(child: Text("No products available"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final selected = _selectedIds.contains(product.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? AppTheme.primary : Colors.transparent,
                      width: selected ? 2 : 0,
                    ),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: product.image.isNotEmpty
                            ? Image.network(
                                _imageUrl(product.image),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => _imgFallback(),
                              )
                            : _imgFallback(),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "${product.price} FCFA / ${product.unit}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Icon(
                      selected ? Icons.check_circle : Icons.add_circle_outline,
                      color: selected
                          ? AppTheme.primary
                          : const Color(0xFF6D7B6C),
                    ),
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedIds.remove(product.id);
                        } else {
                          _selectedIds.add(product.id);
                        }
                      });
                    },
                  ),
                );
              },
            ),
    );
  }

  String _imageUrl(String img) {
    if (img.startsWith("http")) return img;
    final path = img.startsWith("/") ? img.substring(1) : img;
    return "${AppConfig.baseUrl}/${Uri.encodeFull(path)}";
  }

  Widget _imgFallback() {
    return Container(
      color: const Color(0xFFE6EEFF),
      child: const Center(
        child: Icon(Icons.eco_outlined, size: 20, color: Color(0xFF22C55E)),
      ),
    );
  }
}

