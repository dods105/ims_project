import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyUserId = 'user_id';
  static const _keyUserName = 'username';

  static Future<void> saveSession(int userId, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setString(_keyUserName, username);
  }

  static Future<int?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
  }
}
