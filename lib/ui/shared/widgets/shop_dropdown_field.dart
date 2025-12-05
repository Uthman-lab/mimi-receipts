import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/shop.dart';
import '../../../../core/di/injection.dart';
import '../../../../modules/receipt/domain/usecases/usecases.dart';
import '../../receipt/screen/add_shop_dialog.dart';
import '../../receipt/screen/shop_management_sheet.dart';
import '../constants/constants.dart';

class ShopDropdownField extends StatefulWidget {
  final Shop? selectedShop;
  final ValueChanged<Shop?> onShopSelected;
  final String? Function(Shop?)? validator;
  final bool enabled;

  const ShopDropdownField({
    super.key,
    this.selectedShop,
    required this.onShopSelected,
    this.validator,
    this.enabled = true,
  });

  @override
  State<ShopDropdownField> createState() => _ShopDropdownFieldState();
}

class _ShopDropdownFieldState extends State<ShopDropdownField> {
  List<Shop> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      final getShops = getIt<GetShops>();
      final shops = await getShops();
      setState(() {
        _shops = shops;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddShopDialog() async {
    final shop = await showDialog<Shop>(
      context: context,
      builder: (context) => const AddShopDialog(),
    );

    if (shop != null && mounted) {
      // Add the new shop
      try {
        final addShop = getIt<AddShop>();
        final shopId = await addShop(shop);

        // Reload shops and select the new one from the list
        await _loadShops();

        // Find the newly added shop from the reloaded list
        final newShop = _shops.firstWhere((s) => s.id == shopId);

        widget.onShopSelected(newShop);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Failed to add shop')));
        }
      }
    }
  }

  Future<void> _showShopManagementSheet() async {
    final result = await showModalBottomSheet<Shop?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShopManagementSheet(
        selectedShop: widget.selectedShop,
        onShopSelected: (shop) {
          Navigator.pop(context, shop);
        },
      ),
    );

    if (result != null && mounted) {
      await _loadShops();
      widget.onShopSelected(result);
    } else if (mounted) {
      // Reload shops in case they were edited/deleted
      await _loadShops();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Find the matching shop from the list to ensure object equality
    // DropdownButton requires the value to be the exact same instance as one in items
    Shop? selectedValue;
    if (widget.selectedShop != null && widget.selectedShop!.id != null) {
      try {
        selectedValue = _shops.firstWhere(
          (shop) => shop.id == widget.selectedShop!.id,
        );
      } catch (e) {
        // Shop not found in list, set to null (will show hint)
        selectedValue = null;
      }
    }

    return DropdownButtonFormField<Shop>(
      value: selectedValue,
      decoration: InputDecoration(
        labelText: AppStrings.shop,
        suffixIcon: widget.enabled
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _showShopManagementSheet,
                    tooltip: AppStrings.manageShops,
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _showAddShopDialog,
                    tooltip: AppStrings.addShop,
                  ),
                ],
              )
            : null,
      ),
      items: _shops.map((shop) {
        return DropdownMenuItem<Shop>(value: shop, child: Text(shop.name));
      }).toList(),
      onChanged: widget.enabled
          ? (Shop? shop) {
              if (shop != null) {
                widget.onShopSelected(shop);
              }
            }
          : null,
      validator: widget.validator != null
          ? (Shop? value) => widget.validator!(value)
          : null,
      isExpanded: true,
      hint: _isLoading
          ? const Text(AppStrings.loading)
          : const Text(AppStrings.selectShop),
    );
  }
}
