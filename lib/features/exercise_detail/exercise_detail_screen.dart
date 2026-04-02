import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/shared/widgets/progress_chart.dart';
import '../progress/progress_service.dart';
import '../progress/pr_service.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final AppDatabase db;
  final String exerciseId;
  final String name;

  const ExerciseDetailScreen({
    super.key,
    required this.db,
    required this.exerciseId,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: FutureBuilder(
        future: db.select(db.workoutSets).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sets =
              snapshot.data!.where((s) => s.exerciseId == exerciseId).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 PR
                FutureBuilder(
                  future: PRService(db).getPR(exerciseId),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();

                    return Text(
                      "🏆 PR: ${snap.data}",
                      style: const TextStyle(fontSize: 20),
                    );
                  },
                ),

                const SizedBox(height: 10),

                // 🔥 GRÁFICA
                FutureBuilder(
                  future: ProgressService(db).getProgress(exerciseId),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();

                    return ProgressChart(data: snap.data!);
                  },
                ),

                const SizedBox(height: 20),

                // 🔥 HISTORIAL DE SETS
                const Text("Sets históricos"),

                ...sets.map((s) => ListTile(
                      title: Text("${s.reps} reps"),
                      subtitle: Text("Set ${s.setNumber} | ${s.restSeconds}s"),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
