import '../../domain/entities/receipt_item.dart';

class ReceiptItemModel extends ReceiptItem {
  const ReceiptItemModel({
    super.id,
    required super.receiptId,
    required super.quantity,
    required super.description,
    required super.unitPrice,
    required super.amount,
    required super.category,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      id: json['id'] as int?,
      receiptId: json['receipt_id'] as int,
      quantity: (json['quantity'] as num).toDouble(),
      description: json['description'] as String,
      unitPrice: (json['unit_price'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'receipt_id': receiptId,
      'quantity': quantity,
      'description': description,
      'unit_price': unitPrice,
      'amount': amount,
      'category': category,
    };
  }
}



