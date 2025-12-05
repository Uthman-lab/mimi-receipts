import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/shared.dart';
import '../../../../../modules/receipt/domain/entities/receipt_item.dart';
import '../../../../../core/constants/categories.dart';

class ReceiptForm extends StatefulWidget {
  final TextEditingController shopNameController;
  final DateTime? initialDate;
  final ValueChanged<DateTime> onDateChanged;
  final List<ReceiptItem> items;
  final ValueChanged<List<ReceiptItem>> onItemsChanged;

  const ReceiptForm({
    super.key,
    required this.shopNameController,
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

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  double get totalAmount {
    return widget.items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: AppStrings.shopName,
          controller: widget.shopNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
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
    final descriptionController = TextEditingController();
    final unitPriceController = TextEditingController();
    String selectedCategory = Categories.food;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.addItem),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: AppStrings.description,
                controller: descriptionController,
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
                controller: quantityController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                controller: unitPriceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                decoration: const InputDecoration(labelText: AppStrings.category),
                items: Categories.all.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedCategory = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text);
              final unitPrice = double.tryParse(unitPriceController.text);
              
              if (quantity == null || unitPrice == null || descriptionController.text.isEmpty) {
                return;
              }

              final amount = quantity * unitPrice;
              final newItem = ReceiptItem(
                receiptId: 0,
                quantity: quantity,
                description: descriptionController.text,
                unitPrice: unitPrice,
                amount: amount,
                category: selectedCategory,
              );

              final newItems = List<ReceiptItem>.from(widget.items);
              newItems.add(newItem);
              widget.onItemsChanged(newItems);

              Navigator.pop(dialogContext);
            },
            child: const Text(AppStrings.add),
          ),
        ],
      ),
    );
  }
}

