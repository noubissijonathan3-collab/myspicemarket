class AppConstants {
  AppConstants._();

  static const String appName = 'My SpiceMarket';
  static const String currency = 'FCFA';
  static const double deliveryFeeThreshold = 5000;
  static const double defaultDeliveryFee = 1500;
  static const int freeDeliveryThreshold = 5000;
  static const int searchDebounceMs = 300;
  static const int bannerAutoSlideSeconds = 5;
  static const int maxRecentlyViewed = 50;
  static const int pageSize = 20;

  static const String prefToken = 'auth_token';
  static const String prefUser = 'user_data';
  static const String prefCart = 'cart_data';
  static const String prefRecentSearches = 'recent_searches';
}
