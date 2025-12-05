import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'empty_state.dart';

class SearchableItemDropdown extends FormField<String> {
  SearchableItemDropdown({
    super.key,
    String? selectedItem,
    required ValueChanged<String?> onItemSelected,
    String? Function(String?)? validator,
    required List<String> items,
    bool enabled = true,
    required String label,
    String? hint,
  }) : super(
          initialValue: selectedItem,
          validator: validator,
          enabled: enabled,
          builder: (FormFieldState<String> state) {
            return _SearchableItemDropdownWidget(
              selectedItem: state.value ?? selectedItem,
              onItemSelected: (item) {
                state.didChange(item);
                onItemSelected(item);
              },
              items: items,
              enabled: enabled,
              label: label,
              hint: hint,
              errorText: state.errorText,
            );
          },
        );
}

class _SearchableItemDropdownWidget extends StatelessWidget {
  final String? selectedItem;
  final ValueChanged<String?> onItemSelected;
  final List<String> items;
  final bool enabled;
  final String label;
  final String? hint;
  final String? errorText;

  const _SearchableItemDropdownWidget({
    required this.selectedItem,
    required this.onItemSelected,
    required this.items,
    required this.enabled,
    required this.label,
    this.hint,
    this.errorText,
  });

  Future<void> _showItemSelectionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useRootNavigator: true,
      builder: (sheetContext) => _ItemSelectionSheet(
        items: items,
        selectedItem: selectedItem,
        onItemSelected: (item) {
          // Navigation is handled directly in the widget
        },
      ),
    );

    if (result != null) {
      onItemSelected(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showItemSelectionSheet(context) : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint ?? AppStrings.selectItem,
          suffixIcon: enabled
              ? const Icon(Icons.arrow_drop_down)
              : null,
          enabled: enabled,
          errorText: errorText,
        ),
        child: Text(
          selectedItem ?? (hint ?? AppStrings.selectItem),
          style: TextStyle(
            color: selectedItem != null
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _ItemSelectionSheet extends StatefulWidget {
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onItemSelected;

  const _ItemSelectionSheet({
    required this.items,
    this.selectedItem,
    required this.onItemSelected,
  });

  @override
  State<_ItemSelectionSheet> createState() => _ItemSelectionSheetState();
}

class _ItemSelectionSheetState extends State<_ItemSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasSearchText = false;
  BuildContext? _sheetContext;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
    // Auto-focus search field when sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _hasSearchText = _searchController.text.isNotEmpty;
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => item.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  bool get _shouldShowAddNewItem {
    if (!_hasSearchText) return false;
    final searchText = _searchController.text.trim();
    if (searchText.isEmpty) return false;
    // Show "Add new item" if search text doesn't exactly match any item
    return !widget.items.any((item) => item.toLowerCase() == searchText.toLowerCase());
  }

  Future<void> _showAddNewItemDialog(BuildContext context) async {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.addItem),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: AppStrings.description,
              hintText: AppStrings.description,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppStrings.fieldRequired;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, textController.text.trim());
              }
            },
            child: const Text(AppStrings.add),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && mounted && _sheetContext != null) {
      Navigator.of(_sheetContext!, rootNavigator: true).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    _sheetContext = context;
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (sheetBuilderContext, scrollController) {
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
                      AppStrings.selectItem,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddNewItemDialog(sheetBuilderContext),
                      tooltip: AppStrings.addItem,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    labelText: AppStrings.searchItem,
                    hintText: AppStrings.searchItem,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _hasSearchText
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              Expanded(
                child: _filteredItems.isEmpty && !_shouldShowAddNewItem
                    ? Center(
                        child: EmptyState(
                          icon: Icons.search_off,
                          message: 'No items found',
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(8),
                        itemCount: _shouldShowAddNewItem ? _filteredItems.length + 1 : _filteredItems.length,
                        itemBuilder: (context, index) {
                          // Show "Add new item" option at the top
                          if (_shouldShowAddNewItem && index == 0) {
                            return Card(
                              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: ListTile(
                                leading: Icon(
                                  Icons.add_circle_outline,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                title: Text(
                                  'Add "${_searchController.text.trim()}"',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                onTap: () {
                                  if (mounted && _sheetContext != null) {
                                    Navigator.of(_sheetContext!, rootNavigator: true).pop(_searchController.text.trim());
                                  }
                                },
                              ),
                            );
                          }

                          // Adjust index if "Add new item" is shown
                          final itemIndex = _shouldShowAddNewItem ? index - 1 : index;
                          final item = _filteredItems[itemIndex];
                          final isSelected = widget.selectedItem == item;

                          return Card(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(item),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(context).colorScheme.primary,
                                    )
                                  : null,
                              onTap: () {
                                if (mounted && _sheetContext != null) {
                                  Navigator.of(_sheetContext!, rootNavigator: true).pop(item);
                                }
                              },
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

