import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/shared.dart';
import '../../../../../modules/receipt/domain/entities/receipt_item.dart';
import '../../../../../modules/receipt/domain/entities/shop.dart';
import '../../../../../core/constants/categories.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../modules/receipt/domain/usecases/usecases.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _loadItemNames();
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
    String selectedCategory = Categories.food;

    showDialog(
      context: context,
      builder: (dialogContext) => _AddItemDialogContent(
        formKey: formKey,
        itemNames: _itemNames,
        isLoadingItemNames: _isLoadingItemNames,
        quantityController: quantityController,
        unitPriceController: unitPriceController,
        selectedCategory: selectedCategory,
        onCategoryChanged: (category) {
          selectedCategory = category;
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

          if (quantity == null || unitPrice == null || selectedItem.isEmpty) {
            return;
          }

          final amount = quantity * unitPrice;
          final newItem = ReceiptItem(
            receiptId: 0,
            quantity: quantity,
            description: selectedItem,
            unitPrice: unitPrice,
            amount: amount,
            category: selectedCategory,
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
  final TextEditingController quantityController;
  final TextEditingController unitPriceController;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onItemAdded;
  final ValueChanged<String> onAdd;

  const _AddItemDialogContent({
    required this.formKey,
    required this.itemNames,
    required this.isLoadingItemNames,
    required this.quantityController,
    required this.unitPriceController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onItemAdded,
    required this.onAdd,
  });

  @override
  State<_AddItemDialogContent> createState() => _AddItemDialogContentState();
}

class _AddItemDialogContentState extends State<_AddItemDialogContent> {
  String? selectedItem;
  late List<String> _currentItemNames;
  String get selectedCategory => widget.selectedCategory;

  @override
  void initState() {
    super.initState();
    _currentItemNames = List<String>.from(widget.itemNames);
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
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: AppStrings.category,
                ),
                items: Categories.all.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.onCategoryChanged(value);
                  }
                },
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
