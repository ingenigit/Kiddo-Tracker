import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  // Set a value
  static Future<void> setUserLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", value);
  }

  // Get a value
  static Future<bool?> getUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("loggedIn");
  }

  // Example for int
  static Future<void> setIntValue(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("", value);
  }

  static Future<int?> getIntValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }
}