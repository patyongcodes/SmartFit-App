import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UsdaFoodItem {
  final String name;
  final int caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  UsdaFoodItem({
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });
}

class UsdaFoodService {
  final Dio _dio = Dio();
  static const _baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  Future<UsdaFoodItem?> searchFood(String query) async {
    final apiKey = dotenv.env['USDA_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      return null; // Falls back gracefully — see MealPlanBuilder
    }

    try {
      final response = await _dio.get(
        '$_baseUrl/foods/search',
        queryParameters: {
          'api_key': apiKey,
          'query': query,
          'pageSize': 1,
          'dataType': 'Foundation,SR Legacy',
        },
      );

      final foods = response.data['foods'] as List?;
      if (foods == null || foods.isEmpty) return null;

      final food = foods.first as Map<String, dynamic>;
      final nutrients = food['foodNutrients'] as List? ?? [];

      double findNutrient(String nameContains) {
        for (final n in nutrients) {
          final name = (n['nutrientName'] as String?)?.toLowerCase() ?? '';
          if (name.contains(nameContains)) {
            return (n['value'] as num?)?.toDouble() ?? 0;
          }
        }
        return 0;
      }

      return UsdaFoodItem(
        name: food['description'] as String? ?? query,
        caloriesPer100g: findNutrient('energy').round(),
        proteinPer100g: findNutrient('protein'),
        carbsPer100g: findNutrient('carbohydrate'),
        fatPer100g: findNutrient('total lipid'),
      );
    } catch (_) {
      return null;
    }
  }
}