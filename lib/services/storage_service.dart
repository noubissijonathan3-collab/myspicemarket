import '../models/storage_settings_model.dart';
import 'settings_service.dart';

class StorageService {
  static Future<StorageSettingsModel> getStorageInfo() async {
    final settings = await SettingsService.getSettings();
    return settings.storage;
  }

  static Future<Map<String, dynamic>> clearCache() async {
    return await SettingsService.clearCache();
  }

  static Future<void> clearDownloadedBanners() async {
    // Placeholder for clearing downloaded banners
  }

  static Future<void> clearOfflineTranslations() async {
    // Placeholder for clearing offline translations
  }
}
