import 'package:flutter/material.dart';
import 'package:rpg_fitness/features/nutrition/data/nutrition_repository.dart';

import '../../domain/models/nutrition_profile.dart';
import '../../domain/services/nutrition_calculator.dart';
import '../../domain/services/nutrition_evaluator.dart';

import '../widgets/calorie_bar.dart';
import '../widgets/macro_bar.dart';
import '../widgets/nutrition_feedback.dart';
import '../widgets/add_food_dialog.dart';
import 'nutrition_history_screen.dart';

// 🔥 SUGERENCIAS
import '../../domain/services/nutrition_suggestions.dart';

// 🔥 IA REAL
import '../../domain/services/nutrition_ai_service.dart';

// 🔥 EVENTOS RPG
import 'package:rpg_fitness/core/events/event_bus.dart';
import 'package:rpg_fitness/core/events/nutrition_events.dart';

class NutritionScreen extends StatefulWidget {
  final NutritionRepository repository;
  final NutritionProfile profile;

  const NutritionScreen({
    super.key,
    required this.repository,
    required this.profile,
  });

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  int calories = 0;
  int protein = 0;

  late int targetCalories;
  late int targetProtein;

  NutritionResult? result;

  // 🔥 evitar loops de eventos
  int lastCalories = -1;
  int lastProtein = -1;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final summary = await widget.repository.getTodaySummary();

    targetCalories =
        NutritionCalculator.calculateTargetCalories(widget.profile);

    targetProtein = NutritionCalculator.calculateProteinTarget(widget.profile);

    final newResult = NutritionEvaluator.evaluate(
      widget.profile,
      summary,
    );

    // =========================
    // 🔥 EVENTO RPG (SOLO SI CAMBIA)
    // =========================
    if (summary.calories != lastCalories || summary.protein != lastProtein) {
      EventBus().emit(
        NutritionEvaluatedEvent(
          calories: summary.calories,
          targetCalories: targetCalories,
          protein: summary.protein,
          targetProtein: targetProtein,
        ),
      );

      lastCalories = summary.calories;
      lastProtein = summary.protein;
    }

    if (!mounted) return;

    setState(() {
      calories = summary.calories;
      protein = summary.protein;
      result = newResult;
    });
  }

  void _openAddFoodDialog() {
    showDialog(
      context: context,
      builder: (_) => AddFoodDialog(
        repository: widget.repository,
        onSave: (entry, name) async {
          await widget.repository.addFood(entry, name);

          if (!mounted) return;

          await load();
        },
      ),
    );
  }

  void _goToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NutritionHistoryScreen(
          repo: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🔥 IA REAL
    final aiSuggestions = NutritionAIService.getSuggestions(
      calories: calories,
      targetCalories: targetCalories,
      protein: protein,
      targetProtein: targetProtein,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrición"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =========================
            // 🔥 CALORÍAS
            // =========================
            CalorieBar(
              current: calories,
              target: targetCalories,
            ),

            const SizedBox(height: 16),

            // =========================
            // 🍗 PROTEÍNA
            // =========================
            MacroBar(
              label: "Proteína",
              current: protein,
              target: targetProtein,
            ),

            const SizedBox(height: 20),

            // =========================
            // 🚦 FEEDBACK RPG
            // =========================
            NutritionFeedback(result: result!),

            const SizedBox(height: 20),

            // =========================
            // 🧠 SUGERENCIA SIMPLE
            // =========================
            Text(
              NutritionSuggestions.getSuggestion(
                currentCalories: calories,
                targetCalories: targetCalories,
                currentProtein: protein,
                targetProtein: targetProtein,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // =========================
            // 🤖 IA AVANZADA
            // =========================
            const Text(
              "Recomendaciones:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 5),

            ...aiSuggestions.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• $s"),
              ),
            ),

            const SizedBox(height: 25),

            // =========================
            // 📅 HISTORIAL
            // =========================
            Center(
              child: ElevatedButton(
                onPressed: _goToHistory,
                child: const Text("Ver historial"),
              ),
            ),
          ],
        ),
      ),

      // =========================
      // ➕ AGREGAR COMIDA
      // =========================
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
