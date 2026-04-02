import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';

Future<void> seedData(AppDatabase db) async {
  final routines = await db.select(db.routines).get();

  if (routines.isNotEmpty) return;

  // Rutinas
  await db.into(db.routines).insert(
        RoutinesCompanion.insert(id: "chest", name: "Pecho"),
      );

  await db.into(db.routines).insert(
        RoutinesCompanion.insert(id: "back", name: "Espalda"),
      );

  // Ejercicios (🔥 TODOS con muscleGroup)
  await db.into(db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          id: "pushups",
          routineId: "chest",
          name: "Flexiones",
          muscleGroup: "Pecho",
        ),
      );

  await db.into(db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          id: "dips",
          routineId: "chest",
          name: "Fondos",
          muscleGroup: "Pecho",
        ),
      );

  await db.into(db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          id: "pullups",
          routineId: "back",
          name: "Dominadas",
          muscleGroup: "Espalda",
        ),
      );

  // Plan semanal
  await db.into(db.weeklyPlan).insert(
        WeeklyPlanCompanion.insert(
          monday: const Value("chest"),
          tuesday: const Value("back"),
        ),
      );
}
