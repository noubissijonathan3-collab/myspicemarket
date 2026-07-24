import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/call_service.dart';
import '../call_screen.dart';
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
  StreamSubscription<IncomingCallData>? _incomingCallSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _listenIncomingCalls();
  }

  void _listenIncomingCalls() {
    _incomingCallSub = CallService.incomingCallStream.listen((call) {
      if (!mounted) return;
      _showIncomingCallDialog(call);
    });
  }

  void _showIncomingCallDialog(IncomingCallData call) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF198754), shape: BoxShape.circle),
              child: const Icon(Icons.phone, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Incoming Call')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                call.callerName.isNotEmpty ? call.callerName[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(call.callerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (call.orderId != null)
              Text('Order #${call.orderId!.substring(0, 8)}', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              CallService.rejectCall(call.callerId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(backgroundColor: Colors.red.shade50, foregroundColor: Colors.red),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    targetUserId: call.callerId,
                    targetName: call.callerName,
                    orderId: call.orderId ?? '',
                    isIncoming: true,
                    incomingCallData: call,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF198754), foregroundColor: Colors.white),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    final notifProvider = context.read<NotificationProvider>();
    notifProvider.attachRealtimeListeners(auth.notificationStream, auth.unreadCountStream);
    await Future.wait([
      context.read<UserProvider>().loadProfile(),
      context.read<HomeProvider>().loadHomeData(),
      context.read<CartProvider>().loadCart(),
      notifProvider.loadNotifications(refresh: true),
      context.read<FavoriteProvider>().loadFavorites(),
    ]);
  }

  @override
  void dispose() {
    _incomingCallSub?.cancel();
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
