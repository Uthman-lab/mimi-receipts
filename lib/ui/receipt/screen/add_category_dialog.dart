import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/category.dart';
import '../../shared/widgets/app_text_field.dart';
import '../../shared/constants/constants.dart';

class AddCategoryDialog extends StatefulWidget {
  final Category? category;

  const AddCategoryDialog({super.key, this.category});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final category = Category(
      id: widget.category?.id,
      name: _nameController.text.trim(),
      color: widget.category?.color,
    );

    Navigator.pop(context, category);
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.category != null;
    return AlertDialog(
      title: Text(isEditMode ? AppStrings.editCategory : AppStrings.addCategory),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: AppStrings.categoryName,
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.fieldRequired;
                  }
                  return null;
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
          onPressed: _saveCategory,
          child: Text(isEditMode ? AppStrings.updateCategory : AppStrings.add),
        ),
      ],
    );
  }
}



