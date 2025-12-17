import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/category.dart';
import '../../../../core/di/injection.dart';
import '../../../../modules/receipt/domain/usecases/usecases.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/category_list_item.dart';
import '../../shared/constants/constants.dart';
import 'add_category_dialog.dart';

class CategoryManagementSheet extends StatefulWidget {
  final Category? selectedCategory;
  final ValueChanged<Category?> onCategorySelected;

  const CategoryManagementSheet({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  State<CategoryManagementSheet> createState() => _CategoryManagementSheetState();
}

class _CategoryManagementSheetState extends State<CategoryManagementSheet> {
  List<Category> _categories = [];
  bool _isLoading = true;
  Map<int, bool> _categoryHasReceiptItems = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final getCategories = getIt<GetCategories>();
      final categories = await getCategories();
      
      // Check which categories have receipt items
      final categoryHasReceiptItems = getIt<CategoryHasReceiptItems>();
      final receiptItemsMap = <int, bool>{};
      
      for (final category in categories) {
        if (category.id != null) {
          final hasItems = await categoryHasReceiptItems(category.id!);
          receiptItemsMap[category.id!] = hasItems;
        }
      }

      setState(() {
        _categories = categories;
        _categoryHasReceiptItems = receiptItemsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddCategoryDialog({Category? category}) async {
    final result = await showDialog<Category>(
      context: context,
      builder: (context) => AddCategoryDialog(category: category),
    );

    if (result != null && mounted) {
      try {
        if (category != null) {
          // Update existing category
          final updateCategory = getIt<UpdateCategory>();
          await updateCategory(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.categoryUpdated)),
          );
        } else {
          // Add new category
          final addCategory = getIt<AddCategory>();
          await addCategory(result);
        }
        await _loadCategories();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteCategory(Category category) async {
    if (category.id == null) return;

    final hasReceiptItems = _categoryHasReceiptItems[category.id] ?? false;
    if (hasReceiptItems) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.categoryHasReceiptItems)),
      );
      return;
    }

    try {
      final deleteCategory = getIt<DeleteCategory>();
      await deleteCategory(category.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.categoryDeleted)),
        );
        await _loadCategories();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.manageCategories,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddCategoryDialog(),
                      tooltip: AppStrings.addCategory,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _categories.isEmpty
                        ? Center(
                            child: EmptyState(
                              icon: Icons.category,
                              message: AppStrings.noCategoriesMessage,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              final hasReceiptItems = _categoryHasReceiptItems[category.id] ?? false;
                              final isSelected = widget.selectedCategory?.id == category.id;

                              return Card(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : null,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: CategoryListItem(
                                  category: category,
                                  canDelete: !hasReceiptItems,
                                  onTap: () {
                                    widget.onCategorySelected(category);
                                    Navigator.pop(context);
                                  },
                                  onEdit: () => _showAddCategoryDialog(category: category),
                                  onDelete: () => _deleteCategory(category),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}



