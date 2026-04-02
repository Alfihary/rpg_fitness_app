import '../../core/database/app_database.dart';
import 'mission_model.dart';

class MissionService {
  final AppDatabase db;

  MissionService(this.db);

  List<Mission> getDailyMissions() {
    return [
      Mission(
        id: "reps_50",
        title: "🔥 50 reps",
        description: "Haz 50 reps hoy",
        target: 50,
        type: "reps",
      ),
      Mission(
        id: "workout_1",
        title: "💪 Entrena",
        description: "Completa 1 entrenamiento",
        target: 1,
        type: "workout",
      ),
    ];
  }

  Future<bool> isCompleted(Mission mission) async {
    final sets = await db.select(db.workoutSets).get();

    if (mission.type == "reps") {
      int total = sets.fold(0, (sum, s) => sum + s.reps);
      return total >= mission.target;
    }

    if (mission.type == "workout") {
      final workouts = await db.select(db.workouts).get();
      return workouts.isNotEmpty;
    }

    return false;
  }
}
