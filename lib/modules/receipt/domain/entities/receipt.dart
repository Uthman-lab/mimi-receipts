import 'receipt_item.dart';

class Receipt {
  final int? id;
  final String shopName;
  final DateTime date;
  final double totalAmount;
  final List<ReceiptItem> items;

  const Receipt({
    this.id,
    required this.shopName,
    required this.date,
    required this.totalAmount,
    required this.items,
  });

  Receipt copyWith({
    int? id,
    String? shopName,
    DateTime? date,
    double? totalAmount,
    List<ReceiptItem>? items,
  }) {
    return Receipt(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
    );
  }
}

