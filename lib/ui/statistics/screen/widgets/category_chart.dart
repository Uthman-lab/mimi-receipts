import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/shared.dart';
import '../../../../core/theme/colors.dart';

class CategoryChart extends StatelessWidget {
  final Map<String, double> spendingByCategory;

  const CategoryChart({
    super.key,
    required this.spendingByCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final entries = spendingByCategory.entries.toList();
    final total = spendingByCategory.values.fold<double>(0.0, (a, b) => a + b);

    return PieChart(
      PieChartData(
        sections: entries.map((entry) {
          final percentage = (entry.value / total * 100);
          return PieChartSectionData(
            value: entry.value,
            title: '${percentage.toStringAsFixed(1)}%',
            color: AppColors.getCategoryColor(entry.key),
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
}




