import 'package:flutter/material.dart';
import '../../../shared/shared.dart';

class ItemMonthlyTable extends StatelessWidget {
  final Map<String, Map<String, double>> monthlyItemSpending;

  const ItemMonthlyTable({
    super.key,
    required this.monthlyItemSpending,
  });

  List<String> _getAllMonths(Map<String, Map<String, double>> monthlyItemSpending) {
    final months = <String>{};
    for (var monthsMap in monthlyItemSpending.values) {
      months.addAll(monthsMap.keys);
    }
    return months.toList()..sort();
  }

  List<MapEntry<String, Map<String, double>>> _getSortedItems(
    Map<String, Map<String, double>> monthlyItemSpending,
  ) {
    // Calculate total spending per item and sort
    final itemTotals = monthlyItemSpending.map((item, months) {
      final total = months.values.fold<double>(0.0, (a, b) => a + b);
      return MapEntry(item, total);
    });

    final sortedItems = monthlyItemSpending.entries.toList()
      ..sort((a, b) {
        final totalA = itemTotals[a.key] ?? 0.0;
        final totalB = itemTotals[b.key] ?? 0.0;
        return totalB.compareTo(totalA);
      });

    return sortedItems;
  }

  @override
  Widget build(BuildContext context) {
    if (monthlyItemSpending.isEmpty) {
      return const SizedBox.shrink();
    }

    final allMonths = _getAllMonths(monthlyItemSpending);
    if (allMonths.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedItems = _getSortedItems(monthlyItemSpending);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        ),
        columns: [
          const DataColumn(
            label: Text(
              'Item',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...allMonths.map((month) {
            return DataColumn(
              label: Text(
                month.substring(5), // Show MM format
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }),
          const DataColumn(
            label: Text(
              'Total',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            numeric: true,
          ),
        ],
        rows: sortedItems.map((entry) {
          final item = entry.key;
          final monthsData = entry.value;
          final total = monthsData.values.fold<double>(0.0, (a, b) => a + b);

          return DataRow(
            cells: [
              DataCell(
                Tooltip(
                  message: item,
                  child: Text(
                    item,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ...allMonths.map((month) {
                final amount = monthsData[month] ?? 0.0;
                return DataCell(
                  Text(
                    amount > 0 ? PriceDisplay.format(amount) : '-',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: amount > 0
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                );
              }),
              DataCell(
                Text(
                  PriceDisplay.format(total),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}



