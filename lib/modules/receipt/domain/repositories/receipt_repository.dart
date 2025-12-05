import '../entities/entities.dart';

abstract class ReceiptRepository {
  Future<List<Receipt>> getReceipts();
  Future<Receipt?> getReceiptById(int id);
  Future<int> addReceipt(Receipt receipt);
  Future<void> updateReceipt(Receipt receipt);
  Future<void> deleteReceipt(int id);
  Future<Map<String, dynamic>> getStatistics({int? shopId});
  Future<List<Map<String, dynamic>>> getPriceHistory(String itemDescription);
  Future<List<String>> getShopNames();
  Future<List<String>> getItemNames();
  Future<double?> getLastItemPrice(String itemName);
  
  // Shop methods
  Future<List<Shop>> getShops();
  Future<Shop?> getShopById(int id);
  Future<int> addShop(Shop shop);
  Future<void> updateShop(Shop shop);
  Future<void> deleteShop(int id);
  Future<List<Receipt>> getReceiptsByShopId(int shopId);
  
  // Category methods
  Future<List<Category>> getCategories();
  Future<Category?> getCategoryById(int id);
  Future<int> addCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(int id);
  Future<bool> categoryHasReceiptItems(int categoryId);
}

