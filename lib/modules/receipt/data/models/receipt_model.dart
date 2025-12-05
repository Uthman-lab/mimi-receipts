import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_item.dart';
import 'receipt_item_model.dart';

class ReceiptModel extends Receipt {
  const ReceiptModel({
    super.id,
    required super.shopName,
    required super.date,
    required super.totalAmount,
    required super.items,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) {
    return ReceiptModel(
      id: json['id'] as int?,
      shopName: json['shop_name'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => ReceiptItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'items': items.map((item) => (item as ReceiptItemModel).toJson()).toList(),
    };
  }

  Map<String, dynamic> toDatabaseJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'date': date.toIso8601String().split('T')[0], // Store only date part
      'total_amount': totalAmount,
    };
  }

  factory ReceiptModel.fromDatabaseJson(Map<String, dynamic> json, List<ReceiptItem> items) {
    return ReceiptModel(
      id: json['id'] as int,
      shopName: json['shop_name'] as String,
      date: DateTime.parse(json['date'] as String),
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: items,
    );
  }
}

