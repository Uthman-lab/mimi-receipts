import 'package:flutter/material.dart';
import '../../../shared/shared.dart';

class ItemSpendingChart extends StatelessWidget {
  final List<Map<String, dynamic>> spendingByItem;
  final int maxItemsToShow;

  const ItemSpendingChart({
    super.key,
    required this.spendingByItem,
    this.maxItemsToShow = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (spendingByItem.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemsToShow = spendingByItem.take(maxItemsToShow).toList();
    final hasMore = spendingByItem.length > maxItemsToShow;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itemsToShow.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = itemsToShow[index];
            final itemDescription = item['itemDescription'] as String;
            final totalSpent = item['totalSpent'] as double;
            final purchaseCount = item['purchaseCount'] as int;
            final avgPrice = item['avgPrice'] as double;
            final totalQuantity = item['totalQuantity'] as double;

            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.paddingS,
                horizontal: AppSpacing.paddingXS,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rank indicator
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.paddingM),
                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          itemDescription,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.paddingXS),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoChip(
                                context,
                                Icons.attach_money,
                                PriceDisplay(amount: totalSpent),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.paddingXS),
                            Expanded(
                              child: _buildInfoChip(
                                context,
                                Icons.shopping_cart,
                                Text('$purchaseCount'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.paddingXS),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoChip(
                                context,
                                Icons.trending_up,
                                Text(
                                  'Avg: ${PriceDisplay.format(avgPrice)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ),
                            if (totalQuantity > 0) ...[
                              const SizedBox(width: AppSpacing.paddingXS),
                              Expanded(
                                child: _buildInfoChip(
                                  context,
                                  Icons.inventory_2,
                                  Text(
                                    'Qty: ${totalQuantity.toStringAsFixed(1)}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (hasMore)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.paddingS),
            child: Text(
              '... and ${spendingByItem.length - maxItemsToShow} more items',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, Widget child) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.paddingXS,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Flexible(child: child),
        ],
      ),
    );
  }
}
