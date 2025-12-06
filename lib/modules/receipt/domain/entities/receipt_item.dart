class ReceiptItem {
  final int? id;
  final int receiptId;
  final double quantity;
  final String description;
  final double unitPrice;
  final double amount;
  final String category;

  const ReceiptItem({
    this.id,
    required this.receiptId,
    required this.quantity,
    required this.description,
    required this.unitPrice,
    required this.amount,
    required this.category,
  });

  ReceiptItem copyWith({
    int? id,
    int? receiptId,
    double? quantity,
    String? description,
    double? unitPrice,
    double? amount,
    String? category,
  }) {
    return ReceiptItem(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}



