import 'package:shared_preferences/shared_preferences.dart';


class PrefsHelper {
  static const _tokenKey = "auth_token";
  static const _adminIdKey = "admin_id";

  static Future<void> saveAuthData(String token, int adminId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setInt(_adminIdKey, adminId);
    } catch (e) {
      print("[PrefsHelper] Error saving auth data: $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print("[PrefsHelper] Error getting token: $e");
      return null;
    }
  }

  static Future<int?> getAdminId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_adminIdKey);
    } catch (e) {
      print("[PrefsHelper] Error getting adminId: $e");
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_adminIdKey);
    } catch (e) {
      print("[PrefsHelper] Error clearing auth data: $e");
    }
  }
}
