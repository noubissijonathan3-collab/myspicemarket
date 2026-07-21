import '../models/delivery_preferences_model.dart';
import 'settings_service.dart';

class DeliveryPreferencesService {
  static Future<void> updateDeliveryPreferences(DeliveryPreferencesModel prefs) async {
    await SettingsService.updateDelivery(prefs);
  }
}
