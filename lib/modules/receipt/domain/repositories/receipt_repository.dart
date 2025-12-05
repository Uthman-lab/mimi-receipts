import '../entities/entities.dart';

abstract class ReceiptRepository {
  Future<List<Receipt>> getReceipts();
  Future<Receipt?> getReceiptById(int id);
  Future<int> addReceipt(Receipt receipt);
  Future<void> updateReceipt(Receipt receipt);
  Future<void> deleteReceipt(int id);
  Future<Map<String, dynamic>> getStatistics();
  Future<List<Map<String, dynamic>>> getPriceHistory(String itemDescription);
}

