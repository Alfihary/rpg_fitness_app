import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/daily_nutrition_summary.dart';
import '../domain/models/food_entry.dart';

class NutritionRepository {
  final AppDatabase db;

  NutritionRepository(this.db);

  // =========================
  // 📊 GET TODAY SUMMARY
  // =========================
  Future<DailyNutritionSummary> getTodaySummary() async {
    final now = DateTime.now();

    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final logs = await (db.select(db.nutritionLogs)
          ..where((tbl) =>
              tbl.date.isBiggerOrEqualValue(start) &
              tbl.date.isSmallerThanValue(end)))
        .get();

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fats = 0;

    for (final l in logs) {
      calories += l.calories;
      protein += l.protein;
      carbs += l.carbs;
      fats += l.fats;
    }

    return DailyNutritionSummary(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );
  }

  // =========================
  // 🍽️ ADD FOOD (ESTO TE FALTABA)
  // =========================
  Future<void> addFood(FoodEntry entry) async {
    print("🔥 INSERTANDO EN DB");
    await db.into(db.nutritionLogs).insert(
          NutritionLogsCompanion.insert(
            id: DateTime.now().millisecondsSinceEpoch.toString(), // 🔥 FIX
            date: DateTime.now(),
            mealType: entry.mealType,
            calories: entry.calories,
            protein: entry.protein,
            carbs: entry.carbs,
            fats: entry.fats,
          ),
        );
    print("✅ INSERT OK");
  }
}
