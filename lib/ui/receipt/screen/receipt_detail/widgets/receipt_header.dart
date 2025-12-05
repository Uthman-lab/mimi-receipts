import 'package:flutter/material.dart';
import '../../../../../modules/receipt/domain/entities/receipt.dart';
import '../../../../shared/shared.dart';
import '../../../../../core/utils/utils.dart';

class ReceiptHeader extends StatelessWidget {
  final Receipt receipt;

  const ReceiptHeader({
    super.key,
    required this.receipt,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  receipt.shopName,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              PriceDisplay(
                amount: receipt.totalAmount,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.paddingM),
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
            ],
          ),
        ],
      ),
    );
  }
}

