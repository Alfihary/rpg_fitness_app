class FeedbackService {
  static String getFeedback({
    required int reps,
    required int min,
    required int max,
    required int pr,
  }) {
    if (reps > pr) return "🔥 NUEVO RÉCORD";

    if (reps >= min && reps <= max) {
      return "✅ Rango perfecto";
    }

    if (reps > max) {
      return "💪 Más de lo esperado";
    }

    return "⚠️ Puedes mejorar";
  }
}
