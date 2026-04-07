import 'app_event.dart';

class NutritionEvaluatedEvent extends AppEvent {
  final int calories;
  final int targetCalories;
  final int protein;
  final int targetProtein;

  NutritionEvaluatedEvent({
    required this.calories,
    required this.targetCalories,
    required this.protein,
    required this.targetProtein,
  });
}
