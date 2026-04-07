import 'package:flutter/material.dart';
import '../../domain/models/daily_nutrition_summary.dart';
import '../../data/nutrition_repository.dart';
import '../screens/nutrition_day_detail_screen.dart';

class NutritionDayTile extends StatelessWidget {
  final DateTime date;
  final DailyNutritionSummary data;
  final NutritionRepository repository; // 🔥 NUEVO

  const NutritionDayTile({
    super.key,
    required this.date,
    required this.data,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${date.day}/${date.month}";

    Color color;

    if (data.calories < 1200) {
      color = Colors.orange;
    } else if (data.calories <= 2500) {
      color = Colors.green;
    } else {
      color = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NutritionDayDetailScreen(
                repo: repository,
                date: date,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            date.day.toString(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(formattedDate),
        subtitle: Text(
          "${data.calories} kcal | ${data.protein}g proteína",
        ),
      ),
    );
  }
}
