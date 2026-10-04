import 'package:shared_preferences/shared_preferences.dart';

class PreferencesRepository {
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _notificationsEnabledKey = 'notificationsEnabled';

  Future<void> setDarkMode(bool isDarkMode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, isDarkMode);
  }

  Future<bool> getDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isDarkModeKey) ?? false;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }
}
