import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../shared/shared.dart';
import '../../../../core/theme/colors.dart';

class ItemMonthlyChart extends StatefulWidget {
  final Map<String, Map<String, double>> monthlyItemSpending;
  final int maxItemsToShow;

  const ItemMonthlyChart({
    super.key,
    required this.monthlyItemSpending,
    this.maxItemsToShow = 5,
  });

  @override
  State<ItemMonthlyChart> createState() => _ItemMonthlyChartState();
}

class _ItemMonthlyChartState extends State<ItemMonthlyChart> {
  final Set<String> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    // Select top items by default
    final topItems = _getTopItems(widget.monthlyItemSpending, widget.maxItemsToShow);
    _selectedItems.addAll(topItems);
  }

  List<String> _getTopItems(
    Map<String, Map<String, double>> monthlyItemSpending,
    int count,
  ) {
    // Calculate total spending per item
    final itemTotals = monthlyItemSpending.map((item, months) {
      final total = months.values.fold<double>(0.0, (a, b) => a + b);
      return MapEntry(item, total);
    });

    final sortedItems = itemTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedItems.take(count).map((e) => e.key).toList();
  }

  List<String> _getAllMonths(Map<String, Map<String, double>> monthlyItemSpending) {
    final months = <String>{};
    for (var monthsMap in monthlyItemSpending.values) {
      months.addAll(monthsMap.keys);
    }
    return months.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monthlyItemSpending.isEmpty) {
      return const SizedBox.shrink();
    }

    final allMonths = _getAllMonths(widget.monthlyItemSpending);
    if (allMonths.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxSpending = widget.monthlyItemSpending.values
        .expand((months) => months.values)
        .fold<double>(0.0, (a, b) => a > b ? a : b);

    final colors = AppColors.getChartColors();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Item selection checkboxes
        Container(
          padding: const EdgeInsets.all(AppSpacing.paddingS),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(
            spacing: AppSpacing.paddingS,
            runSpacing: AppSpacing.paddingXS,
            children: widget.monthlyItemSpending.keys.toList().asMap().entries.map((entry) {
              final item = entry.value;
              final itemIndex = entry.key;
              final isSelected = _selectedItems.contains(item);
              final color = colors[itemIndex % colors.length];
              return FilterChip(
                label: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedItems.add(item);
                    } else {
                      _selectedItems.remove(item);
                    }
                  });
                },
                selectedColor: color.withOpacity(0.3),
                checkmarkColor: color,
                avatar: isSelected
                    ? Icon(
                        Icons.check_circle,
                        size: 16,
                        color: color,
                      )
                    : null,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.paddingM),
        // Chart
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          '\$${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < allMonths.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            allMonths[value.toInt()].substring(5), // Show MM format
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
              lineBarsData: _selectedItems.toList().asMap().entries.map((entry) {
                final item = entry.value;
                final itemIndex = entry.key;
                final itemData = widget.monthlyItemSpending[item] ?? {};
                final color = colors[itemIndex % colors.length];
                
                final spots = allMonths.asMap().entries.map((entry) {
                  final month = entry.value;
                  final amount = itemData[month] ?? 0.0;
                  return FlSpot(entry.key.toDouble(), amount);
                }).toList();

                return LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withOpacity(0.1),
                  ),
                );
              }).toList(),
              minY: 0,
              maxY: maxSpending * 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

