import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';

import '../../core/shared/widgets/progress_chart.dart';
import '../progress/progress_service.dart';
import '../progress/pr_service.dart';

// 🔥 NUEVO
import '../exercise_detail/exercise_detail_screen.dart';

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

          if (workouts.isEmpty) {
            return const Center(child: Text("Sin historial aún"));
          }

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
                      final exerciseMap = {for (var e in exercises) e.id: e};

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
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Workout ${w.date}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text("Routine: ${w.routineId}"),
                              const SizedBox(height: 12),
                              const Text("Ejercicios",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ...volumeByExercise.entries.map((e) {
                                final exercise = exercises
                                    .firstWhere((ex) => ex.name == e.key);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExerciseDetailScreen(
                                          db: db,
                                          exerciseId: exercise.id,
                                          name: exercise.name,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${e.key}: ${e.value} reps"),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              const Text("Progreso",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ...volumeByExercise.keys.map((name) {
                                final exercise =
                                    exercises.firstWhere((e) => e.name == name);

                                return FutureBuilder(
                                  future: Future.wait([
                                    PRService(db).getPR(exercise.id),
                                    ProgressService(db)
                                        .getProgress(exercise.id),
                                  ]),
                                  builder: (context, snap) {
                                    if (!snap.hasData) {
                                      return const SizedBox();
                                    }

                                    final pr = snap.data![0] as int;
                                    final data = snap.data![1] as List<int>;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("🏆 PR: $pr"),
                                        ProgressChart(data: data),
                                      ],
                                    );
                                  },
                                );
                              }),
                              const SizedBox(height: 12),
                              const Text("Músculos trabajados",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ...volumeByMuscle.entries.map(
                                (e) => Text("${e.key}: ${e.value}"),
                              ),
                              const SizedBox(height: 12),
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
