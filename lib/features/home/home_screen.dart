import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/init/initialize_app.dart';
import '../../core/events/event_initializer.dart';

import '../rpg/user_stats_provider.dart';
import '../workout/workout_screen.dart';
import '../workout/seed_data.dart';
import '../history/history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool initialized = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final db = ref.read(databaseProvider);
      final engine = ref.read(gameEngineProvider);

      initEventSystem(engine);

      await initializeApp(db);
      await seedData(db);

      setState(() {
        initialized = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userStatsStreamProvider);

    if (!initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("RPG Fitness")),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (stats) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Nivel: ${stats.level}"),
              Text("XP: ${stats.xp}"),

              const SizedBox(height: 20),

              // 🔥 FITNESS STATS
              Text("Strength: ${stats.strength}"),
              Text("Endurance: ${stats.endurance}"),
              Text("Agility: ${stats.agility}"),
              Text("Aesthetics: ${stats.aesthetics}"),
              Text("Power: ${stats.power}"),

              const SizedBox(height: 20),

              // 🔥 META STATS
              Text("Discipline: ${stats.discipline}"),
              Text("Balance: ${stats.balance}"),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  final db = ref.read(databaseProvider);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutScreen(db: db),
                    ),
                  );
                },
                child: const Text("Ir a entrenar"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () {
                  final db = ref.read(databaseProvider);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HistoryScreen(db: db),
                    ),
                  );
                },
                child: const Text("Ver historial"),
              ),
            ],
          );
        },
      ),
    );
  }
}
