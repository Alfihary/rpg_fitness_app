import 'package:rpg_fitness/features/nutrition/domain/models/food.dart';

class FoodDatabase {
  static final List<Food> foods = [
    Food(
      name: "Pechuga de pollo",
      caloriesPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatsPer100g: 3,
    ),
    Food(
      name: "Arroz",
      caloriesPer100g: 130,
      proteinPer100g: 2,
      carbsPer100g: 28,
      fatsPer100g: 0,
    ),
    Food(
      name: "Huevo",
      caloriesPer100g: 155,
      proteinPer100g: 13,
      carbsPer100g: 1,
      fatsPer100g: 11,
    ),
  ];
}
