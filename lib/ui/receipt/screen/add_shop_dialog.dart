import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/shop.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/constants/constants.dart';

class AddShopDialog extends StatefulWidget {
  const AddShopDialog({super.key});

  @override
  State<AddShopDialog> createState() => _AddShopDialogState();
}

class _AddShopDialogState extends State<AddShopDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _telController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _telController.dispose();
    super.dispose();
  }

  void _saveShop() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final shop = Shop(
      name: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty 
          ? null 
          : _addressController.text.trim(),
      tel: _telController.text.trim().isEmpty 
          ? null 
          : _telController.text.trim(),
    );

    Navigator.pop(context, shop);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(AppStrings.addShop),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: AppStrings.shopName,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.paddingM),
              AppTextField(
                label: AppStrings.address,
                controller: _addressController,
                maxLines: 2,
              ),
              const SizedBox(height: AppSpacing.paddingM),
              AppTextField(
                label: AppStrings.tel,
                controller: _telController,
                keyboardType: TextInputType.phone,
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
          onPressed: _saveShop,
          child: const Text(AppStrings.add),
        ),
      ],
    );
  }
}

