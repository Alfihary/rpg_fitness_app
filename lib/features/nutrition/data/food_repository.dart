import '../domain/models/food.dart';
import 'food_database.dart';
import 'food_api_service.dart';

class FoodRepository {
  final api = FoodApiService();

  Future<List<Food>> search(String query) async {
    if (query.length < 2) return [];

    // 🔥 intenta API primero
    final apiResults = await api.searchFoods(query);

    if (apiResults.isNotEmpty) return apiResults;

    // fallback local
    return FoodDatabase.foods
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
