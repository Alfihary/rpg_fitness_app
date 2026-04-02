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

  // =========================
  // 🔥 EJERCICIOS PECHO
  // =========================

  await db.into(db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          id: "pushups",
          routineId: "chest",
          name: "Flexiones",
          muscleGroup: "Pecho",

          // 🔥 NUEVO (PLAN)
          targetSets: 3,
          suggestedMinReps: 6,
          suggestedMaxReps: 8,
          hasDropSet: true,
          restSeconds: 60,
        ),
      );

  await db.into(db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          id: "dips",
          routineId: "chest",
          name: "Fondos",
          muscleGroup: "Pecho",
          targetSets: 3,
          suggestedMinReps: 6,
          suggestedMaxReps: 10,
          hasDropSet: true,
          restSeconds: 60,
        ),
      );

  // =========================
  // 🔥 EJERCICIOS ESPALDA
  // =========================

  await db.into(db.routineExercises).insert(
        RoutineExercisesCompanion.insert(
          id: "pullups",
          routineId: "back",
          name: "Dominadas",
          muscleGroup: "Espalda",
          targetSets: 3,
          suggestedMinReps: 5,
          suggestedMaxReps: 8,
          hasDropSet: false,
          restSeconds: 90,
        ),
      );

  // =========================
  // 🔥 PLAN SEMANAL
  // =========================

  await db.into(db.weeklyPlan).insert(
        WeeklyPlanCompanion.insert(
          monday: const Value("chest"),
          tuesday: const Value("back"),
        ),
      );
}
