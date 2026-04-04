import 'package:flutter/material.dart';
import '../../data/food_repository.dart';
import '../../domain/models/food.dart';
import '../../domain/models/food_entry.dart';

class AddFoodDialog extends StatefulWidget {
  final Function(FoodEntry) onSave;

  const AddFoodDialog({
    super.key,
    required this.onSave,
  });

  @override
  State<AddFoodDialog> createState() => _AddFoodDialogState();
}

class _AddFoodDialogState extends State<AddFoodDialog> {
  final repo = FoodRepository();

  String mealType = "breakfast";
  List<Food> results = [];
  Food? selectedFood;

  final searchCtrl = TextEditingController();
  final gramsCtrl = TextEditingController(text: "100");

  void _search(String query) {
    setState(() {
      results = repo.search(query);
    });
  }

  void _save() {
    if (selectedFood == null) return;

    final grams = int.tryParse(gramsCtrl.text) ?? 0;

    final food = selectedFood!;

    final calories = (food.caloriesPer100g * grams) ~/ 100;
    final protein = (food.proteinPer100g * grams) ~/ 100;
    final carbs = (food.carbsPer100g * grams) ~/ 100;
    final fats = (food.fatsPer100g * grams) ~/ 100;

    final entry = FoodEntry(
      mealType: mealType,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
    );

    widget.onSave(entry);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar comida"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🍽️ Tipo de comida
            DropdownButtonFormField<String>(
              value: mealType,
              decoration: const InputDecoration(labelText: "Tipo de comida"),
              items: const [
                DropdownMenuItem(value: "breakfast", child: Text("Desayuno")),
                DropdownMenuItem(value: "lunch", child: Text("Comida")),
                DropdownMenuItem(value: "dinner", child: Text("Cena")),
                DropdownMenuItem(value: "snack", child: Text("Snack")),
              ],
              onChanged: (value) => setState(() => mealType = value!),
            ),

            const SizedBox(height: 12),

            // 🔍 BUSCADOR
            TextField(
              controller: searchCtrl,
              onChanged: _search,
              decoration: const InputDecoration(
                labelText: "Buscar alimento",
                hintText: "pollo, arroz, huevo...",
              ),
            ),

            const SizedBox(height: 10),

            // 📋 RESULTADOS
            if (results.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (_, i) {
                    final food = results[i];
                    return ListTile(
                      title: Text(food.name),
                      subtitle: Text("${food.caloriesPer100g} kcal / 100g"),
                      onTap: () {
                        setState(() {
                          selectedFood = food;
                          searchCtrl.text = food.name;
                          results = [];
                        });
                      },
                    );
                  },
                ),
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

            const SizedBox(height: 10),

            // 🔥 PREVIEW
            if (selectedFood != null)
              Builder(
                builder: (_) {
                  final grams = int.tryParse(gramsCtrl.text) ?? 0;
                  final f = selectedFood!;

                  final calories = (f.caloriesPer100g * grams) ~/ 100;
                  final protein = (f.proteinPer100g * grams) ~/ 100;

                  return Text(
                    "≈ $calories kcal | $protein g proteína",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),
          ],
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
