import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/category.dart';
import '../../../core/theme/colors.dart';
import '../constants/constants.dart';

class CategoryListItem extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool canDelete;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.canDelete = true,
  });

  Future<void> _handleDelete(BuildContext context) async {
    if (!canDelete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.categoryHasReceiptItems)),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.deleteCategoryConfirm),
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
    final categoryColor = AppColors.getCategoryColor(category.name);

    return Dismissible(
      key: Key('category_${category.id}'),
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
              const SnackBar(content: Text(AppStrings.categoryHasReceiptItems)),
            );
            return false;
          }
          return await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(AppStrings.delete),
                  content: const Text(AppStrings.deleteCategoryConfirm),
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
              ) ??
              false;
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
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: categoryColor, width: 2),
          ),
          child: Center(
            child: Text(
              category.name[0].toUpperCase(),
              style: TextStyle(
                color: categoryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium,
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
                        const SnackBar(
                          content: Text(AppStrings.categoryHasReceiptItems),
                        ),
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


