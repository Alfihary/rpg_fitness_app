import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/events/app_event.dart';
import '../rpg/muscle_mapper.dart';
import '../rpg/fatigue_system.dart';
import '../rpg/balance_system.dart';

class GameEngine {
  final AppDatabase db;

  GameEngine(this.db);

  Future<void> handle(AppEvent event) async {
    if (event is WorkoutCompletedEvent) {
      final stats = await db.select(db.userStatsTable).getSingle();

      final sets = await db.select(db.workoutSets).get();
      final exercises = await db.select(db.routineExercises).get();

      Map<String, RoutineExercise> exerciseMap = {
        for (var e in exercises) e.id: e
      };

      Map<String, int> muscleCount = {};
      Set<String> trainedMuscles = {};

      double strength = stats.strength.toDouble();
      double endurance = stats.endurance.toDouble();
      double agility = stats.agility.toDouble();
      double aesthetics = stats.aesthetics.toDouble();
      double power = stats.power.toDouble();

      int totalXp = 0;

      // =========================
      // 🔥 PROCESAR SETS
      // =========================
      for (var s in sets) {
        final exercise = exerciseMap[s.exerciseId];
        if (exercise == null) continue;

        final muscle = exercise.muscleGroup;
        trainedMuscles.add(muscle);

        muscleCount[muscle] = (muscleCount[muscle] ?? 0) + 1;

        final reps = s.reps;
        final weight = s.weight == 0 ? 1.0 : s.weight;

        double volume = reps.toDouble() * weight.toDouble();

        // 🔥 FATIGA
        final fatigueMultiplier =
            FatigueSystem.getFatigueMultiplier(muscleCount[muscle]!);

        volume *= fatigueMultiplier;

        totalXp += volume.toInt();

        final mapping = MuscleMapper.map[muscle];
        if (mapping == null) continue;

        mapping.forEach((stat, weightFactor) {
          final gain = volume * weightFactor;

          switch (stat) {
            case "strength":
              strength += gain;
              break;
            case "endurance":
              endurance += gain;
              break;
            case "agility":
              agility += gain;
              break;
            case "aesthetics":
              aesthetics += gain;
              break;
            case "power":
              power += gain;
              break;
          }
        });
      }

      // =========================
      // 🔥 BALANCE CORPORAL
      // =========================
      final balanceMultiplier =
          BalanceSystem.getBalanceMultiplier(trainedMuscles);

      totalXp = (totalXp * balanceMultiplier).toInt();

      // =========================
      // 🔥 STREAK DIARIO
      // =========================
      final workouts = await db.select(db.workouts).get();

      workouts.sort((a, b) => b.date.compareTo(a.date));

      int newStreak = 1;

      if (workouts.length >= 2) {
        final last = workouts[0].date;
        final previous = workouts[1].date;

        final diff = last.difference(previous).inDays;

        if (diff == 1) {
          newStreak = stats.streak + 1;
        }
      }

      // =========================
      // 🔥 XP + LEVEL (MEJORADO)
      // =========================
      int newXp = stats.xp + totalXp;

      // curva RPG real
      int newLevel = (newXp / 100).floor();

      // =========================
      // 🔥 UPDATE FINAL
      // =========================
      await (db.update(db.userStatsTable)..where((t) => t.id.equals(stats.id)))
          .write(
        UserStatsTableCompanion(
          xp: Value(newXp),
          level: Value(newLevel),
          strength: Value(strength.toInt()),
          endurance: Value(endurance.toInt()),
          agility: Value(agility.toInt()),
          aesthetics: Value(aesthetics.toInt()),
          power: Value(power.toInt()),

          // 🔥 NUEVO
          discipline: Value(stats.discipline + 1),
          streak: Value(newStreak),

          // 🔥 EXISTENTE
          balance: Value(stats.balance),
        ),
      );
    }
  }
}
