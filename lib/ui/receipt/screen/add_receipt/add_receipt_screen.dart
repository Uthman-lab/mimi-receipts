import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../modules/receipt/domain/entities/receipt_item.dart';
import '../../../../modules/receipt/domain/entities/shop.dart';
import '../../../../core/di/injection.dart';
import '../../../../modules/receipt/domain/repositories/repositories.dart';
import '../../bloc/receipt_bloc.dart';
import '../../../shared/shared.dart';
import '../../../../modules/receipt/domain/entities/receipt.dart';
import 'widgets/widgets.dart';

class AddReceiptScreen extends StatefulWidget {
  final Receipt? receipt;

  const AddReceiptScreen({super.key, this.receipt});

  @override
  State<AddReceiptScreen> createState() => _AddReceiptScreenState();
}

class _AddReceiptScreenState extends State<AddReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  Shop? _selectedShop;
  DateTime? _selectedDate;
  List<ReceiptItem> _items = [];

  @override
  void initState() {
    super.initState();
    if (widget.receipt != null) {
      _selectedDate = widget.receipt!.date;
      _items = List.from(widget.receipt!.items);
      _loadShopForReceipt();
    } else {
      _selectedDate = DateTime.now();
    }
  }

  Future<void> _loadShopForReceipt() async {
    if (widget.receipt != null) {
      try {
        final repository = getIt<ReceiptRepository>();
        final shop = await repository.getShopById(widget.receipt!.shopId);
        setState(() {
          _selectedShop = shop;
        });
      } catch (e) {
        // If shop not found, create a temporary shop with just the name
        setState(() {
          _selectedShop = Shop(
            id: widget.receipt!.shopId,
            name: widget.receipt!.shopName,
          );
        });
      }
    }
  }

  double get _totalAmount {
    return _items.fold<double>(0.0, (sum, item) => sum + item.amount);
  }

  void _saveReceipt() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedShop == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a shop')));
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final receipt = Receipt(
      id: widget.receipt?.id,
      shopId: _selectedShop!.id!,
      shopName: _selectedShop!.name,
      date: _selectedDate!,
      totalAmount: _totalAmount,
      items: _items,
    );

    if (widget.receipt != null) {
      context.read<ReceiptBloc>().add(UpdateReceiptEvent(receipt));
    } else {
      context.read<ReceiptBloc>().add(AddReceiptEvent(receipt));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receipt != null
              ? AppStrings.editReceipt
              : AppStrings.addReceipt,
        ),
      ),
      body: BlocListener<ReceiptBloc, ReceiptState>(
        listener: (context, state) {
          if (state is ReceiptOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is ReceiptError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: AppSpacing.edgeInsetsM,
            child: ReceiptForm(
              selectedShop: _selectedShop,
              onShopChanged: (shop) {
                setState(() {
                  _selectedShop = shop;
                });
              },
              initialDate: _selectedDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              items: _items,
              onItemsChanged: (items) {
                setState(() {
                  _items = items;
                });
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: AppSpacing.edgeInsetsM,
        child: AppButton(label: AppStrings.save, onPressed: _saveReceipt),
      ),
    );
  }
}
