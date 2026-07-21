import 'auth_service.dart';

class SessionService {
  static Future<bool> isLoggedIn() => AuthService.isLoggedIn();
  static Future<String?> getToken() => AuthService.getToken();
  static Future<void> logout() => AuthService.logout();
}
