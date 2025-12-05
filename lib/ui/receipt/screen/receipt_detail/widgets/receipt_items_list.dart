import 'package:flutter/material.dart';
import '../../../../../modules/receipt/domain/entities/receipt_item.dart';
import '../../../../shared/shared.dart';

class ReceiptItemsList extends StatelessWidget {
  final List<ReceiptItem> items;

  const ReceiptItemsList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.shopping_cart_outlined,
        message: AppStrings.noItemsMessage,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.items,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.paddingM),
        ...items.map((item) => ItemRow(item: item)),
      ],
    );
  }
}

