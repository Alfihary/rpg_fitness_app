import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/events/event_bus.dart';
import '../../core/events/app_event.dart';
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

  Workout? currentWorkout; // 🔥 NUEVO

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final getRoutine = GetTodayRoutine(widget.db);
    final routineId = await getRoutine.execute();

    if (routineId == null) return;

    // 🔥 CREAR / OBTENER WORKOUT REAL
    final workoutCreator = GetOrCreateTodayWorkout(widget.db);
    final workout = await workoutCreator.execute(routineId);

    final result = await (widget.db.select(widget.db.routineExercises)
          ..where((e) => e.routineId.equals(routineId)))
        .get();

    for (var e in result) {
      controllers[e.id] = TextEditingController();
    }

    setState(() {
      routine = routineId;
      exercises = result;
      currentWorkout = workout; // 🔥 GUARDAR WORKOUT
    });
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
      body: Column(
        children: [
          ...exercises.map((e) {
            final controller = controllers[e.id]!;

            return Card(
              child: ListTile(
                title: Text(e.name),
                subtitle: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Reps"),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final reps = int.tryParse(controller.text) ?? 0;

                    if (reps <= 0) return;

                    await widget.db.into(widget.db.workoutSets).insert(
                          WorkoutSetsCompanion.insert(
                            id: DateTime.now().toString(),
                            workoutId: currentWorkout!.id,
                            exerciseId: e.id, // 🔥 CLAVE
                            reps: reps,
                            weight: 0,
                          ),
                        );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${e.name} guardado")),
                    );
                  },
                  child: const Text("Guardar"),
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final sets = await (widget.db.select(widget.db.workoutSets)
                    ..where((s) => s.workoutId.equals(currentWorkout!.id)))
                  .get();

              int totalReps = 0;

              for (var s in sets) {
                totalReps += s.reps;
              }

              eventBus.emit(
                WorkoutCompletedEvent(totalReps: totalReps),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Workout completado: $totalReps reps"),
                ),
              );
            },
            child: const Text("Finalizar entrenamiento"),
          ),
        ],
      ),
    );
  }
}
