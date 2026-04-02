import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/app_database.dart';

class GenerateTodayWorkout {
  final AppDatabase db;

  GenerateTodayWorkout(this.db);

  Future<void> execute() async {
    final today = DateTime.now();

    final plan = await db.select(db.weeklyPlan).getSingleOrNull();
    if (plan == null) return;

    String? routineId;

    switch (today.weekday) {
      case 1:
        routineId = plan.monday;
        break;
      case 2:
        routineId = plan.tuesday;
        break;
      case 3:
        routineId = plan.wednesday;
        break;
      case 4:
        routineId = plan.thursday;
        break;
      case 5:
        routineId = plan.friday;
        break;
      case 6:
        routineId = plan.saturday;
        break;
      case 7:
        routineId = plan.sunday;
        break;
    }

    if (routineId == null) return;

    final existing = await db.select(db.workouts).getSingleOrNull();

    if (existing != null) return;

    await db.into(db.workouts).insert(
          WorkoutsCompanion.insert(
            id: const Uuid().v4(),
            date: today,
            routineId: routineId,
          ),
        );
  }
}
