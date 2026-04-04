import 'package:flutter/material.dart';
import '../../domain/services/nutrition_evaluator.dart';

class NutritionFeedback extends StatelessWidget {
  final NutritionResult result;

  const NutritionFeedback({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    switch (result) {
      case NutritionResult.perfect:
        text = "🔥 Perfecto";
        color = Colors.green;
        break;
      case NutritionResult.lowEnergy:
        text = "⚠️ Muy pocas calorías";
        color = Colors.orange;
        break;
      case NutritionResult.badDiet:
        text = "❌ Mala dieta";
        color = Colors.red;
        break;
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 18),
    );
  }
}
