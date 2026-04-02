class FatigueSystem {
  static double getFatigueMultiplier(int timesTrained) {
    if (timesTrained <= 1) return 1.0;
    if (timesTrained == 2) return 0.8;
    if (timesTrained == 3) return 0.6;
    return 0.5;
  }
}
