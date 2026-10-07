class AiCoachResult {
  final DateTime startDate;
  final int originalTimelineMonths;
  final int adjustedTimelineMonths;
  final String aiNote;
  final int dailyCalories;
  final String sleepRecommendation;
  final double bodyFatPercent;
  final String bodyFatCategory;
  final int proteinG;
  final int carbG;
  final int fatG;
  final List<WorkoutDay> weeklySchedule;

  DateTime get endDate => DateTime(startDate.year, startDate.month + adjustedTimelineMonths, startDate.day);

  AiCoachResult({
    required this.startDate,
    required this.originalTimelineMonths,
    required this.adjustedTimelineMonths,
    required this.aiNote,
    required this.dailyCalories,
    required this.sleepRecommendation,
    this.bodyFatPercent = 0,
    this.bodyFatCategory = '',
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
    required this.weeklySchedule,
  });

  factory AiCoachResult.fromJson(Map<String, dynamic> json) {
    return AiCoachResult(
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate'] as String) : DateTime.now(),
      originalTimelineMonths: (json['originalTimelineMonths'] as num?)?.toInt() ?? 0,
      adjustedTimelineMonths: (json['adjustedTimelineMonths'] as num?)?.toInt() ?? 0,
      aiNote: json['aiNote'] as String? ?? '',
      dailyCalories: (json['dailyCalories'] as num?)?.toInt() ?? 0,
      sleepRecommendation: json['sleepRecommendation'] as String? ?? '7–9 hours per night',
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble() ?? 0,
      bodyFatCategory: json['bodyFatCategory'] as String? ?? '',
      proteinG: (json['proteinG'] as num?)?.toInt() ?? 0,
      carbG: (json['carbG'] as num?)?.toInt() ?? 0,
      fatG: (json['fatG'] as num?)?.toInt() ?? 0,
      weeklySchedule: json['weeklySchedule'] is List
          ? (json['weeklySchedule'] as List).whereType<Map<String, dynamic>>().map(WorkoutDay.fromJson).toList()
          : <WorkoutDay>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'originalTimelineMonths': originalTimelineMonths,
      'adjustedTimelineMonths': adjustedTimelineMonths,
      'aiNote': aiNote,
      'dailyCalories': dailyCalories,
      'sleepRecommendation': sleepRecommendation,
      'bodyFatPercent': bodyFatPercent,
      'bodyFatCategory': bodyFatCategory,
      'proteinG': proteinG,
      'carbG': carbG,
      'fatG': fatG,
      'weeklySchedule': weeklySchedule.map((d) => d.toJson()).toList(),
    };
  }
}

class MealItem {
  final String name;
  final String description;
  final int calories;

  MealItem({required this.name, required this.description, required this.calories});

  factory MealItem.fromJson(Map<String, dynamic> json) {
    return MealItem(
      name: json['name'] as String? ?? 'Meal',
      description: json['description'] as String? ?? '',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'description': description, 'calories': calories};
}

class WorkoutDay {
  final String day;
  final bool isRestDay;
  final List<String> targetMuscles;
  final List<ExerciseRecommendation> exercises;
  final List<MealItem> meals;

  WorkoutDay({
    required this.day,
    required this.isRestDay,
    required this.targetMuscles,
    required this.exercises,
    required this.meals,
  });

  factory WorkoutDay.fromJson(Map<String, dynamic> json) {
    return WorkoutDay(
      day: json['day'] as String? ?? '',
      isRestDay: json['isRestDay'] as bool? ?? false,
      targetMuscles: json['targetMuscles'] is List
          ? (json['targetMuscles'] as List).whereType<String>().toList()
          : <String>[],
      exercises: json['exercises'] is List
          ? (json['exercises'] as List).whereType<Map<String, dynamic>>().map(ExerciseRecommendation.fromJson).toList()
          : <ExerciseRecommendation>[],
      meals: json['meals'] is List
          ? (json['meals'] as List).whereType<Map<String, dynamic>>().map(MealItem.fromJson).toList()
          : <MealItem>[],
    );
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'isRestDay': isRestDay,
        'targetMuscles': targetMuscles,
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'meals': meals.map((m) => m.toJson()).toList(),
      };
}

class ExerciseRecommendation {
  final String name;
  final String description;
  final String muscleGroup;
  final int sets;
  final int reps;

  ExerciseRecommendation({
    required this.name,
    required this.description,
    required this.muscleGroup,
    required this.sets,
    required this.reps,
  });

  factory ExerciseRecommendation.fromJson(Map<String, dynamic> json) {
    return ExerciseRecommendation(
      name: json['name'] as String? ?? 'Exercise',
      description: json['description'] as String? ?? '',
      muscleGroup: json['muscleGroup'] as String? ?? '',
      sets: (json['sets'] as num?)?.toInt() ?? 3,
      reps: (json['reps'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'muscleGroup': muscleGroup,
        'sets': sets,
        'reps': reps,
      };
}