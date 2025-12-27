import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/shared.dart';
import '../../../../core/utils/utils.dart';

class PriceHistoryChart extends StatelessWidget {
  final List<Map<String, dynamic>> priceHistory;

  const PriceHistoryChart({
    super.key,
    required this.priceHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (priceHistory.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxPrice = priceHistory.map((e) => e['unitPrice'] as double).reduce((a, b) => a > b ? a : b);
    final minPrice = priceHistory.map((e) => e['unitPrice'] as double).reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < priceHistory.length) {
                  final dateStr = priceHistory[value.toInt()]['date'] as String;
                  final date = DateTime.parse(dateStr);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormatter.formatForDisplay(date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: priceHistory.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['unitPrice'] as double);
            }).toList(),
            isCurved: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
        minY: minPrice * 0.9,
        maxY: maxPrice * 1.1,
      ),
    );
  }
}






