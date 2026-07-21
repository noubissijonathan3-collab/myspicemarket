import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_settings_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../providers/security_provider.dart';
import '../../providers/ai_provider.dart';
import '../../providers/storage_provider.dart';
import '../../models/language_model.dart';
import '../../services/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../auth/login_screen.dart';

class _C {
  static const background = Color(0xFFF8F9FF);
  static const surface = Color(0xFFF8F9FF);
  static const surfaceContLowest = Color(0xFFFFFFFF);
  static const primary = Color(0xFF006E2F);
  static const primaryContainer = Color(0xFF22C55E);
  static const secondaryContainer = Color(0xFF99F899);
  static const onSurface = Color(0xFF121C2A);
  static const onSurfaceVariant = Color(0xFF3D4A3D);
  static const outlineVariant = Color(0xFFBCCBB9);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _l10n = AppLocalizations.of(context);
  }

  Future<void> _loadSettings() async {
    final prov = context.read<SettingsProvider>();
    if (prov.settings == null) await prov.loadSettings();
    final s = prov.settings;
    if (s != null && mounted) {
      context.read<ThemeProvider>().loadFromSettings(s.theme);
      context.read<LanguageProvider>().loadFromSettings(s.language);
      context.read<NotificationSettingsProvider>().loadFromSettings(s.notifications);
      context.read<PrivacyProvider>().loadFromSettings(s.privacy);
      context.read<SecurityProvider>().loadFromSettings(s.security);
      context.read<AiSettingsProvider>().loadFromSettings(s.ai);
      context.read<StorageProvider>().loadFromSettings(s.storage);
    }
  }

  @override
  Widget build(BuildContext context) {
    _l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: _C.background,
      body: Column(
        children: [
          _appBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              child: Column(
                children: [
                  _accountCard(),
                  const SizedBox(height: 12),
                  _appearanceCard(),
                  const SizedBox(height: 12),
                  _languageCard(),
                  const SizedBox(height: 12),
                  _notificationsCard(),
                  const SizedBox(height: 12),
                  _privacyCard(),
                  const SizedBox(height: 12),
                  _aiCard(),
                  const SizedBox(height: 12),
                  _storageCard(),
                  const SizedBox(height: 12),
                  _helpCard(),
                  const SizedBox(height: 24),
                  _logoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: _C.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _C.primaryContainer, width: 2),
              ),
              child: ClipOval(
                child: _avatarWidget(context.read<AuthProvider>().user?.avatar ?? '', 40),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _l10n.t('settings'),
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: _C.primary,
              ),
            ),
            const Spacer(),
            InkWell(
              borderRadius: BorderRadius.circular(99),
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close, color: _C.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarWidget(String url, double size) {
    if (url.isNotEmpty) {
      final fullUrl = url.startsWith('http') ? url : '${AppConfig.baseUrl}$url';
      return Image.network(fullUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
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

  Widget _accountCard() {
    final user = context.watch<AuthProvider>().user;
    return _card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _viewFullImage(user?.avatar ?? ''),
                  child: ClipOval(child: _avatarWidget(user?.avatar ?? '', 56)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? _l10n.t('user'),
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _C.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(fontSize: 13, color: _C.onSurfaceVariant),
                      ),
                      if ((user?.phone ?? '').isNotEmpty)
                        Text(
                          user!.phone,
                          style: const TextStyle(fontSize: 13, color: _C.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          _tile(Icons.person_outline, _l10n.t('editProfile'), null, () {
            Navigator.pushReplacementNamed(context, '/profile');
          }),
          _divider(),
          _tile(Icons.lock_outline, _l10n.t('changePassword'), _l10n.t('updateYourPassword'), () {}),
          _divider(),
          _tile(Icons.payment_outlined, _l10n.t('paymentMethods'), _l10n.t('mobileMoneyAndCards'), () {}),
          _divider(),
          _tile(Icons.location_on_outlined, _l10n.t('deliveryAddresses'), _l10n.t('manageSavedAddresses'), () {}),
        ],
      ),
    );
  }

  Widget _appearanceCard() {
    final prov = context.watch<ThemeProvider>();
    final modes = {'system': _l10n.t('system'), 'light': _l10n.t('light'), 'dark': _l10n.t('dark')};
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.palette_outlined, _l10n.t('appearance')),
          _divider(),
          ...modes.entries.map((e) => _radioTile(e.value, prov.themeMode == e.key, () => prov.setThemeMode(e.key))),
        ],
      ),
    );
  }

  Widget _languageCard() {
    final prov = context.watch<LanguageProvider>();
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.translate, _l10n.t('languageTranslation')),
          _divider(),
          _tile(Icons.language, _l10n.t('language'), prov.languages.isEmpty ? 'English' : prov.languages.firstWhere((l) => l.code == prov.currentLanguage, orElse: () => prov.languages.isNotEmpty ? prov.languages.first : LanguageModel(code: 'en', name: 'English', nativeName: 'English')).name, () => _showLanguagePicker(prov)),
          _divider(),
          _switchTile(Icons.wifi_tethering, _l10n.t('autoDetect'), prov.autoDetect, (v) => prov.setAutoDetect(v)),
          _divider(),
          _switchTile(Icons.dynamic_feed, _l10n.t('dynamicTranslation'), prov.translateDynamic, (v) => prov.setTranslateDynamic(v)),
          _divider(),
          _switchTile(Icons.chat, _l10n.t('chatTranslation'), prov.translateChat, (v) => prov.setTranslateChat(v)),
        ],
      ),
    );
  }

  Widget _notificationsCard() {
    final prov = context.watch<NotificationSettingsProvider>();
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.notifications_outlined, _l10n.t('notifications')),
          _divider(),
          _switchTile(Icons.shopping_bag_outlined, _l10n.t('orderUpdates'), prov.orderUpdates, (v) => prov.setOrderUpdates(v)),
          _divider(),
          _switchTile(Icons.local_offer_outlined, _l10n.t('promotionsDiscounts'), prov.promotions, (v) => prov.setPromotions(v)),
          _divider(),
          _switchTile(Icons.local_shipping_outlined, _l10n.t('deliveryUpdates'), prov.deliveryUpdates, (v) => prov.setDeliveryUpdates(v)),
          _divider(),
          _switchTile(Icons.shield_outlined, _l10n.t('securityAlerts'), prov.securityAlerts, (v) => prov.setSecurityAlerts(v)),
          _divider(),
          _switchTile(Icons.new_releases_outlined, _l10n.t('newProducts'), prov.newProducts, (v) => prov.setNewProducts(v)),
        ],
      ),
    );
  }

  Widget _privacyCard() {
    final priv = context.watch<PrivacyProvider>();
    final sec = context.watch<SecurityProvider>();
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.shield_outlined, _l10n.t('privacySecurity')),
          _divider(),
          _switchTile(Icons.share_outlined, _l10n.t('dataSharing'), priv.dataSharing, (v) => priv.setDataSharing(v)),
          _divider(),
          _switchTile(Icons.analytics_outlined, _l10n.t('analytics'), priv.analytics, (v) => priv.setAnalytics(v)),
          _divider(),
          _switchTile(Icons.cookie_outlined, _l10n.t('cookieConsent'), priv.cookieConsent, (v) => priv.setCookieConsent(v)),
          _divider(),
          _switchTile(Icons.fingerprint, _l10n.t('biometricAuth'), sec.biometricAuth, (v) => sec.setBiometricAuth(v)),
        ],
      ),
    );
  }

  Widget _aiCard() {
    final prov = context.watch<AiSettingsProvider>();
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.auto_awesome, _l10n.t('aiFeatures')),
          _divider(),
          _switchTile(Icons.restaurant_menu, _l10n.t('cookingAssistant'), prov.cookingAssistant, (v) => prov.setCookingAssistant(v)),
          _divider(),
          _switchTile(Icons.search, _l10n.t('smartSearch'), prov.smartSearch, (v) => prov.setSmartSearch(v)),
          _divider(),
          _switchTile(Icons.thumb_up_outlined, _l10n.t('recommendations'), prov.recommendations, (v) => prov.setRecommendations(v)),
          _divider(),
          _switchTile(Icons.calendar_month_outlined, _l10n.t('weeklyMealPlanner'), prov.weeklyPlanner, (v) => prov.setWeeklyPlanner(v)),
          _divider(),
          _switchTile(Icons.monitor_heart_outlined, _l10n.t('nutritionAdvisor'), prov.nutritionAdvisor, (v) => prov.setNutritionAdvisor(v)),
        ],
      ),
    );
  }

  Widget _storageCard() {
    final prov = context.watch<StorageProvider>();
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.storage_outlined, _l10n.t('storage')),
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.folder_outlined, color: _C.primary, size: 22),
                const SizedBox(width: 14),
                Expanded(child: Text(_l10n.t('cacheSize'), style: const TextStyle(fontSize: 15, color: _C.onSurface))),
                Text(prov.formattedCacheSize, style: const TextStyle(fontSize: 14, color: _C.onSurfaceVariant)),
              ],
            ),
          ),
          _divider(),
          _tile(Icons.delete_outline, _l10n.t('clearCache'), null, () => prov.clearCache()),
        ],
      ),
    );
  }

  Widget _helpCard() {
    return _card(
      child: Column(
        children: [
          _sectionHeader(Icons.help_outline, _l10n.t('helpAbout')),
          _divider(),
          _tile(Icons.quiz_outlined, _l10n.t('faq'), _l10n.t('frequentlyAskedQuestions'), () {}),
          _divider(),
          _tile(Icons.headset_mic_outlined, _l10n.t('contactSupport'), _l10n.t('getHelpFromOurTeam'), () {}),
          _divider(),
          _tile(Icons.description_outlined, _l10n.t('termsConditions'), _l10n.t('appUsageTerms'), () {}),
          _divider(),
          _tile(Icons.privacy_tip_outlined, _l10n.t('privacyPolicy'), _l10n.t('howWeHandleYourData'), () {}),
          _divider(),
          _tile(Icons.info_outline, _l10n.t('about'), 'Version 2.4.0', () {}),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return OutlinedButton.icon(
      onPressed: _logout,
      icon: const Icon(Icons.logout_rounded),
      label: Text(_l10n.t('logout')),
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

  Widget _sectionHeader(IconData icon, String title) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: _C.primary, size: 20),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _C.primary)),
          ],
        ),
      );

  Widget _tile(IconData icon, String title, String? subtitle, VoidCallback onTap) =>
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

  Widget _switchTile(IconData icon, String title, bool value, ValueChanged<bool> onChanged) =>
      Material(
        color: Colors.transparent,
        child: SwitchListTile(
          secondary: Icon(icon, color: _C.primary),
          title: Text(title),
          value: value,
          onChanged: onChanged,
          activeTrackColor: _C.primary,
        ),
      );

  Widget _radioTile(String label, bool selected, VoidCallback onTap) => Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            color: selected ? _C.primary : _C.onSurfaceVariant,
          ),
          title: Text(label),
          onTap: onTap,
        ),
      );

  Widget _divider() => Divider(color: _C.outlineVariant, height: 1);

  void _viewFullImage(String url) {
    if (url.isEmpty) return;
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
              errorBuilder: (_, _, _) =>
                  const Text('Failed to load image', style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker(LanguageProvider prov) {
    if (prov.languages.isEmpty) {
      prov.loadLanguages();
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer<LanguageProvider>(
          builder: (_, lp, _) {
            final items = lp.languages;
            if (items.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            return SizedBox(
              height: 400,
              child: Column(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(_l10n.t('selectLanguage'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final lang = items[i];
                        final selected = lang.code == lp.currentLanguage;
                        return ListTile(
                          leading: Icon(
                            selected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: selected ? _C.primary : null,
                          ),
                          title: Text(lang.name),
                          onTap: () {
                            lp.setLanguage(lang.code);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    context.read<AuthProvider>().clearUser();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }
}
