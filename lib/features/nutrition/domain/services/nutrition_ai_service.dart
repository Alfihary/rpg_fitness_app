class NutritionAIService {
  static List<String> getSuggestions({
    required int calories,
    required int targetCalories,
    required int protein,
    required int targetProtein,
  }) {
    final List<String> suggestions = [];

    if (protein < targetProtein) {
      suggestions.add("Aumenta proteína: pollo, huevo, atún");
    }

    if (calories < targetCalories) {
      suggestions.add("Te faltan calorías: añade arroz o avena");
    }

    if (calories > targetCalories + 300) {
      suggestions.add("Reduce grasas o porciones");
    }

    if (suggestions.isEmpty) {
      suggestions.add("Perfecto, sigue así 🔥");
    }

    return suggestions;
  }
}
