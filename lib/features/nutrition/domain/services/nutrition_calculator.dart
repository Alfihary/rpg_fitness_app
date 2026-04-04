import '../models/nutrition_profile.dart';

class NutritionCalculator {
  static double calculateBMR(NutritionProfile profile) {
    if (profile.sex == 'male') {
      return (10 * profile.weight) +
          (6.25 * profile.height) -
          (5 * profile.age) +
          5;
    } else {
      return (10 * profile.weight) +
          (6.25 * profile.height) -
          (5 * profile.age) -
          161;
    }
  }

  static double calculateTDEE(NutritionProfile profile) {
    final bmr = calculateBMR(profile);
    return bmr * profile.activityFactor;
  }

  static int calculateTargetCalories(NutritionProfile profile) {
    final tdee = calculateTDEE(profile);

    switch (profile.goal) {
      case 'cut':
        return (tdee - 400).round();
      case 'bulk':
        return (tdee + 300).round();
      default:
        return tdee.round();
    }
  }

  static int calculateProteinTarget(NutritionProfile profile) {
    return (profile.weight * 2.0).round();
  }
}
