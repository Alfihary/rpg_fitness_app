import 'package:flutter/material.dart';
import 'package:rpg_fitness/features/nutrition/data/nutrition_repository.dart';

import '../../domain/models/nutrition_profile.dart';
import '../../domain/services/nutrition_calculator.dart';
import '../../domain/services/nutrition_evaluator.dart';

import '../widgets/calorie_bar.dart';
import '../widgets/macro_bar.dart';
import '../widgets/nutrition_feedback.dart';
import '../widgets/add_food_dialog.dart';

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

    result = NutritionEvaluator.evaluate(
      widget.profile,
      summary,
    );

    setState(() {
      calories = summary.calories;
      protein = summary.protein;
    });
  }

  void _openAddFoodDialog() {
    showDialog(
      context: context,
      builder: (_) => AddFoodDialog(
        onSave: (entry) async {
          await widget.repository.addFood(entry);
          await load(); // 🔥 refresca UI
        },
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nutrición"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CalorieBar(
              current: calories,
              target: targetCalories,
            ),
            const SizedBox(height: 16),
            MacroBar(
              label: "Proteína",
              current: protein,
              target: targetProtein,
            ),
            const SizedBox(height: 20),
            NutritionFeedback(result: result!),
          ],
        ),
      ),

      // 🔥 BOTÓN QUE TE FALTABA
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddFoodDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
