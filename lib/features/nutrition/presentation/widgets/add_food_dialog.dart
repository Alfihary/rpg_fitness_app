import 'package:flutter/material.dart';

import '../../data/food_repository.dart';
import '../../data/favorites_repository.dart';
import '../../data/nutrition_repository.dart';

import '../../domain/models/food.dart';
import '../../domain/models/food_entry.dart';

class AddFoodDialog extends StatefulWidget {
  final Future<void> Function(FoodEntry entry, String name) onSave;
  final NutritionRepository repository;

  const AddFoodDialog({
    super.key,
    required this.onSave,
    required this.repository,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final foodRepo = FoodRepository();
  final favRepo = FavoritesRepository();

  String mealType = "breakfast";

  List<Food> results = [];
  Food? selectedFood;

  final searchCtrl = TextEditingController();
  final gramsCtrl = TextEditingController(text: "100");

  late Future<List<String>> frequentFuture;

  @override
  void initState() {
    super.initState();
    frequentFuture = widget.repository.getFrequentFoods();
  }

  void _search(String query) async {
    final r = await foodRepo.search(query);

    if (!mounted) return;

    setState(() {
      selectedFood = null;
      results = r;
    });
  }

  void _save() {
    if (selectedFood == null) return;

    final grams = int.tryParse(gramsCtrl.text) ?? 0;
    final f = selectedFood!;

    final entry = FoodEntry(
      mealType: mealType,
      calories: (f.caloriesPer100g * grams) ~/ 100,
      protein: (f.proteinPer100g * grams) ~/ 100,
      carbs: (f.carbsPer100g * grams) ~/ 100,
      fats: (f.fatsPer100g * grams) ~/ 100,
    );

    Navigator.pop(context);

    Future.microtask(() {
      widget.onSave(entry, f.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final favorites = favRepo.getFavorites();

    return AlertDialog(
      title: const Text("Agregar comida"),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🍽️ Tipo de comida
              DropdownButtonFormField<String>(
                value: mealType,
                items: const [
                  DropdownMenuItem(value: "breakfast", child: Text("Desayuno")),
                  DropdownMenuItem(value: "lunch", child: Text("Comida")),
                  DropdownMenuItem(value: "dinner", child: Text("Cena")),
                  DropdownMenuItem(value: "snack", child: Text("Snack")),
                ],
                onChanged: (v) => setState(() => mealType = v!),
              ),

              const SizedBox(height: 10),

              // ⭐ FAVORITOS
              if (favorites.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("⭐ Favoritos"),
                    Wrap(
                      children: favorites.map((f) {
                        return Padding(
                          padding: const EdgeInsets.all(4),
                          child: Chip(
                            label: Text(f),
                            onDeleted: () {
                              setState(() {
                                favRepo.toggleFavorite(f);
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),

              // 🔁 FRECUENTES
              FutureBuilder<List<String>>(
                future: frequentFuture,
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();

                  final items = snap.data!;

                  if (items.isEmpty) return const SizedBox();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("🔁 Frecuentes"),
                      Wrap(
                        children: items.map((f) {
                          return Padding(
                            padding: const EdgeInsets.all(4),
                            child: Chip(label: Text(f)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
              ),

              // 🔍 BUSCAR
              TextField(
                controller: searchCtrl,
                onChanged: _search,
                decoration: const InputDecoration(
                  labelText: "Buscar alimento",
                ),
              ),

              const SizedBox(height: 10),

              // ✅ SELECCIONADO
              if (selectedFood != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Seleccionado"),
                    Card(
                      child: ListTile(
                        title: Text(selectedFood!.name),
                        subtitle: Text(
                          "${selectedFood!.caloriesPer100g} kcal / 100g",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              selectedFood = null;
                              searchCtrl.clear();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                )

              // 🔍 RESULTADOS
              else if (results.isNotEmpty)
                Column(
                  children: results.map((food) {
                    return ListTile(
                      title: Text(food.name),
                      trailing: IconButton(
                        icon: Icon(
                          favRepo.isFavorite(food.name)
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            favRepo.toggleFavorite(food.name);
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          selectedFood = food;
                          searchCtrl.text = food.name;
                          results = [];
                        });
                      },
                    );
                  }).toList(),
                ),

              const SizedBox(height: 10),

              // ⚖️ GRAMOS
              TextField(
                controller: gramsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Cantidad (gramos)",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text("Guardar"),
        ),
      ],
    );
  }
}
