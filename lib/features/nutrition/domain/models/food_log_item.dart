class FoodLogItem {
  final String id;
  final String mealType;
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final DateTime date;
  final String foodName;

  FoodLogItem({
    required this.id,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.date,
    required this.foodName,
  });
}
