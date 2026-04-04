import 'package:drift/drift.dart';
import 'package:rpg_fitness/core/database/app_database.dart';
import 'package:rpg_fitness/core/events/event_bus.dart';
import 'package:rpg_fitness/core/events/app_event.dart';

class EvaluateNutrition {
  final AppDatabase db;

  EvaluateNutrition(this.db);

  Future<void> execute() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final logs = await (db.select(db.nutritionLogs)
          ..where((tbl) =>
              tbl.date.isBiggerOrEqualValue(start) &
              tbl.date.isSmallerThanValue(end)))
        .get();

    int calories = logs.fold<int>(0, (sum, e) => sum + e.calories);
    int protein = logs.fold<int>(0, (sum, e) => sum + e.protein);

    // 🔥 LÓGICA RPG
    if (calories >= 2000 && calories <= 2600 && protein >= 120) {
      eventBus.emit(NutritionPerfectEvent());
    } else if (calories < 1500) {
      eventBus.emit(NutritionLowEnergyEvent());
    } else {
      eventBus.emit(NutritionBadDietEvent());
    }
  }
}
