import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview_plus/device_preview_plus.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/location_provider.dart';
import 'providers/home_provider.dart';
import 'providers/grocery_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/review_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';
import 'providers/notification_settings_provider.dart';
import 'providers/privacy_provider.dart';
import 'providers/security_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/storage_provider.dart';
import 'ai/providers/ai_provider.dart' as ai;
import 'ai/providers/meal_ai_provider.dart';
import 'ai/providers/nutrition_provider.dart';
import 'ai/providers/shopping_provider.dart';
import 'ai/providers/translation_provider.dart';
import 'ai/providers/voice_provider.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/meals/meals_screen.dart';
import 'screens/grocery/grocery_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'ai/screens/ai_assistant_screen.dart';
import 'ai/screens/voice_assistant_screen.dart';
import 'ai/screens/translation_screen.dart';
import 'ai/screens/meal_planner_screen.dart';
import 'ai/screens/budget_planner_screen.dart';
import 'ai/screens/nutrition_screen.dart';
import 'ai/screens/recipe_generator_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'utils/colors.dart';
import 'l10n/app_localizations.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options != null) {
    try {
      await Firebase.initializeApp(options: options);
    } catch (_) {}
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    DevicePreview(
      enabled: kIsWeb && !kReleaseMode,
      builder: (context) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => GroceryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => RatingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => NotificationSettingsProvider()),
        ChangeNotifierProvider(create: (_) => PrivacyProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
        ChangeNotifierProvider(create: (_) => AiSettingsProvider()),
        ChangeNotifierProvider(create: (_) => StorageProvider()),
        ChangeNotifierProvider(create: (_) => ai.AiProvider()),
        ChangeNotifierProvider(create: (_) => MealAiProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => ShoppingProvider()),
        ChangeNotifierProvider(create: (_) => TranslationProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
      ],
      child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _setupFirebaseMessaging();
  }

  void _setupFirebaseMessaging() async {
    final messaging = FirebaseMessaging.instance;

    const settings = NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      badge: AppleNotificationSetting.enabled,
      sound: AppleNotificationSetting.enabled,
    );
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await messaging.getToken();
    if (token != null) {
      try {
        final authService = AuthService();
        await NotificationService.registerFcmToken(token);
      } catch (_) {}
    }

    messaging.onTokenRefresh.listen((token) {
      NotificationService.registerFcmToken(token).catch((_) {});
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null && navigatorKey.currentContext != null) {
        ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
          SnackBar(
            content: Text(notification.body ?? notification.title ?? 'New notification'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                final orderId = message.data['orderId'];
                if (orderId != null && orderId.isNotEmpty) {
                  Navigator.pushNamed(navigatorKey.currentContext!, '/notifications');
                }
              },
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final orderId = message.data['orderId'];
      if (orderId != null && orderId.isNotEmpty && navigatorKey.currentContext != null) {
        Navigator.pushNamed(navigatorKey.currentContext!, '/notifications');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProv = context.watch<LanguageProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My SpiceMarket',
      locale: Locale(langProv.currentLanguage),
      supportedLocales: const [
        Locale('en'), Locale('fr'), Locale('es'), Locale('de'),
        Locale('zh'), Locale('ar'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder: (context, child) {
        return DevicePreview.appBuilder(
          context,
          KeyedSubtree(
            key: ValueKey(langProv.currentLanguage),
            child: child!,
          ),
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onSurface,
          elevation: 0,
          centerTitle: false,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
      routes: {
        '/meals': (_) => const MealsScreen(),
        '/grocery': (_) => const GroceryScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/ai/assistant': (_) => const AiAssistantScreen(),
        '/ai/voice': (_) => const VoiceAssistantScreen(),
        '/ai/translation': (_) => const TranslationScreen(),
        '/ai/meal-planner': (_) => const MealPlannerScreen(),
        '/ai/budget-planner': (_) => const BudgetPlannerScreen(),
        '/ai/nutrition': (_) => const NutritionScreen(),
        '/ai/recipe-generator': (_) => const RecipeGeneratorScreen(),
        '/notifications': (_) => const NotificationsScreen(),
      },
    );
  }
}
