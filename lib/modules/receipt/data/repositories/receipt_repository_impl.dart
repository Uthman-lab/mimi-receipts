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
      shopId: receipt.shopId,
      shopName: receipt.shopName,
      date: receipt.date,
      totalAmount: receipt.totalAmount,
      items: receipt.items
          .map(
            (item) => ReceiptItemModel(
              receiptId: 0, // Will be set after receipt is inserted
              quantity: item.quantity,
              description: item.description,
              unitPrice: item.unitPrice,
              amount: item.amount,
              category: item.category,
            ),
          )
          .toList(),
    );
    final id = await localDataSource.insertReceipt(receiptModel);

    // Update receipt items with the new receipt ID
    final updatedItems = receiptModel.items
        .map(
          (item) => ReceiptItemModel(
            receiptId: id,
            quantity: item.quantity,
            description: item.description,
            unitPrice: item.unitPrice,
            amount: item.amount,
            category: item.category,
          ),
        )
        .toList();

    final updatedReceipt = ReceiptModel(
      id: id,
      shopId: receiptModel.shopId,
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
    if (receipt.id == null)
      throw Exception('Receipt ID is required for update');

    final receiptModel = ReceiptModel(
      id: receipt.id,
      shopId: receipt.shopId,
      shopName: receipt.shopName,
      date: receipt.date,
      totalAmount: receipt.totalAmount,
      items: receipt.items
          .map(
            (item) => ReceiptItemModel(
              id: item.id,
              receiptId: receipt.id!,
              quantity: item.quantity,
              description: item.description,
              unitPrice: item.unitPrice,
              amount: item.amount,
              category: item.category,
            ),
          )
          .toList(),
    );
    await localDataSource.updateReceipt(receiptModel);
  }

  @override
  Future<void> deleteReceipt(int id) async {
    await localDataSource.deleteReceipt(id);
  }

  @override
  Future<Map<String, dynamic>> getStatistics({int? shopId}) async {
    return await localDataSource.getStatistics(shopId: shopId);
  }

  @override
  Future<List<Map<String, dynamic>>> getPriceHistory(
    String itemDescription,
  ) async {
    return await localDataSource.getPriceHistory(itemDescription);
  }

  @override
  Future<List<String>> getShopNames() async {
    return await localDataSource.getShopNames();
  }

  @override
  Future<List<String>> getItemNames() async {
    return await localDataSource.getItemNames();
  }

  @override
  Future<double?> getLastItemPrice(String itemName) async {
    return await localDataSource.getLastItemPrice(itemName);
  }

  @override
  Future<List<Shop>> getShops() async {
    return await localDataSource.getShops();
  }

  @override
  Future<Shop?> getShopById(int id) async {
    return await localDataSource.getShopById(id);
  }

  @override
  Future<int> addShop(Shop shop) async {
    final shopModel = ShopModel(
      name: shop.name,
      address: shop.address,
      tel: shop.tel,
    );
    return await localDataSource.insertShop(shopModel);
  }

  @override
  Future<void> updateShop(Shop shop) async {
    if (shop.id == null) throw Exception('Shop ID is required for update');
    final shopModel = ShopModel(
      id: shop.id,
      name: shop.name,
      address: shop.address,
      tel: shop.tel,
    );
    await localDataSource.updateShop(shopModel);
  }

  @override
  Future<void> deleteShop(int id) async {
    await localDataSource.deleteShop(id);
  }

  @override
  Future<List<Receipt>> getReceiptsByShopId(int shopId) async {
    return await localDataSource.getReceiptsByShopId(shopId);
  }

  @override
  Future<List<Category>> getCategories() async {
    return await localDataSource.getCategories();
  }

  @override
  Future<Category?> getCategoryById(int id) async {
    return await localDataSource.getCategoryById(id);
  }

  @override
  Future<int> addCategory(Category category) async {
    final categoryModel = CategoryModel(
      name: category.name,
      color: category.color,
    );
    return await localDataSource.insertCategory(categoryModel);
  }

  @override
  Future<void> updateCategory(Category category) async {
    if (category.id == null)
      throw Exception('Category ID is required for update');
    final categoryModel = CategoryModel(
      id: category.id,
      name: category.name,
      color: category.color,
    );
    await localDataSource.updateCategory(categoryModel);
  }

  @override
  Future<void> deleteCategory(int id) async {
    await localDataSource.deleteCategory(id);
  }

  @override
  Future<bool> categoryHasReceiptItems(int categoryId) async {
    return await localDataSource.categoryHasReceiptItems(categoryId);
  }
}
