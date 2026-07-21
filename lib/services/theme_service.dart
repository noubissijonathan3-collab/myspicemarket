import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static Future<List<Map<String, String>>> getThemes() async {
    return [
      {'mode': 'light', 'displayName': 'Light', 'description': 'Light theme for bright environments'},
      {'mode': 'dark', 'displayName': 'Dark', 'description': 'Dark theme for low-light environments'},
      {'mode': 'system', 'displayName': 'System', 'description': 'Follows your device theme'},
    ];
  }

  static Future<void> applyTheme(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
  }
}
