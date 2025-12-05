import 'package:flutter/material.dart';
import '../../../../../modules/receipt/domain/entities/receipt.dart';
import '../../../../shared/shared.dart';
import '../../../../../core/utils/utils.dart';

class ReceiptCard extends StatelessWidget {
  final Receipt receipt;
  final VoidCallback onTap;

  const ReceiptCard({
    super.key,
    required this.receipt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  receipt.shopName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              PriceDisplay(amount: receipt.totalAmount),
            ],
          ),
          const SizedBox(height: AppSpacing.paddingS),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: AppSizes.iconS,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.paddingXS),
              Text(
                DateFormatter.formatForDisplay(receipt.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: AppSpacing.paddingM),
              Icon(
                Icons.shopping_bag,
                size: AppSizes.iconS,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.paddingXS),
              Text(
                '${receipt.items.length} ${receipt.items.length == 1 ? 'item' : 'items'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

