import 'package:flutter/material.dart';

class AppAutocompleteField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final List<String> options;
  final void Function(String)? onSelected;
  final bool enabled;

  const AppAutocompleteField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    required this.options,
    this.onSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled || options.isEmpty) {
      return TextFormField(
        controller: controller,
        validator: validator,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
      );
    }

    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return options;
        }
        return options.where((option) =>
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        controller?.text = selection;
        onSelected?.call(selection);
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        if (controller != null) {
          textEditingController = controller!;
        }
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          validator: validator,
          enabled: enabled,
          onTap: enabled
              ? () {
                  // Ensure field is focused when tapped
                  focusNode.requestFocus();
                }
              : null,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: options.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    onPressed: enabled
                        ? () {
                            // Focus the field to trigger autocomplete overlay
                            focusNode.requestFocus();
                            // Workaround: Temporarily trigger text change to show overlay
                            // This ensures the autocomplete overlay appears when clicking dropdown
                            if (textEditingController.text.isEmpty) {
                              // Add and immediately remove a space to trigger overlay
                              textEditingController.text = ' ';
                              textEditingController.text = '';
                            }
                          }
                        : null,
                  )
                : null,
          ),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
    );
  }
}

