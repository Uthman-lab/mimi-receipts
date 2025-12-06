import 'package:flutter/material.dart';
import '../../../modules/receipt/domain/entities/receipt_item.dart';
import '../constants/constants.dart';
import 'category_chip.dart';
import 'price_display.dart';

class ItemRow extends StatelessWidget {
  final ReceiptItem item;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ItemRow({
    super.key,
    required this.item,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingS),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: AppSpacing.edgeInsetsM,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.paddingXS),
                    Row(
                      children: [
                        CategoryChip(category: item.category),
                        const SizedBox(width: AppSpacing.paddingS),
                        Text(
                          'Qty: ${item.quantity.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(width: AppSpacing.paddingS),
                        Text(
                          '@ ${PriceDisplay.format(item.unitPrice)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceDisplay(amount: item.amount),
                  if (onDelete != null) ...[
                    const SizedBox(height: AppSpacing.paddingXS),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: AppSizes.iconS),
                      onPressed: onDelete,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



