import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/init/initialize_app.dart';
import '../../core/events/event_initializer.dart';

import '../rpg/user_stats_provider.dart';
import '../workout/workout_screen.dart';
import '../workout/seed_data.dart';
import '../history/history_screen.dart';

// 🔥 NUEVO
import '../missions/mission_service.dart';
import '../achievements/achievement_service.dart';
import '../nutrition/presentation/screens/nutrition_screen.dart';
import 'package:rpg_fitness/features/nutrition/data/nutrition_repository.dart';
import 'package:rpg_fitness/features/nutrition/domain/models/nutrition_profile.dart';

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

      // 🔥 NO TOCAR (ESTÁ PERFECTO)
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

    final db = ref.read(databaseProvider);
    final missions = MissionService(db).getDailyMissions();

    return Scaffold(
      appBar: AppBar(title: const Text("RPG Fitness")),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (stats) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================
                // 🔥 STATS
                // =====================
                const Text("Stats",
                    style: TextStyle(fontWeight: FontWeight.bold)),

                Text("Nivel: ${stats.level}"),
                Text("XP: ${stats.xp}"),

                const SizedBox(height: 10),

                Text("Strength: ${stats.strength}"),
                Text("Endurance: ${stats.endurance}"),
                Text("Agility: ${stats.agility}"),
                Text("Aesthetics: ${stats.aesthetics}"),
                Text("Power: ${stats.power}"),

                const SizedBox(height: 10),

                Text("Discipline: ${stats.discipline}"),
                Text("Balance: ${stats.balance}"),

                const SizedBox(height: 20),

                // =====================
                // 🔥 MISIONES
                // =====================
                const Text(
                  "Misiones",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                ...missions.map((m) {
                  return FutureBuilder(
                    future: MissionService(db).isCompleted(m),
                    builder: (context, snap) {
                      final done = snap.data ?? false;

                      return ListTile(
                        leading: Icon(
                          done ? Icons.check : Icons.circle,
                          color: done ? Colors.green : Colors.grey,
                        ),
                        title: Text(m.title),
                        subtitle: Text(m.description),
                      );
                    },
                  );
                }),

                const SizedBox(height: 20),

                // =====================
                // 🔥 LOGROS
                // =====================
                const Text(
                  "Logros",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                FutureBuilder(
                  future: AchievementService(db).getAchievements(),
                  builder: (context, snap) {
                    if (!snap.hasData) return const SizedBox();

                    final achievements = snap.data!;

                    if (achievements.isEmpty) {
                      return const Text("Sin logros aún");
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: achievements.map((a) => Text("🏆 $a")).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // =====================
                // 🔥 ACCIONES
                // =====================
                const Text(
                  "Acciones",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NutritionScreen(
                            repository: NutritionRepository(db),
                            profile: const NutritionProfile(
                              weight: 85,
                              height: 174,
                              age: 38,
                              sex: 'male',
                              goal: 'cut',
                              activityFactor: 1.5,
                            ),
                          ),
                        ));
                  },
                  child: const Text("Nutrición"),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
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
            ),
          );
        },
      ),
    );
  }
}
