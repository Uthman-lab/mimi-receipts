import '../../domain/entities/entities.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/datasources.dart';
import '../models/models.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptLocalDataSource localDataSource;

  ReceiptRepositoryImpl(this.localDataSource);

  @override
  Future<List<Receipt>> getReceipts() async {
    return await localDataSource.getReceipts();
  }

  @override
  Future<Receipt?> getReceiptById(int id) async {
    return await localDataSource.getReceiptById(id);
  }

  @override
  Future<int> addReceipt(Receipt receipt) async {
    final receiptModel = ReceiptModel(
      shopName: receipt.shopName,
      date: receipt.date,
      totalAmount: receipt.totalAmount,
      items: receipt.items.map((item) => ReceiptItemModel(
        receiptId: 0, // Will be set after receipt is inserted
        quantity: item.quantity,
        description: item.description,
        unitPrice: item.unitPrice,
        amount: item.amount,
        category: item.category,
      )).toList(),
    );
    final id = await localDataSource.insertReceipt(receiptModel);
    
    // Update receipt items with the new receipt ID
    final updatedItems = receiptModel.items.map((item) => 
      ReceiptItemModel(
        receiptId: id,
        quantity: item.quantity,
        description: item.description,
        unitPrice: item.unitPrice,
        amount: item.amount,
        category: item.category,
      )
    ).toList();
    
    final updatedReceipt = ReceiptModel(
      id: id,
      shopName: receiptModel.shopName,
      date: receiptModel.date,
      totalAmount: receiptModel.totalAmount,
      items: updatedItems,
    );
    
    await localDataSource.updateReceipt(updatedReceipt);
    return id;
  }

  @override
  Future<void> updateReceipt(Receipt receipt) async {
    if (receipt.id == null) throw Exception('Receipt ID is required for update');
    
    final receiptModel = ReceiptModel(
      id: receipt.id,
      shopName: receipt.shopName,
      date: receipt.date,
      totalAmount: receipt.totalAmount,
      items: receipt.items.map((item) => ReceiptItemModel(
        id: item.id,
        receiptId: receipt.id!,
        quantity: item.quantity,
        description: item.description,
        unitPrice: item.unitPrice,
        amount: item.amount,
        category: item.category,
      )).toList(),
    );
    await localDataSource.updateReceipt(receiptModel);
  }

  @override
  Future<void> deleteReceipt(int id) async {
    await localDataSource.deleteReceipt(id);
  }

  @override
  Future<Map<String, dynamic>> getStatistics() async {
    return await localDataSource.getStatistics();
  }

  @override
  Future<List<Map<String, dynamic>>> getPriceHistory(String itemDescription) async {
    return await localDataSource.getPriceHistory(itemDescription);
  }
}

