import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/app_event.dart';

import '../progress/pr_service.dart';
import '../feedback/feedback_service.dart';

import 'get_today_routine.dart';
import 'get_or_create_today_workout.dart';

class WorkoutScreen extends StatefulWidget {
  final AppDatabase db;

  const WorkoutScreen({super.key, required this.db});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String? routine;
  List<RoutineExercise> exercises = [];

  final Map<String, TextEditingController> controllers = {};
  final Map<String, int> setCounters = {};
  final Map<String, int> restTimers = {};
  final Map<String, Timer?> timers = {};
  final Map<String, double> progress = {};

  Workout? currentWorkout;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final routineId = await GetTodayRoutine(widget.db).execute();
    if (routineId == null) return;

    final workout = await GetOrCreateTodayWorkout(widget.db).execute(routineId);

    final result = await (widget.db.select(widget.db.routineExercises)
          ..where((e) => e.routineId.equals(routineId)))
        .get();

    for (var e in result) {
      controllers[e.id] = TextEditingController();
      setCounters[e.id] = 0;
      restTimers[e.id] = e.restSeconds;
      progress[e.id] = 0;
    }

    setState(() {
      routine = routineId;
      exercises = result;
      currentWorkout = workout;
    });
  }

  void startTimer(String id) {
    timers[id]?.cancel();

    timers[id] = Timer.periodic(const Duration(seconds: 1), (t) {
      if (restTimers[id]! <= 0) {
        t.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🔥 Descanso terminado")),
        );
      } else {
        setState(() {
          restTimers[id] = restTimers[id]! - 1;
        });
      }
    });
  }

  double getMultiplier(RoutineExercise e, int reps) {
    if (reps >= e.suggestedMinReps && reps <= e.suggestedMaxReps) return 1.2;

    if (reps > e.suggestedMaxReps) return 1.5;

    return 0.8;
  }

  @override
  Widget build(BuildContext context) {
    if (routine == null || currentWorkout == null) {
      return const Scaffold(
        body: Center(child: Text("No hay rutina hoy")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("Rutina: $routine")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ...exercises.map((e) {
              final controller = controllers[e.id]!;

              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("${e.targetSets} series"),
                      Text("${e.suggestedMinReps}-${e.suggestedMaxReps} reps"),
                      if (e.hasDropSet) const Text("Dropset"),
                      Text("Descanso: ${restTimers[e.id]}s"),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress[e.id]! / e.targetSets,
                      ),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: "Reps"),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final reps = int.tryParse(controller.text) ?? 0;
                              if (reps <= 0) return;

                              final set = setCounters[e.id]! + 1;

                              final multiplier = getMultiplier(e, reps);

                              final finalReps = (reps * multiplier).toInt();

                              await widget.db
                                  .into(widget.db.workoutSets)
                                  .insert(
                                    WorkoutSetsCompanion.insert(
                                      id: DateTime.now().toString(),
                                      workoutId: currentWorkout!.id,
                                      exerciseId: e.id,
                                      reps: finalReps,
                                      weight: 0,
                                      setNumber: set,
                                      restSeconds: e.restSeconds,
                                      isDropSet: false,
                                    ),
                                  );

                              final pr = await PRService(widget.db).getPR(e.id);

                              final feedback = FeedbackService.getFeedback(
                                reps: reps,
                                min: e.suggestedMinReps,
                                max: e.suggestedMaxReps,
                                pr: pr,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(feedback)),
                              );

                              setState(() {
                                setCounters[e.id] = set;
                                progress[e.id] = set.toDouble();
                              });

                              controller.clear();
                              startTimer(e.id);
                            },
                            child: const Text("Agregar set"),
                          ),
                          const SizedBox(width: 10),
                          if (e.hasDropSet)
                            ElevatedButton(
                              onPressed: () async {
                                final reps = int.tryParse(controller.text) ?? 0;

                                await widget.db
                                    .into(widget.db.workoutSets)
                                    .insert(
                                      WorkoutSetsCompanion.insert(
                                        id: DateTime.now().toString(),
                                        workoutId: currentWorkout!.id,
                                        exerciseId: e.id,
                                        reps: reps,
                                        weight: 0,
                                        setNumber: setCounters[e.id]! + 1,
                                        restSeconds: e.restSeconds,
                                        isDropSet: true,
                                      ),
                                    );
                              },
                              child: const Text("Dropset"),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                restTimers[e.id] = 60;
                              });
                            },
                            child: const Text("1m"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                restTimers[e.id] = 120;
                              });
                            },
                            child: const Text("2m"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                restTimers[e.id] = 180;
                              });
                            },
                            child: const Text("3m"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                restTimers[e.id] =
                                    (restTimers[e.id]! - 10).clamp(10, 300);
                              });
                            },
                            child: const Text("-10s"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                restTimers[e.id] =
                                    (restTimers[e.id]! + 10).clamp(10, 300);
                              });
                            },
                            child: const Text("+10s"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            ElevatedButton(
              onPressed: () async {
                final sets = await (widget.db.select(widget.db.workoutSets)
                      ..where((s) => s.workoutId.equals(currentWorkout!.id)))
                    .get();

                int total = 0;
                for (var s in sets) {
                  total += s.reps;
                }

                eventBus.emit(WorkoutCompletedEvent(totalReps: total));

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Total reps: $total")),
                );
              },
              child: const Text("Finalizar entrenamiento"),
            ),
          ],
        ),
      ),
    );
  }
}
