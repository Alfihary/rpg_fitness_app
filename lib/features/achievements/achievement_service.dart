import '../../core/database/app_database.dart';

class AchievementService {
  final AppDatabase db;

  AchievementService(this.db);

  Future<List<String>> getAchievements() async {
    final sets = await db.select(db.workoutSets).get();

    int totalReps = sets.fold(0, (sum, s) => sum + s.reps);

    List<String> achievements = [];

    if (totalReps >= 100) {
      achievements.add("🔥 100 reps");
    }

    if (totalReps >= 500) {
      achievements.add("💀 500 reps");
    }

    return achievements;
  }
}
