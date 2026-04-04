import 'package:flutter/material.dart';

class CalorieBar extends StatelessWidget {
  final int current;
  final int target;

  const CalorieBar({
    super.key,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    Color color;
    if (progress < 0.8) {
      color = Colors.orange;
    } else if (progress <= 1.1) {
      color = Colors.green;
    } else {
      color = Colors.red;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Calorías: $current / $target"),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          color: color,
          backgroundColor: Colors.grey.shade800,
        ),
      ],
    );
  }
}
