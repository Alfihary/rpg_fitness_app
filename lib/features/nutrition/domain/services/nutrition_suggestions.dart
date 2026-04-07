class NutritionSuggestions {
  static String getSuggestion({
    required int currentCalories,
    required int targetCalories,
    required int currentProtein,
    required int targetProtein,
  }) {
    if (currentProtein < targetProtein) {
      return "💪 Te falta proteína → come pollo, huevo o atún";
    }

    if (currentCalories < targetCalories) {
      return "⚡ Te faltan calorías → añade arroz o avena";
    }

    if (currentCalories > targetCalories + 300) {
      return "⚠️ Te estás pasando → reduce grasas o carbs";
    }

    return "🔥 Vas perfecto, sigue así";
  }
}
