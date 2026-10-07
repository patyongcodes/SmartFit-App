import 'dart:math';
import '../ai_coach/ai_coach_models.dart';
import 'exercise_database.dart';

/// Deterministic 7-day scheduling algorithm — see thesis documentation
/// section 5 for the full rule set and rationale.
class WorkoutScheduler {
  WorkoutScheduler._();

  static const _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  static const _restDayIndices = {2, 6}; // Wed, Sun
  static const _workoutDayIndices = [0, 1, 3, 4, 5]; // Mon, Tue, Thu, Fri, Sat
  static const _prevAdjacentSlot = {1: 0, 3: 2, 4: 3};

  static List<WorkoutDay> generateSchedule(List<String> muscles) {
    final slotMuscles = _distributeMuscles(muscles);
    final occurrenceCount = <String, int>{};
    final schedule = List<WorkoutDay?>.filled(7, null);

    for (final restIndex in _restDayIndices) {
      schedule[restIndex] = WorkoutDay(
        day: _dayNames[restIndex],
        isRestDay: true,
        targetMuscles: const [],
        exercises: const [],
        meals: const [],
      );
    }

    for (var slot = 0; slot < _workoutDayIndices.length; slot++) {
      final dayIndex = _workoutDayIndices[slot];
      final muscle = slotMuscles[slot];

      if (muscle == null) {
        schedule[dayIndex] = WorkoutDay(
          day: _dayNames[dayIndex],
          isRestDay: false,
          targetMuscles: const [],
          exercises: const [],
          meals: const [],
        );
        continue;
      }

      final occurrence = occurrenceCount[muscle] ?? 0;
      occurrenceCount[muscle] = occurrence + 1;

      schedule[dayIndex] = WorkoutDay(
        day: _dayNames[dayIndex],
        isRestDay: false,
        targetMuscles: [muscle],
        exercises: _pickExercises(muscle, occurrence),
        meals: const [],
      );
    }

    return schedule.whereType<WorkoutDay>().toList();
  }

  static List<String?> _distributeMuscles(List<String> muscles) {
    final slots = List<String?>.filled(5, null);
    if (muscles.isEmpty) return slots;

    if (muscles.length == 1) {
      slots[0] = muscles[0];
      slots[2] = muscles[0];
      slots[4] = muscles[0];
      return slots;
    }

    var cursor = 0;
    for (var i = 0; i < 5; i++) {
      var candidate = muscles[cursor % muscles.length];
      final prevSlot = _prevAdjacentSlot[i];
      if (prevSlot != null && slots[prevSlot] == candidate) {
        cursor++;
        candidate = muscles[cursor % muscles.length];
      }
      slots[i] = candidate;
      cursor++;
    }
    return slots;
  }

  static List<ExerciseRecommendation> _pickExercises(String muscle, int occurrence) {
    final pool = ExerciseDatabase.byMuscleGroup[muscle] ?? const [];
    if (pool.isEmpty) return const [];

    final count = min(3, pool.length);
    final startOffset = (occurrence * 2) % pool.length;
    final picked = <ExerciseTemplate>[];
    for (var i = 0; i < count; i++) {
      picked.add(pool[(startOffset + i) % pool.length]);
    }

    return picked
        .map((t) => ExerciseRecommendation(
              name: t.name,
              description: t.description,
              muscleGroup: t.muscleGroup,
              sets: 3,
              reps: 10,
            ))
        .toList();
  }
}