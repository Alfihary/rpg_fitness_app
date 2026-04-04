import '../domain/models/food.dart';
import 'food_database.dart';

class FoodRepository {
  List<Food> search(String query) {
    return FoodDatabase.foods
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
