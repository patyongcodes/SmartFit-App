import '../ai_coach/program_calendar.dart';
import 'workout_session.dart';

class StreakCalculator {
  StreakCalculator._();

  static int calculate({
    required List<ScheduledDay> calendar,
    required List<WorkoutSession> sessions,
    required DateTime today,
  }) {
    final sessionDates = sessions.map((s) => DateTime(s.date.year, s.date.month, s.date.day)).toSet();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final pastActiveDays = calendar.where((d) => d.isActive && d.date.isBefore(todayOnly)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    var streak = 0;
    for (final day in pastActiveDays) {
      if (day.template.isRestDay) continue;
      final completed = sessionDates.contains(DateTime(day.date.year, day.date.month, day.date.day));
      if (completed) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}