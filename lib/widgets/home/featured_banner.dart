import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../config/app_config.dart';
import 'banner_indicator.dart';

class FeaturedBanner extends StatefulWidget {
  const FeaturedBanner({super.key});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  late final PageController _controller;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      final banners = context.read<HomeProvider>().banners;
      if (banners.isEmpty) return;
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % banners.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = context.watch<HomeProvider>().banners;
    final isLoading = context.watch<HomeProvider>().isLoading;

    if (isLoading && banners.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 20),
        child: SizedBox(height: 170, child: Center(child: CircularProgressIndicator())),
      );
    }

    if (banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          SizedBox(
            height: AppDimensions.bannerHeight,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppDimensions.containerMargin),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusXxl),
                      gradient: LinearGradient(
                        colors: [
                          _parseColor(banner.backgroundColor).withValues(alpha: 0.7),
                          _parseColor(banner.backgroundColor).withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                                child: const Text('Weekly Offer', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                banner.title,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner.subtitle,
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Text('Shop Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        banner.image.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _imageUrl(banner.image),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(Icons.eco, color: Colors.white.withValues(alpha: 0.2), size: 64),
                                ),
                              )
                            : Icon(Icons.eco, color: Colors.white.withValues(alpha: 0.2), size: 64),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          BannerIndicator(
            count: banners.length,
            currentIndex: _currentPage,
          ),
        ],
      ),
    );
  }
  String _imageUrl(String img) {
    if (img.startsWith("http")) return img;
    final path = img.startsWith("/") ? img.substring(1) : img;
    return "${AppConfig.baseUrl}/${Uri.encodeFull(path)}";
  }
}

Color _parseColor(String hex) {
  if (hex.isEmpty) return AppColors.primary;
  final sanitized = hex.replaceFirst('#', '');
  if (sanitized.length != 6) return AppColors.primary;
  final value = int.tryParse(sanitized, radix: 16);
  return value != null ? Color(0xFF000000 | value) : AppColors.primary;
}
