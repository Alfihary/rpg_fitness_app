import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';

class HistoryScreen extends StatelessWidget {
  final AppDatabase db;

  const HistoryScreen({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial")),
      body: FutureBuilder(
        future: db.select(db.workouts).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final workouts = snapshot.data!;

          return ListView(
            children: workouts.map((w) {
              return FutureBuilder(
                future: (db.select(db.workoutSets)
                      ..where((s) => s.workoutId.equals(w.id)))
                    .get(),
                builder: (context, setSnapshot) {
                  if (!setSnapshot.hasData) {
                    return const SizedBox();
                  }

                  final sets = setSnapshot.data!;

                  return FutureBuilder(
                    future: db.select(db.routineExercises).get(),
                    builder: (context, exSnapshot) {
                      if (!exSnapshot.hasData) {
                        return const SizedBox();
                      }

                      final exercises = exSnapshot.data!;

                      Map<String, RoutineExercise> exerciseMap = {
                        for (var e in exercises) e.id: e
                      };

                      Map<String, int> volumeByExercise = {};
                      Map<String, int> volumeByMuscle = {};
                      int totalVolume = 0;

                      for (var s in sets) {
                        final exercise = exerciseMap[s.exerciseId];

                        if (exercise == null) continue;

                        volumeByExercise[exercise.name] =
                            (volumeByExercise[exercise.name] ?? 0) + s.reps;

                        volumeByMuscle[exercise.muscleGroup] =
                            (volumeByMuscle[exercise.muscleGroup] ?? 0) +
                                s.reps;

                        totalVolume += s.reps;
                      }

                      return Card(
                        margin: const EdgeInsets.all(8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Workout ${w.date}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Routine: ${w.routineId}"),
                              const SizedBox(height: 10),
                              ...volumeByExercise.entries.map(
                                (e) => Text("${e.key}: ${e.value} reps"),
                              ),
                              const SizedBox(height: 10),
                              ...volumeByMuscle.entries.map(
                                (e) => Text(
                                  "${e.key}: ${e.value} volumen",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "TOTAL: $totalVolume reps",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
