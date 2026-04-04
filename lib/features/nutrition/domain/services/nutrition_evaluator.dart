import '../models/daily_nutrition_summary.dart';
import '../models/nutrition_profile.dart';
import 'nutrition_calculator.dart';

enum NutritionResult {
  perfect,
  lowEnergy,
  badDiet,
}

class NutritionEvaluator {
  static NutritionResult evaluate(
    NutritionProfile profile,
    DailyNutritionSummary summary,
  ) {
    final targetCalories = NutritionCalculator.calculateTargetCalories(profile);

    final proteinTarget = NutritionCalculator.calculateProteinTarget(profile);

    final minCalories = targetCalories - 200;
    final maxCalories = targetCalories + 200;

    final caloriesOk =
        summary.calories >= minCalories && summary.calories <= maxCalories;

    final proteinOk = summary.protein >= proteinTarget;

    if (caloriesOk && proteinOk) {
      return NutritionResult.perfect;
    }

    if (summary.calories < minCalories) {
      return NutritionResult.lowEnergy;
    }

    return NutritionResult.badDiet;
  }
}
