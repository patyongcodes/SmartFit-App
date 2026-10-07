import 'ai_coach_models.dart';
import '../body_composition/body_composition_calculator.dart';
import '../exercise/workout_scheduler.dart';
import '../nutrition/meal_plan_builder.dart';
import '../nutrition/nutrition_calculator.dart';

class PlanGenerator {
  final MealPlanBuilder _mealPlanBuilder;

  PlanGenerator({MealPlanBuilder? mealPlanBuilder}) : _mealPlanBuilder = mealPlanBuilder ?? MealPlanBuilder();

  Future<AiCoachResult> generatePlan({
    required List<String> targetMuscles,
    required int timelineMonths,
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) async {
    final bodyFatPercent = BodyCompositionCalculator.calculateBodyFatPercent(
      weightKg: weightKg,
      heightCm: heightCm,
      age: age,
      isMale: isMale,
    );
    final bodyFatCategory = BodyCompositionCalculator.classifyBodyFat(bodyFatPercent: bodyFatPercent, isMale: isMale);

    final bmr = NutritionCalculator.calculateBmr(weightKg: weightKg, heightCm: heightCm, age: age, isMale: isMale);
    final tdee = NutritionCalculator.calculateTdee(bmr);
    final dailyCalories = NutritionCalculator.calculateDailyCalorieTarget(tdee);
    final macros = NutritionCalculator.calculateMacros(dailyCalories: dailyCalories, weightKg: weightKg);

    final minimumMonths = 2 + (targetMuscles.length - 1);
    final adjustedTimelineMonths = timelineMonths < minimumMonths ? minimumMonths : timelineMonths;

    final aiNote = timelineMonths < minimumMonths
        ? 'Estimated body fat: ${bodyFatPercent.toStringAsFixed(1)}% ($bodyFatCategory). Building ${targetMuscles.join(", ")} typically needs at least $minimumMonths months of consistent training, so your timeline was adjusted.'
        : 'Estimated body fat: ${bodyFatPercent.toStringAsFixed(1)}% ($bodyFatCategory). Your requested timeline is realistic for building ${targetMuscles.join(", ")}.';

    final baseSchedule = WorkoutScheduler.generateSchedule(targetMuscles);
    final mealsByDay = await _mealPlanBuilder.buildWeeklyMealPlan(dailyCalories: dailyCalories);

    final mergedSchedule = baseSchedule
        .map((day) => WorkoutDay(
              day: day.day,
              isRestDay: day.isRestDay,
              targetMuscles: day.targetMuscles,
              exercises: day.exercises,
              meals: mealsByDay[day.day] ?? const [],
            ))
        .toList();

    return AiCoachResult(
      startDate: DateTime.now(),
      originalTimelineMonths: timelineMonths,
      adjustedTimelineMonths: adjustedTimelineMonths,
      aiNote: aiNote,
      dailyCalories: dailyCalories,
      sleepRecommendation: 'Aim for 7-9 hours of sleep per night to support muscle recovery and growth.',
      bodyFatPercent: bodyFatPercent,
      bodyFatCategory: bodyFatCategory,
      proteinG: macros.proteinG,
      carbG: macros.carbG,
      fatG: macros.fatG,
      weeklySchedule: mergedSchedule,
    );
  }
}