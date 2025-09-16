import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper {
  //constructor
  SharedPreferenceHelper._();
  // logged in
  static Future<void> setUserLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("loggedIn", value);
  }

  static Future<bool?> getUserLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("loggedIn");
  }

  // user Number
  static Future<void> setUserNumber(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userNumber", value);
  }

  static Future<String?> getUserNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userNumber");
  }

  //user session id
  static Future<void> setUserSessionId(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userSessionId", value);
  }

  static Future<String?> getUserSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userSessionId");
  }
}