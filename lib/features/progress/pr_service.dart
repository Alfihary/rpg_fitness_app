import '../../core/database/app_database.dart';

class PRService {
  final AppDatabase db;

  PRService(this.db);

  Future<int> getPR(String exerciseId) async {
    final sets = await (db.select(db.workoutSets)
          ..where((s) => s.exerciseId.equals(exerciseId)))
        .get();

    if (sets.isEmpty) return 0;

    return sets.map((e) => e.reps).reduce((a, b) => a > b ? a : b);
  }
}
