class BalanceSystem {
  static double getBalanceMultiplier(Set<String> trainedMuscles) {
    bool trainedUpper =
        trainedMuscles.contains("Pecho") || trainedMuscles.contains("Espalda");

    bool trainedLower = trainedMuscles.contains("Pierna");

    if (trainedUpper && trainedLower) return 1.0;

    if (!trainedLower) return 0.7; // ❌ ignoraste piernas

    return 0.85;
  }
}
