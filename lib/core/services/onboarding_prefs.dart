import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPrefs {
  OnboardingPrefs._();

  static const _kOnboardingComplete = 'onboarding_complete';
  static const _kUserName = 'user_name';

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOnboardingComplete) ?? false;
  }

  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingComplete, true);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }
}