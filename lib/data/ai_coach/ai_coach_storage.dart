import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_coach_models.dart';

class AiCoachStorage {
  AiCoachStorage._();

  static const _kSavedPlan = 'ai_coach_saved_plan';

  static Future<void> savePlan(AiCoachResult result) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedPlan, jsonEncode(result.toJson()));
  }

  static Future<AiCoachResult?> loadPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSavedPlan);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AiCoachResult.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}