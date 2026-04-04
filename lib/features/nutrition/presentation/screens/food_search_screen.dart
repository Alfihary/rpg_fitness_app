import 'package:flutter/material.dart';
import '../../data/food_repository.dart';
import '../../domain/models/food.dart';

class FoodSearchScreen extends StatefulWidget {
  final Function(Food) onSelected;

  const FoodSearchScreen({super.key, required this.onSelected});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final repo = FoodRepository();
  List<Food> results = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buscar alimento")),
      body: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                results = repo.search(value);
              });
            },
            decoration: const InputDecoration(
              hintText: "Ej: pollo, arroz...",
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (_, i) {
                final food = results[i];
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text(
                      "${food.caloriesPer100g} kcal | ${food.proteinPer100g}g proteína"),
                  onTap: () {
                    widget.onSelected(food);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
