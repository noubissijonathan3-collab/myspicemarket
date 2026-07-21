import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/favorite_provider.dart';
import '../profile/profile_screen.dart';
import '../meals/meals_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/home/search_section.dart';
import '../../widgets/home/home_menu_cards.dart';
import '../../widgets/home/featured_banner.dart';
import '../../widgets/home/why_choose_section.dart';
import '../../widgets/home/customer_reviews_section.dart';
import '../../widgets/home/how_it_works_section.dart';
import '../../widgets/home/support_section.dart';
import '../../widgets/home/recommended_section.dart';
import '../../widgets/home/recently_viewed_section.dart';
import '../../widgets/home/bottom_navigation.dart';
import '../../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await Future.wait([
      context.read<UserProvider>().loadProfile(),
      context.read<HomeProvider>().loadHomeData(),
      context.read<CartProvider>().loadCart(),
      context.read<NotificationProvider>().loadNotifications(),
      context.read<FavoriteProvider>().loadFavorites(),
    ]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = _buildScreens();

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) {
            _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          }
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      _buildHomeContent(),
      const MealsScreen(),
      _buildCartScreen(),
      _buildOrdersScreen(),
      const ProfileScreen(),
    ];
  }

  Widget _buildCartScreen() {
    return const CartScreen();
  }

  Widget _buildOrdersScreen() {
    return const OrdersScreen();
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SearchSection(),
              const SizedBox(height: 8),
              HomeMenuCards(
                onMealsTap: () => setState(() => _currentIndex = 1),
                onGroceriesTap: () => Navigator.pushNamed(context, '/grocery'),
              ),
              const SizedBox(height: 8),
              const FeaturedBanner(),
              const RecommendedSection(),
              const RecentlyViewedSection(),
              const WhyChooseSection(),
              const CustomerReviewsSection(),
              const HowItWorksSection(),
              const SupportSection(),
              const SizedBox(height: 112),
            ],
          ),
        ),
      ),
    );
  }
}
