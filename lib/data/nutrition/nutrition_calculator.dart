/// BMR/TDEE calculation using the Mifflin-St Jeor equation (1990).
/// See thesis documentation for the full citation and verified formula.
class NutritionCalculator {
  NutritionCalculator._();

  static double calculateBmr({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    final base = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
    return isMale ? base + 5 : base - 161;
  }

  /// "Moderately active" multiplier (1.55), a standard clinical activity
  /// factor for someone starting a structured training program.
  static double calculateTdee(double bmr) => bmr * 1.55;

  /// Adds a lean-bulk surplus (~350 kcal/day) on top of TDEE to support
  /// muscle gain while limiting fat accumulation.
  static int calculateDailyCalorieTarget(double tdee) => (tdee + 350).round();

  /// Protein at 1.8g/kg bodyweight — above the ~1.6g/kg sufficiency
  /// threshold identified by Morton et al. (2018). Fat at 25% of total
  /// calories; remainder allocated to carbohydrates.
  static MacroTargets calculateMacros({required int dailyCalories, required double weightKg}) {
    final proteinG = (weightKg * 1.8).round();
    final proteinCal = proteinG * 4;
    final fatCal = (dailyCalories * 0.25).round();
    final fatG = (fatCal / 9).round();
    final carbCal = (dailyCalories - proteinCal - fatCal).clamp(0, dailyCalories);
    final carbG = (carbCal / 4).round();
    return MacroTargets(proteinG: proteinG, carbG: carbG, fatG: fatG);
  }
}

class MacroTargets {
  final int proteinG;
  final int carbG;
  final int fatG;

  MacroTargets({required this.proteinG, required this.carbG, required this.fatG});
}