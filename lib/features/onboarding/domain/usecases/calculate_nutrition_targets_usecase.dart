import 'dart:math';

import '../entities/nutrition_targets.dart';

enum NutritionGender { male, female }

enum NutritionActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
}

class CalculateNutritionTargetsUsecase {
  NutritionTargets call({
    required NutritionGender gender,
    required double heightCm,
    required double currentWeightKg,
    required double targetWeightKg,
    required NutritionActivityLevel activityLevel,
  }) {
    final double safeHeight = max(heightCm, 0);
    final double safeCurrentWeight = max(currentWeightKg, 0);
    final double safeTargetWeight = max(targetWeightKg, 0);

    final bool isMale = gender == NutritionGender.male;
    final double bmr = (10 * safeCurrentWeight) +
        (6.25 * safeHeight) -
        (5 * 25) +
        (isMale ? 5 : -161);

    final double activityFactor = _activityFactor(activityLevel);
    final double tdee = bmr * activityFactor;
    double caloriesGoal = safeTargetWeight < safeCurrentWeight
        ? tdee - 500
        : tdee + 300;

    final int minCalories = isMale ? 1400 : 1200;
    caloriesGoal = max(caloriesGoal, minCalories.toDouble());

    final int proteinGrams = (safeTargetWeight * 2).round();
    final int fatGrams = (safeTargetWeight * 0.8).round();

    final int proteinCalories = proteinGrams * 4;
    final int fatCalories = fatGrams * 9;
    final int roundedCalories = caloriesGoal.round();
    final int remainingCalories = max(
      0,
      roundedCalories - (proteinCalories + fatCalories),
    );
    final int carbsGrams = (remainingCalories / 4).round();

    return NutritionTargets(
      calories: roundedCalories,
      proteinGrams: proteinGrams,
      fatGrams: fatGrams,
      carbsGrams: carbsGrams,
    );
  }

  double _activityFactor(NutritionActivityLevel level) {
    switch (level) {
      case NutritionActivityLevel.sedentary:
        return 1.2;
      case NutritionActivityLevel.lightlyActive:
        return 1.375;
      case NutritionActivityLevel.moderatelyActive:
        return 1.55;
      case NutritionActivityLevel.veryActive:
        return 1.725;
    }
  }
}
