import 'package:flutter/material.dart';
import '../../../../modules/receipt/domain/entities/shop.dart';
import '../../../../core/di/injection.dart';
import '../../../../modules/receipt/domain/usecases/usecases.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/shop_list_item.dart';
import '../../shared/constants/constants.dart';
import 'add_shop_dialog.dart';

class ShopManagementSheet extends StatefulWidget {
  final Shop? selectedShop;
  final ValueChanged<Shop?> onShopSelected;

  const ShopManagementSheet({
    super.key,
    this.selectedShop,
    required this.onShopSelected,
  });

  @override
  State<ShopManagementSheet> createState() => _ShopManagementSheetState();
}

class _ShopManagementSheetState extends State<ShopManagementSheet> {
  List<Shop> _shops = [];
  bool _isLoading = true;
  Map<int, bool> _shopHasReceipts = {};

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final getShops = getIt<GetShops>();
      final shops = await getShops();
      
      // Check which shops have receipts
      final getReceiptsByShop = getIt<GetReceiptsByShop>();
      final receiptsMap = <int, bool>{};
      
      for (final shop in shops) {
        if (shop.id != null) {
          final receipts = await getReceiptsByShop(shop.id!);
          receiptsMap[shop.id!] = receipts.isNotEmpty;
        }
      }

      setState(() {
        _shops = shops;
        _shopHasReceipts = receiptsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddShopDialog({Shop? shop}) async {
    final result = await showDialog<Shop>(
      context: context,
      builder: (context) => AddShopDialog(shop: shop),
    );

    if (result != null && mounted) {
      try {
        if (shop != null) {
          // Update existing shop
          final updateShop = getIt<UpdateShop>();
          await updateShop(result);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.shopUpdated)),
          );
        } else {
          // Add new shop
          final addShop = getIt<AddShop>();
          await addShop(result);
        }
        await _loadShops();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }

  Future<void> _deleteShop(Shop shop) async {
    if (shop.id == null) return;

    final hasReceipts = _shopHasReceipts[shop.id] ?? false;
    if (hasReceipts) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.shopHasReceipts)),
      );
      return;
    }

    try {
      final deleteShop = getIt<DeleteShop>();
      await deleteShop(shop.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.shopDeleted)),
        );
        await _loadShops();
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
                      AppStrings.manageShops,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _showAddShopDialog(),
                      tooltip: AppStrings.addShop,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _shops.isEmpty
                        ? Center(
                            child: EmptyState(
                              icon: Icons.store,
                              message: AppStrings.noShopsMessage,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _shops.length,
                            itemBuilder: (context, index) {
                              final shop = _shops[index];
                              final hasReceipts = _shopHasReceipts[shop.id] ?? false;
                              final isSelected = widget.selectedShop?.id == shop.id;

                              return Card(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : null,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: ShopListItem(
                                  shop: shop,
                                  canDelete: !hasReceipts,
                                  onTap: () {
                                    widget.onShopSelected(shop);
                                    Navigator.pop(context);
                                  },
                                  onEdit: () => _showAddShopDialog(shop: shop),
                                  onDelete: () => _deleteShop(shop),
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

