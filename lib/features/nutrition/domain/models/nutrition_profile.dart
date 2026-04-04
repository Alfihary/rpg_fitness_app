class NutritionProfile {
  final double weight;
  final double height;
  final int age;
  final String sex; // male | female
  final String goal; // cut | maintain | bulk
  final double activityFactor;

  const NutritionProfile({
    required this.weight,
    required this.height,
    required this.age,
    required this.sex,
    required this.goal,
    required this.activityFactor,
  });
}
