import '../../core/database/app_database.dart';

class ProgressService {
  final AppDatabase db;

  ProgressService(this.db);

  Future<List<int>> getProgress(String exerciseId) async {
    final sets = await (db.select(db.workoutSets)
          ..where((s) => s.exerciseId.equals(exerciseId)))
        .get();

    Map<String, int> daily = {};

    for (var s in sets) {
      final day = s.workoutId.substring(0, 10); // simplificado

      daily[day] = (daily[day] ?? 0) + s.reps;
    }

    return daily.values.toList();
  }
}
