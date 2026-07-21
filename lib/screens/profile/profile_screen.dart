import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/image_picker_service.dart';
import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_screen.dart';

class _C {
  static const background            = Color(0xFFF8F9FF);
  static const surface               = Color(0xFFF8F9FF);
  static const surfaceContLowest     = Color(0xFFFFFFFF);
  static const primary               = Color(0xFF006E2F);
  static const primaryContainer      = Color(0xFF22C55E);
  static const secondaryContainer    = Color(0xFF99F899);
  static const onSurface             = Color(0xFF121C2A);
  static const onSurfaceVariant      = Color(0xFF3D4A3D);
  static const outlineVariant        = Color(0xFFBCCBB9);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadProfile();
    });
  }

  Future<void> _pickAndUploadImage() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<Uint8List>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.t('changeProfilePicture'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _sourceButton(ctx, Icons.photo_library, l10n.t('gallery')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;

    setState(() => _uploading = true);
    try {
      await AuthService.uploadAvatar(picked);
      if (!mounted) return;
      await context.read<AuthProvider>().loadProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.t('profilePictureUpdated'))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.t('failed')}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Widget _sourceButton(BuildContext ctx, IconData icon, String label) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () async {
        try {
          final bytes = await ImagePickerService.pickImage();
          if (!ctx.mounted) return;
          Navigator.pop(ctx, bytes);
        } catch (e) {
          if (!ctx.mounted) return;
          Navigator.pop(ctx, null);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text('${l10n.t('failed')}: $e')),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF006E2F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: const Color(0xFF006E2F)),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _C.background,
      body: Column(
        children: [
          _appBar(user, l10n),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                children: [
                  _profileHeader(user, l10n),
                  const SizedBox(height: 20),
                  _deliveryCard(l10n),
                  const SizedBox(height: 12),
                  _actionsGroup(l10n),
                  const SizedBox(height: 12),
                  _aiFeaturesGroup(l10n),
                  const SizedBox(height: 12),
                  _supportGroup(l10n),
                  const SizedBox(height: 24),
                  _logoutButton(l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar(User user, AppLocalizations l10n) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: _C.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _C.primaryContainer, width: 2),
              ),
              child: ClipOval(child: _avatarWidget(user.avatar, 40)),
            ),
            const SizedBox(width: 8),
            Text("${l10n.t('hello')} ${user.fullName.split(' ').first}",
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _C.primary,
                )),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => _openPlaceholder(l10n.t('notifications'), l10n),
              child: const Icon(Icons.notifications_outlined,
                  color: _C.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileHeader(User user, AppLocalizations l10n) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _viewFullImage(user.avatar),
              child: ClipOval(child: _avatarWidget(user.avatar, 110)),
            ),
            if (_uploading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006E2F),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(user.fullName,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _C.onSurface)),
        const SizedBox(height: 4),
        Text(user.email,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _C.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(user.phone,
            style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: _C.onSurfaceVariant)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _openPlaceholder(l10n.t('editProfile'), l10n),
          icon: const Icon(Icons.edit_outlined, size: 16),
          label: Text(l10n.t('editProfile')),
        ),
      ],
    );
  }

  Widget _deliveryCard(AppLocalizations l10n) {
    return _card(
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: const Icon(Icons.home_outlined),
          title: Text(l10n.t('primaryAddress')),
          subtitle: Text(l10n.t('setYourDeliveryAddress')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openPlaceholder(l10n.t('deliveryAddresses'), l10n),
        ),
      ),
    );
  }

  Widget _actionsGroup(AppLocalizations l10n) {
    return _card(
      child: Column(
        children: [
          _tile(Icons.receipt_long_outlined, l10n.t('myOrders'),
              l10n.t('historyAndTracking'), () => _openPlaceholder(l10n.t('myOrders'), l10n)),
          _divider(),
          _tile(Icons.account_balance_wallet_outlined, l10n.t('paymentMethods'),
              l10n.t('mobileMoneyAndCards'), () => _openPlaceholder(l10n.t('paymentMethods'), l10n)),
          _divider(),
          _tile(Icons.notifications_outlined, l10n.t('notifications'),
              l10n.t('appAlertsAndPromos'), () => _openPlaceholder(l10n.t('notifications'), l10n)),
        ],
      ),
    );
  }

  Widget _aiFeaturesGroup(AppLocalizations l10n) {
    return _card(
      child: Column(
        children: [
          _tile(Icons.auto_awesome, l10n.t('aiAssistant'),
              l10n.t('aiAssistantDesc'), () => Navigator.pushNamed(context, '/ai/assistant')),
          _divider(),
          _tile(Icons.menu_book, l10n.t('recipeGenerator'),
              l10n.t('recipeGeneratorDesc'), () => Navigator.pushNamed(context, '/ai/recipe-generator')),
          _divider(),
          _tile(Icons.restaurant_menu, l10n.t('mealPlanner'),
              l10n.t('mealPlannerDesc'), () => Navigator.pushNamed(context, '/ai/meal-planner')),
          _divider(),
          _tile(Icons.account_balance_wallet, l10n.t('budgetPlanner'),
              l10n.t('budgetPlannerDesc'), () => Navigator.pushNamed(context, '/ai/budget-planner')),
          _divider(),
          _tile(Icons.health_and_safety, l10n.t('nutritionAdvisor'),
              l10n.t('nutritionDesc'), () => Navigator.pushNamed(context, '/ai/nutrition')),
          _divider(),
          _tile(Icons.mic, l10n.t('voiceAssistant'),
              l10n.t('voiceAssistantDesc'), () => Navigator.pushNamed(context, '/ai/voice')),
          _divider(),
          _tile(Icons.translate, l10n.t('translation'),
              l10n.t('translationDesc'), () => Navigator.pushNamed(context, '/ai/translation')),
        ],
      ),
    );
  }

  Widget _supportGroup(AppLocalizations l10n) {
    return _card(
      child: Column(
        children: [
          _tile(Icons.help_outline, l10n.t('helpAndSupport'), null,
                  () => _openPlaceholder(l10n.t('helpAndSupport'), l10n)),
          _divider(),
          _tile(Icons.settings_outlined, l10n.t('settings'), null,
                  () => Navigator.pushNamed(context, '/settings')),
          _divider(),
          _tile(Icons.info_outline, l10n.t('aboutMySpicemarket'),
              "Version 2.4.0 (Fresh Release)",
                  () => _openPlaceholder(l10n.t('aboutMySpicemarket'), l10n)),
        ],
      ),
    );
  }

  Widget _logoutButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout_rounded),
      label: Text(l10n.t('logout')),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _C.surfaceContLowest,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _C.outlineVariant),
    ),
    child: child,
  );

  Widget _tile(
      IconData icon, String title, String? subtitle, VoidCallback onTap) =>
      Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: _C.primary),
          title: Text(title),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
      );

  Widget _divider() => Divider(color: _C.outlineVariant);

  void _viewFullImage(String url) {
    if (url.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final fullUrl = url.startsWith('http') ? url : '${AppConfig.baseUrl}$url';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Image.network(
              fullUrl,
              fit: BoxFit.contain,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : const CircularProgressIndicator(color: Colors.white),
              errorBuilder: (_, _, _) => Text(l10n.t('failedToLoadImage'), style: const TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _avatarWidget(String url, double size) {
    if (url.isNotEmpty) {
      final fullUrl = url.startsWith('http') ? url : '${AppConfig.baseUrl}$url';
      return Image.network(fullUrl,
          width: size, height: size, fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _avatarFallback(size));
    }
    return _avatarFallback(size);
  }

  Widget _avatarFallback(double size) => Container(
    width: size,
    height: size,
    color: _C.secondaryContainer,
    child: Icon(Icons.person, color: _C.primary, size: size * 0.5),
  );

  void _openPlaceholder(String title, AppLocalizations l10n) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: Center(child: Text(l10n.t('notifications'))),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Provider.of<AuthProvider>(context, listen: false).clearUser();
    Provider.of<FavoriteProvider>(context, listen: false).clear();
    Provider.of<CartProvider>(context, listen: false).clear();
    Provider.of<OrderProvider>(context, listen: false).clear();
    Provider.of<NotificationProvider>(context, listen: false).clear();
    Provider.of<ProfileProvider>(context, listen: false).clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
