import '../../core/database/app_database.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/app_event.dart';
import 'package:uuid/uuid.dart';

class CompleteWorkout {
  final AppDatabase db;

  CompleteWorkout(this.db);

  Future<void> execute(String routineId) async {
    final id = const Uuid().v4();

    await db
        .into(db.workouts)
        .insert(
          WorkoutsCompanion.insert(
            id: id,
            date: DateTime.now(),
            routineId: routineId,
          ),
        );

    eventBus.emit(WorkoutCompletedEvent());
  }
}
