import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/shared.dart';
import '../../../../../modules/receipt/domain/entities/receipt_item.dart';
import '../../../../../modules/receipt/domain/entities/shop.dart';
import '../../../../../modules/receipt/domain/entities/category.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../modules/receipt/domain/usecases/usecases.dart';
import '../../../screen/category_management_sheet.dart';

class ReceiptForm extends StatefulWidget {
  final Shop? selectedShop;
  final ValueChanged<Shop?> onShopChanged;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final List<ReceiptItem> items;
  final ValueChanged<List<ReceiptItem>> onItemsChanged;

  const ReceiptForm({
    super.key,
    this.selectedShop,
    required this.onShopChanged,
    this.initialDate,
    required this.onDateChanged,
    required this.items,
    required this.onItemsChanged,
  });

  @override
  State<ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<ReceiptForm> {
  DateTime? _selectedDate;
  List<String> _itemNames = [];
  bool _isLoadingItemNames = true;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadItemNames();
    _loadCategories();
  }

  Future<void> _loadItemNames() async {
    try {
      final getItemNames = getIt<GetItemNames>();
      final items = await getItemNames();
      setState(() {
        _itemNames = items;
        _isLoadingItemNames = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingItemNames = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final getCategories = getIt<GetCategories>();
      final categories = await getCategories();
      setState(() {
        _categories = categories;
        _selectedCategoryName = categories.isNotEmpty
            ? categories.first.name
            : null;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  double get totalAmount {
    return widget.items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShopDropdownField(
          selectedShop: widget.selectedShop,
          onShopSelected: widget.onShopChanged,
          validator: (shop) {
            if (shop == null) {
              return AppStrings.fieldRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.paddingM),
        DatePickerField(
          label: AppStrings.date,
          initialDate: _selectedDate,
          onDateSelected: (date) {
            setState(() {
              _selectedDate = date;
            });
            widget.onDateChanged(date);
          },
          validator: (value) {
            if (_selectedDate == null) {
              return AppStrings.fieldRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: AppSpacing.paddingL),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.items,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            AppButton(
              label: AppStrings.addItem,
              variant: AppButtonVariant.outlined,
              width: 120,
              height: AppSizes.buttonHeightS,
              onPressed: () => _showAddItemDialog(context),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.paddingM),
        if (widget.items.isEmpty)
          EmptyState(
            icon: Icons.shopping_cart_outlined,
            message: AppStrings.noItemsMessage,
          )
        else
          ...widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return ItemRow(
              item: item,
              onDelete: () {
                final newItems = List<ReceiptItem>.from(widget.items);
                newItems.removeAt(index);
                widget.onItemsChanged(newItems);
              },
            );
          }),
        if (widget.items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.paddingL),
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.totalAmount,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                PriceDisplay(
                  amount: totalAmount,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final unitPriceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedCategory = _selectedCategoryName;

    showDialog(
      context: context,
      builder: (dialogContext) => _AddItemDialogContent(
        formKey: formKey,
        itemNames: _itemNames,
        isLoadingItemNames: _isLoadingItemNames,
        categories: _categories,
        isLoadingCategories: _isLoadingCategories,
        quantityController: quantityController,
        unitPriceController: unitPriceController,
        selectedCategory: selectedCategory,
        onCategoryChanged: (category) {
          selectedCategory = category;
        },
        onManageCategories: () async {
          Navigator.pop(dialogContext);
          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => CategoryManagementSheet(
              onCategorySelected: (category) {
                // Category selected, but we don't need to do anything here
                // The dialog will be reopened with updated categories
              },
            ),
          );
          // Reload categories after management sheet is closed
          await _loadCategories();
          // Reopen the add item dialog
          _showAddItemDialog(context);
        },
        onItemAdded: (newItemName) {
          // Add new item to the local list if it doesn't exist
          if (!_itemNames.contains(newItemName)) {
            setState(() {
              _itemNames.add(newItemName);
              _itemNames.sort(); // Keep sorted
            });
          }
        },
        onAdd: (selectedItem) {
          final quantity = double.tryParse(quantityController.text);
          final unitPrice = double.tryParse(unitPriceController.text);

          if (quantity == null ||
              unitPrice == null ||
              selectedItem.isEmpty ||
              selectedCategory == null) {
            return;
          }

          final amount = quantity * unitPrice;
          final newItem = ReceiptItem(
            receiptId: 0,
            quantity: quantity,
            description: selectedItem,
            unitPrice: unitPrice,
            amount: amount,
            category: selectedCategory!,
          );

          final newItems = List<ReceiptItem>.from(widget.items);
          newItems.add(newItem);
          widget.onItemsChanged(newItems);

          Navigator.pop(dialogContext);
        },
      ),
    );
  }
}

class _AddItemDialogContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<String> itemNames;
  final bool isLoadingItemNames;
  final List<Category> categories;
  final bool isLoadingCategories;
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final VoidCallback onManageCategories;
  final ValueChanged<String> onItemAdded;
  final ValueChanged<String> onAdd;

  const _AddItemDialogContent({
    required this.formKey,
    required this.itemNames,
    required this.isLoadingItemNames,
    required this.categories,
    required this.isLoadingCategories,
    required this.quantityController,
    required this.unitPriceController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onManageCategories,
    required this.onItemAdded,
    required this.onAdd,
  });

  @override
  State<_AddItemDialogContent> createState() => _AddItemDialogContentState();
}

class _AddItemDialogContentState extends State<_AddItemDialogContent> {
  String? selectedItem;
  late List<String> _currentItemNames;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _currentItemNames = List<String>.from(widget.itemNames);
    selectedCategory = widget.selectedCategory;
  }

  void handleItemSelected(String? item) {
    setState(() {
      selectedItem = item;
    });
    if (item != null) {
      // Check if this is a new item not in the list
      if (!_currentItemNames.contains(item)) {
        widget.onItemAdded(item);
        setState(() {
          _currentItemNames.add(item);
          _currentItemNames.sort(); // Keep sorted
        });
      }

      // Auto-fill unit price when item is selected
      getIt<GetLastItemPrice>()(item)
          .then((lastPrice) {
            if (lastPrice != null && mounted) {
              widget.unitPriceController.text = lastPrice.toStringAsFixed(2);
            }
          })
          .catchError((e) {
            // Ignore errors, user can still enter price manually
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addItem),
      content: SingleChildScrollView(
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SearchableItemDropdown(
                key: ValueKey('${selectedItem}_${_currentItemNames.length}'),
                selectedItem: selectedItem,
                onItemSelected: handleItemSelected,
                items: _currentItemNames,
                enabled: !widget.isLoadingItemNames,
                label: AppStrings.description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.paddingM),
              AppTextField(
                label: AppStrings.quantity,
                controller: widget.quantityController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (double.tryParse(value) == null) {
                    return AppStrings.invalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.paddingM),
              AppTextField(
                label: AppStrings.unitPrice,
                controller: widget.unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  if (double.tryParse(value) == null) {
                    return AppStrings.invalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.paddingM),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: AppStrings.category,
                      ),
                      items: widget.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.name,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: widget.isLoadingCategories
                          ? null
                          : (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                              widget.onCategoryChanged(value);
                            },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.fieldRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: widget.onManageCategories,
                    tooltip: AppStrings.manageCategories,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(AppStrings.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (!widget.formKey.currentState!.validate()) {
              return;
            }

            if (selectedItem == null || selectedItem!.isEmpty) {
              return;
            }

            widget.onAdd(selectedItem!);
          },
          child: const Text(AppStrings.add),
        ),
      ],
    );
  }
}
