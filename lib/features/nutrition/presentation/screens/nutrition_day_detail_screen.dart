import 'package:flutter/material.dart';
import '../../data/nutrition_repository.dart';
import '../../domain/models/food_log_item.dart';

class NutritionDayDetailScreen extends StatefulWidget {
  final NutritionRepository repo;
  final DateTime date;

  const NutritionDayDetailScreen({
    super.key,
    required this.repo,
    required this.date,
  });

  @override
  State<NutritionDayDetailScreen> createState() =>
      _NutritionDayDetailScreenState();
}

class _NutritionDayDetailScreenState extends State<NutritionDayDetailScreen> {
  List<FoodLogItem> foods = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final f = await widget.repo.getFoodsByDate(widget.date);

    if (!mounted) return;

    setState(() => foods = f);
  }

  String translateMeal(String m) {
    switch (m) {
      case "breakfast":
        return "Desayuno";
      case "lunch":
        return "Comida";
      case "dinner":
        return "Cena";
      case "snack":
        return "Snack";
      default:
        return m;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detalle ${widget.date.day}/${widget.date.month}"),
      ),
      body: ListView(
        children: foods.map((f) {
          return ListTile(
            // 🔥 AHORA MUESTRA COMIDA REAL
            title: Text(
              f.foodName.isNotEmpty ? f.foodName : "Alimento",
            ),

            // 🔥 INFO COMPLETA
            subtitle: Text(
              "${translateMeal(f.mealType)} • "
              "${f.calories} kcal | "
              "P: ${f.protein}g "
              "C: ${f.carbs}g "
              "G: ${f.fats}g",
            ),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✏️ EDITAR
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final controller =
                        TextEditingController(text: f.calories.toString());

                    final result = await showDialog<int>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Editar calorías"),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Calorías",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancelar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final value = int.tryParse(controller.text);
                              Navigator.pop(context, value);
                            },
                            child: const Text("Guardar"),
                          ),
                        ],
                      ),
                    );

                    if (result == null) return;

                    final updated = FoodLogItem(
                      id: f.id,
                      mealType: f.mealType,
                      calories: result,
                      protein: f.protein,
                      carbs: f.carbs,
                      fats: f.fats,
                      date: f.date,
                      foodName: f.foodName, // 🔥 IMPORTANTE
                    );

                    await widget.repo.updateFood(updated);

                    if (!mounted) return;

                    await load();
                  },
                ),

                // 🗑️ DELETE
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await widget.repo.deleteFood(f.id);

                    if (!mounted) return;

                    await load();
                  },
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
