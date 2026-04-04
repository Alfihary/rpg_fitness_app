import 'package:flutter/material.dart';

class MacroBar extends StatelessWidget {
  final String label;
  final int current;
  final int target;

  const MacroBar({
    super.key,
    required this.label,
    required this.current,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $current / $target g"),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
        ),
      ],
    );
  }
}
