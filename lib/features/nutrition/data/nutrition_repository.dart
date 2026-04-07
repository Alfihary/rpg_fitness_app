import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/models/daily_nutrition_summary.dart';
import '../domain/models/food_entry.dart';
import 'package:rpg_fitness/features/nutrition/domain/models/food_log_item.dart';

class NutritionRepository {
  final AppDatabase db;

  NutritionRepository(this.db);

  // =========================
  // 📊 TODAY
  // =========================
  Future<DailyNutritionSummary> getTodaySummary() async {
    final today = DateTime.now();

    final start = DateTime(today.year, today.month, today.day);
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
  // 🍽️ INSERT
  // =========================
  Future<void> addFood(FoodEntry entry, String foodName) async {
    await db.into(db.nutritionLogs).insert(
          NutritionLogsCompanion.insert(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            date: DateTime.now(),
            mealType: entry.mealType,
            foodName: Value(foodName), // 🔥 NUEVO
            calories: entry.calories,
            protein: entry.protein,
            carbs: entry.carbs,
            fats: entry.fats,
          ),
        );
  }

  // =========================
  // 📅 LAST 7 DAYS
  // =========================
  Future<Map<DateTime, DailyNutritionSummary>> getLast7Days() async {
    final logs = await db.select(db.nutritionLogs).get();

    final Map<String, DailyNutritionSummary> map = {};

    for (final l in logs) {
      final d = DateTime(l.date.year, l.date.month, l.date.day);
      final key = d.toIso8601String();

      final current = map[key];

      if (current == null) {
        map[key] = DailyNutritionSummary(
          calories: l.calories,
          protein: l.protein,
          carbs: l.carbs,
          fats: l.fats,
        );
      } else {
        map[key] = DailyNutritionSummary(
          calories: current.calories + l.calories,
          protein: current.protein + l.protein,
          carbs: current.carbs + l.carbs,
          fats: current.fats + l.fats,
        );
      }
    }

    final sorted = map.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    final result = <DateTime, DailyNutritionSummary>{};

    for (final e in sorted.take(7)) {
      result[DateTime.parse(e.key)] = e.value;
    }

    return result;
  }

  // =========================
  // 🔥 STREAK
  // =========================
  Future<int> getNutritionStreak() async {
    final history = await getLast7Days();

    int streak = 0;

    final dates = history.keys.toList()..sort((a, b) => b.compareTo(a));

    DateTime? prev;

    for (final d in dates) {
      if (prev == null) {
        streak++;
        prev = d;
        continue;
      }

      if (prev.difference(d).inDays == 1) {
        streak++;
        prev = d;
      } else {
        break;
      }
    }

    return streak;
  }

  Future<List<FoodLogItem>> getFoodsByDate(DateTime date) async {
    final logs = await db.select(db.nutritionLogs).get();

    final start = DateTime(date.year, date.month, date.day);

    return logs
        .where((l) {
          final d = l.date;
          return d.year == start.year &&
              d.month == start.month &&
              d.day == start.day;
        })
        .map((l) => FoodLogItem(
              id: l.id,
              mealType: l.mealType,
              calories: l.calories,
              protein: l.protein,
              carbs: l.carbs,
              fats: l.fats,
              date: l.date,
              foodName: l.foodName,
            ))
        .toList();
  }

  Future<void> updateFood(FoodLogItem item) async {
    await (db.update(db.nutritionLogs)..where((t) => t.id.equals(item.id)))
        .write(
      NutritionLogsCompanion(
        calories: Value(item.calories),
        protein: Value(item.protein),
        carbs: Value(item.carbs),
        fats: Value(item.fats),
      ),
    );
  }

  Future<void> deleteFood(String id) async {
    await (db.delete(db.nutritionLogs)..where((t) => t.id.equals(id))).go();
  }

  Future<List<String>> getFrequentFoods() async {
    final logs = await db.select(db.nutritionLogs).get();

    final map = <String, int>{};

    for (final l in logs) {
      // aquí usamos mealType como base simple (puedes mejorar luego)
      map[l.mealType] = (map[l.mealType] ?? 0) + 1;
    }

    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.map((e) => e.key).take(5).toList();
  }
}
