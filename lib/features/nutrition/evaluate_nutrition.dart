import '../../core/database/app_database.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/app_event.dart';

class EvaluateNutrition {
  final AppDatabase db;

  EvaluateNutrition(this.db);

  Future<void> execute() async {
    final today = DateTime.now();

    final logs = await (db.select(
      db.nutritionLogs,
    )..where((tbl) => tbl.date.equals(today))).get();

    int calories = logs.fold(0, (sum, e) => sum + e.calories);
    int protein = logs.fold(0, (sum, e) => sum + e.protein);

    if (calories >= 2000 && calories <= 2500 && protein >= 120) {
      eventBus.emit(NutritionGoalMetEvent());
    }
  }
}
