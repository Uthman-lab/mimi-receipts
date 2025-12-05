import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/shop.dart';
import '../constants/constants.dart';

class ShopListItem extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canDelete;

  const ShopListItem({
    super.key,
    required this.shop,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.canDelete = true,
  });

  Future<void> _handleDelete(BuildContext context) async {
    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.shopHasReceipts)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.deleteShopConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('shop_${shop.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue,
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: canDelete ? Colors.red : Colors.grey,
        child: Icon(
          Icons.delete,
          color: canDelete ? Colors.white : Colors.white70,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete action
          if (!canDelete) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text(AppStrings.shopHasReceipts)),
            );
            return false;
          }
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text(AppStrings.delete),
              content: const Text(AppStrings.deleteShopConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(AppStrings.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text(AppStrings.delete),
                ),
              ],
            ),
          ) ?? false;
        } else {
          // Edit action
          onEdit();
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart && canDelete) {
          onDelete();
        }
      },
      child: ListTile(
        title: Text(
          shop.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (shop.address != null && shop.address!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      shop.address!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
            if (shop.tel != null && shop.tel!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    shop.tel!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: AppStrings.edit,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: canDelete
                  ? () => _handleDelete(context)
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(AppStrings.shopHasReceipts)),
                      );
                    },
              tooltip: AppStrings.delete,
              color: canDelete ? Colors.red : Colors.grey,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

