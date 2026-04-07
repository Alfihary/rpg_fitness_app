import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/events/app_event.dart';
import '../../core/events/nutrition_events.dart'; // 🔥 NUEVO

import '../rpg/muscle_mapper.dart';
import '../rpg/fatigue_system.dart';
import '../rpg/balance_system.dart';

class GameEngine {
  final AppDatabase db;

  GameEngine(this.db);

  int _clampStat(int value) => value < 0 ? 0 : value;

  Future<void> handle(AppEvent event) async {
    final stats = await db.select(db.userStatsTable).getSingle();

    // =========================
    // 🟥 WORKOUT SYSTEM
    // =========================
    if (event is WorkoutCompletedEvent) {
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

      for (var s in sets) {
        final exercise = exerciseMap[s.exerciseId];
        if (exercise == null) continue;

        final muscle = exercise.muscleGroup;
        trainedMuscles.add(muscle);

        muscleCount[muscle] = (muscleCount[muscle] ?? 0) + 1;

        final reps = s.reps;
        final weight = s.weight == 0 ? 1.0 : s.weight;

        double volume = reps.toDouble() * weight.toDouble();

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

      final balanceMultiplier =
          BalanceSystem.getBalanceMultiplier(trainedMuscles);

      totalXp = (totalXp * balanceMultiplier).toInt();

      final workouts = await db.select(db.workouts).get();
      workouts.sort((a, b) => b.date.compareTo(a.date));

      int newStreak = 1;

      if (workouts.length >= 2) {
        final last = workouts[0].date;
        final previous = workouts[1].date;

        if (last.difference(previous).inDays == 1) {
          newStreak = stats.streak + 1;
        }
      }

      int newXp = stats.xp + totalXp;
      int newLevel = (newXp / 100).floor();

      await (db.update(db.userStatsTable)..where((t) => t.id.equals(stats.id)))
          .write(
        UserStatsTableCompanion(
          xp: Value(newXp),
          level: Value(newLevel),
          strength: Value(_clampStat(strength.toInt())),
          endurance: Value(_clampStat(endurance.toInt())),
          agility: Value(_clampStat(agility.toInt())),
          aesthetics: Value(_clampStat(aesthetics.toInt())),
          power: Value(_clampStat(power.toInt())),
          discipline: Value(stats.discipline + 1),
          streak: Value(newStreak),
          balance: Value(stats.balance),
        ),
      );
    }

    // =========================
    // 🟢 NUTRITION PERFECT
    // =========================
    if (event is NutritionPerfectEvent) {
      const xpGain = 30;

      int newXp = stats.xp + xpGain;
      int newLevel = (newXp / 100).floor();

      await (db.update(db.userStatsTable)..where((t) => t.id.equals(stats.id)))
          .write(
        UserStatsTableCompanion(
          xp: Value(newXp),
          level: Value(newLevel),
          strength: Value(stats.strength + 2),
          endurance: Value(stats.endurance + 2),
          balance: Value(stats.balance + 3),
          discipline: Value(stats.discipline + 1),
        ),
      );
    }

    // =========================
    // 🟡 LOW ENERGY
    // =========================
    if (event is NutritionLowEnergyEvent) {
      const xpLoss = 10;

      int newXp = (stats.xp - xpLoss);
      if (newXp < 0) newXp = 0;

      await (db.update(db.userStatsTable)..where((t) => t.id.equals(stats.id)))
          .write(
        UserStatsTableCompanion(
          xp: Value(newXp),
          endurance: Value(_clampStat(stats.endurance - 3)),
          balance: Value(_clampStat(stats.balance - 1)),
        ),
      );
    }

    // =========================
    // 🔴 BAD DIET
    // =========================
    if (event is NutritionBadDietEvent) {
      const xpLoss = 20;

      int newXp = (stats.xp - xpLoss);
      if (newXp < 0) newXp = 0;

      await (db.update(db.userStatsTable)..where((t) => t.id.equals(stats.id)))
          .write(
        UserStatsTableCompanion(
          xp: Value(newXp),
          balance: Value(_clampStat(stats.balance - 4)),
          endurance: Value(_clampStat(stats.endurance - 1)),
        ),
      );
    }

    // =========================
    // 🧠 NUTRITION ADVANCED (🔥 NUEVO)
    // =========================
    if (event is NutritionEvaluatedEvent) {
      int strength = stats.strength;
      int endurance = stats.endurance;
      int balance = stats.balance;

      final calorieDiff = event.calories - event.targetCalories;

      // 💪 PROTEÍNA
      if (event.protein >= event.targetProtein) {
        strength += 2;
      } else {
        strength -= 1;
      }

      // ⚖️ CALORÍAS
      if (calorieDiff.abs() <= 200) {
        balance += 2;
      } else if (calorieDiff < -300) {
        endurance -= 2;
      } else if (calorieDiff > 300) {
        balance -= 2;
      }

      await (db.update(db.userStatsTable)..where((t) => t.id.equals(stats.id)))
          .write(
        UserStatsTableCompanion(
          strength: Value(_clampStat(strength)),
          endurance: Value(_clampStat(endurance)),
          balance: Value(_clampStat(balance)),
        ),
      );
    }
  }
}
