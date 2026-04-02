import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressChart extends StatelessWidget {
  final List<int> data;

  const ProgressChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text("Sin datos aún")),
      );
    }

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true),
            ),
          ),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(
                        e.key.toDouble(),
                        e.value.toDouble(),
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
