import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';

class StatisticsSummary extends StatelessWidget {
  final double totalSpending;
  final int totalReceipts;

  const StatisticsSummary({
    super.key,
    required this.totalSpending,
    required this.totalReceipts,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Spending',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.paddingXS),
                PriceDisplay(
                  amount: totalSpending,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.paddingM),
        Expanded(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Receipts',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.paddingXS),
                Text(
                  totalReceipts.toString(),
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

