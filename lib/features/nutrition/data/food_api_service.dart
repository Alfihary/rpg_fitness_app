import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/food.dart';

class FoodApiService {
  Future<List<Food>> searchFoods(String query) async {
    final url =
        "https://world.openfoodfacts.org/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);

    final products = data['products'] as List;

    return products.take(10).map((p) {
      return Food(
        name: p['product_name'] ?? 'Desconocido',
        caloriesPer100g: (p['nutriments']?['energy-kcal_100g'] ?? 0).toInt(),
        proteinPer100g: (p['nutriments']?['proteins_100g'] ?? 0).toInt(),
        carbsPer100g: (p['nutriments']?['carbohydrates_100g'] ?? 0).toInt(),
        fatsPer100g: (p['nutriments']?['fat_100g'] ?? 0).toInt(),
      );
    }).toList();
  }
}
