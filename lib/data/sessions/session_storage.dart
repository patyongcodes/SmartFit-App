import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_session.dart';

class SessionStorage {
  SessionStorage._();

  static const _kSessions = 'workout_sessions';

  static Future<void> saveSession(WorkoutSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();
    sessions.add(session);
    final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
    await prefs.setString(_kSessions, encoded);
  }

  static Future<List<WorkoutSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessions);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.whereType<Map<String, dynamic>>().map(WorkoutSession.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> hasSessionOnDate(DateTime date) async {
    final sessions = await getAllSessions();
    return sessions.any((s) => s.date.year == date.year && s.date.month == date.month && s.date.day == date.day);
  }
}