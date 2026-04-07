import 'package:flutter/material.dart';
import '../../data/nutrition_repository.dart';
import '../widgets/nutrition_day_tile.dart';

class NutritionHistoryScreen extends StatefulWidget {
  final NutritionRepository repo;

  const NutritionHistoryScreen({super.key, required this.repo});

  @override
  State<NutritionHistoryScreen> createState() => _NutritionHistoryScreenState();
}

class _NutritionHistoryScreenState extends State<NutritionHistoryScreen> {
  Map<DateTime, dynamic> history = {};
  int streak = 0;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final h = await widget.repo.getLast7Days();
    final s = await widget.repo.getNutritionStreak();

    setState(() {
      history = h;
      streak = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial Nutrición")),
      body: Column(
        children: [
          // 🔥 STREAK
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              "🔥 Streak: $streak días",
              style: const TextStyle(fontSize: 20),
            ),
          ),

          // 📊 GRÁFICA SIMPLE
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: history.values.map((e) {
                final height = (e.calories / 3000) * 100;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: height,
                    color: Colors.green,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 10),

          // 📅 LISTA
          Expanded(
            child: ListView(
              children: history.entries.map((e) {
                return NutritionDayTile(
                  date: e.key,
                  data: e.value,
                  repository: widget.repo, // 🔥 FIX CLAVE
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
