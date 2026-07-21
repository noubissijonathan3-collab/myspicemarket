import '../models/privacy_settings_model.dart';
import 'settings_service.dart';

class PrivacyService {
  static Future<void> updatePrivacySettings(PrivacySettingsModel settings) async {
    await SettingsService.updatePrivacy(settings);
  }
}
