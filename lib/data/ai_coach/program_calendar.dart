import 'ai_coach_models.dart';

class ScheduledDay {
  final DateTime date;
  final WorkoutDay template;
  final bool isBeforeStart;
  final bool isAfterEnd;

  ScheduledDay({
    required this.date,
    required this.template,
    required this.isBeforeStart,
    required this.isAfterEnd,
  });

  bool get isActive => !isBeforeStart && !isAfterEnd;

  bool isSameDate(DateTime other) =>
      date.year == other.year && date.month == other.month && date.day == other.day;
}

class ProgramCalendar {
  ProgramCalendar._();

  /// Builds a full calendar from the Monday of the program's start week
  /// through the Sunday of the program's end week, mapping each calendar
  /// date to its Mon-Sun template entry. Days before the actual start date
  /// or after the planned end date are flagged so the UI can mute them.
  static List<ScheduledDay> generate(AiCoachResult plan) {
    final start = _dateOnly(plan.startDate);
    final end = _dateOnly(plan.endDate);

    final firstMonday = start.subtract(Duration(days: start.weekday - 1));
    final lastSunday = end.add(Duration(days: DateTime.sunday - end.weekday));

    final days = <ScheduledDay>[];
    var current = firstMonday;

    while (!current.isAfter(lastSunday)) {
      final weekdayIndex = current.weekday - 1;
      final template = weekdayIndex < plan.weeklySchedule.length
          ? plan.weeklySchedule[weekdayIndex]
          : plan.weeklySchedule.isNotEmpty
              ? plan.weeklySchedule.first
              : WorkoutDay(day: '', isRestDay: true, targetMuscles: [], exercises: [], meals: []);

      days.add(ScheduledDay(
        date: current,
        template: template,
        isBeforeStart: current.isBefore(start),
        isAfterEnd: current.isAfter(end),
      ));
      current = current.add(const Duration(days: 1));
    }
    return days;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static List<List<ScheduledDay>> groupByWeek(List<ScheduledDay> days) {
    final weeks = <List<ScheduledDay>>[];
    for (var i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7 > days.length ? days.length : i + 7));
    }
    return weeks;
  }
}