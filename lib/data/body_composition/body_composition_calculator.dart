/// Body composition estimation using the Deurenberg formula
/// (Deurenberg, Weststrate & Seidell, 1991), a peer-reviewed regression
/// equation relating BMI, age and sex to body fat percentage.
/// See thesis documentation for the full citation and verified formula.
class BodyCompositionCalculator {
  BodyCompositionCalculator._();

  static double calculateBmi({required double weightKg, required double heightCm}) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// isMale: true = male (sex=1), false = female (sex=0), per the
  /// Deurenberg formula's original coding convention.
  static double calculateBodyFatPercent({
    required double weightKg,
    required double heightCm,
    required int age,
    required bool isMale,
  }) {
    final bmi = calculateBmi(weightKg: weightKg, heightCm: heightCm);
    final sexValue = isMale ? 1 : 0;
    final bodyFat = (1.20 * bmi) + (0.23 * age) - (10.8 * sexValue) - 5.4;
    return bodyFat.clamp(3.0, 60.0);
  }

  /// General body fat percentage categories, commonly published by the
  /// American Council on Exercise (ACE). Verify the exact source before
  /// citing formally.
  static String classifyBodyFat({required double bodyFatPercent, required bool isMale}) {
    if (isMale) {
      if (bodyFatPercent < 6) return 'Essential Fat';
      if (bodyFatPercent < 14) return 'Athletic';
      if (bodyFatPercent < 18) return 'Fitness';
      if (bodyFatPercent < 25) return 'Average';
      return 'Above Average';
    } else {
      if (bodyFatPercent < 14) return 'Essential Fat';
      if (bodyFatPercent < 21) return 'Athletic';
      if (bodyFatPercent < 25) return 'Fitness';
      if (bodyFatPercent < 32) return 'Average';
      return 'Above Average';
    }
  }
}