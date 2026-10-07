import '../ai_coach/ai_coach_models.dart';
import 'usda_food_service.dart';

class MealPlanBuilder {
  final UsdaFoodService _foodService;

  MealPlanBuilder({UsdaFoodService? foodService}) : _foodService = foodService ?? UsdaFoodService();

  static const _dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  static const _breakfastOptions = ['eggs whole', 'oatmeal', 'greek yogurt plain', 'whole wheat toast', 'banana raw', 'cottage cheese', 'peanut butter'];
  static const _lunchOptions = ['chicken breast grilled', 'brown rice cooked', 'salmon baked', 'quinoa cooked', 'turkey breast', 'sweet potato baked', 'tuna canned'];
  static const _dinnerOptions = ['lean beef ground', 'broccoli steamed', 'tilapia fillet', 'black beans', 'chicken thigh', 'brown rice cooked', 'spinach raw'];

  Future<Map<String, List<MealItem>>> buildWeeklyMealPlan({required int dailyCalories}) async {
    final result = <String, List<MealItem>>{};

    for (var i = 0; i < _dayNames.length; i++) {
      final breakfastQuery = _breakfastOptions[i % _breakfastOptions.length];
      final lunchQuery = _lunchOptions[i % _lunchOptions.length];
      final dinnerQuery = _dinnerOptions[i % _dinnerOptions.length];

      final meals = await Future.wait([
        _buildMeal(breakfastQuery, (dailyCalories * 0.30).round()),
        _buildMeal(lunchQuery, (dailyCalories * 0.35).round()),
        _buildMeal(dinnerQuery, (dailyCalories * 0.35).round()),
      ]);

      result[_dayNames[i]] = meals;
    }

    return result;
  }

  Future<MealItem> _buildMeal(String foodQuery, int targetCalories) async {
    final food = await _foodService.searchFood(foodQuery);

    if (food == null || food.caloriesPer100g <= 0) {
      return MealItem(
        name: _titleCase(foodQuery),
        description: 'Approx. $targetCalories kcal (USDA lookup unavailable)',
        calories: targetCalories,
      );
    }

    final scaledGrams = (targetCalories / food.caloriesPer100g) * 100;
    final description = '${scaledGrams.round()}g • ${food.proteinPer100g.round()}g protein per 100g (USDA)';

    return MealItem(name: _titleCase(foodQuery), description: description, calories: targetCalories);
  }

  String _titleCase(String s) {
    return s.split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  }
}