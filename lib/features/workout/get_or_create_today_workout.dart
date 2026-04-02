import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';

class GetOrCreateTodayWorkout {
  final AppDatabase db;

  GetOrCreateTodayWorkout(this.db);

  Future<Workout> execute(String routineId) async {
    final today = DateTime.now();

    final existing = await db.select(db.workouts).getSingleOrNull();

    if (existing != null) return existing;

    final id = const Uuid().v4();

    await db.into(db.workouts).insert(
          WorkoutsCompanion.insert(
            id: id,
            date: today,
            routineId: routineId,
          ),
        );

    return (await db.select(db.workouts).get()).last;
  }
}
