import '../models/body_composition.dart';

class BodyRecompositionService {
  static BodyComposition update({
    required BodyComposition current,
    required int calories,
    required int targetCalories,
    required int protein,
    required int targetProtein,
  }) {
    double newFat = current.bodyFat;
    double newMuscle = current.muscleMass;

    // 🔥 lógica base
    if (calories < targetCalories && protein >= targetProtein) {
      newFat -= 0.1;
      newMuscle += 0.05;
    }

    if (calories > targetCalories + 300) {
      newFat += 0.1;
    }

    return BodyComposition(
      weight: current.weight,
      bodyFat: newFat,
      muscleMass: newMuscle,
    );
  }
}
