class AppEvent {}

// =========================
// 🟥 WORKOUT
// =========================
class WorkoutCompletedEvent extends AppEvent {
  final int totalReps;

  WorkoutCompletedEvent({required this.totalReps});
}

// =========================
// 🟢 NUTRITION
// =========================

class NutritionPerfectEvent extends AppEvent {}

class NutritionLowEnergyEvent extends AppEvent {}

class NutritionBadDietEvent extends AppEvent {}
