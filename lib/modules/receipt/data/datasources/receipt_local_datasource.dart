import '../database/database_helper.dart';
import '../models/models.dart';
import '../../domain/entities/entities.dart';

class ReceiptLocalDataSource {
  final DatabaseHelper databaseHelper;

  ReceiptLocalDataSource(this.databaseHelper);

  Future<List<ReceiptModel>> getReceipts() async {
    final db = await databaseHelper.database;
    final receipts = await db.query(tableReceipts, orderBy: '$columnDate DESC');

    final List<ReceiptModel> receiptList = [];
    for (var receiptMap in receipts) {
      final items = await getReceiptItems(receiptMap[columnId] as int);
      receiptList.add(ReceiptModel.fromDatabaseJson(receiptMap, items));
    }
    return receiptList;
  }

  Future<ReceiptModel?> getReceiptById(int id) async {
    final db = await databaseHelper.database;
    final receipts = await db.query(
      tableReceipts,
      where: '${columnId} = ?',
      whereArgs: [id],
    );

    if (receipts.isEmpty) return null;

    final receiptMap = receipts.first;
    final items = await getReceiptItems(id);
    return ReceiptModel.fromDatabaseJson(receiptMap, items);
  }

  Future<List<ReceiptItem>> getReceiptItems(int receiptId) async {
    final db = await databaseHelper.database;
    final items = await db.query(
      tableReceiptItems,
      where: '${columnReceiptId} = ?',
      whereArgs: [receiptId],
    );

    return items.map((item) => ReceiptItemModel.fromJson(item)).toList();
  }

  Future<int> insertReceipt(ReceiptModel receipt) async {
    final db = await databaseHelper.database;
    final receiptId = await db.insert(tableReceipts, receipt.toDatabaseJson());

    // Insert items
    for (var item in receipt.items) {
      await db.insert(tableReceiptItems, {
        columnReceiptId: receiptId,
        columnQuantity: item.quantity,
        columnDescription: item.description,
        columnUnitPrice: item.unitPrice,
        columnAmount: item.amount,
        columnCategory: item.category,
      });
    }

    return receiptId;
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    if (receipt.id == null)
      throw Exception('Receipt ID is required for update');

    final db = await databaseHelper.database;
    await db.update(
      tableReceipts,
      receipt.toDatabaseJson(),
      where: '${columnId} = ?',
      whereArgs: [receipt.id],
    );

    // Delete old items
    await db.delete(
      tableReceiptItems,
      where: '${columnReceiptId} = ?',
      whereArgs: [receipt.id],
    );

    // Insert new items
    for (var item in receipt.items) {
      await db.insert(tableReceiptItems, {
        columnReceiptId: receipt.id,
        columnQuantity: item.quantity,
        columnDescription: item.description,
        columnUnitPrice: item.unitPrice,
        columnAmount: item.amount,
        columnCategory: item.category,
      });
    }
  }

  Future<void> deleteReceipt(int id) async {
    final db = await databaseHelper.database;
    await db.delete(tableReceipts, where: '${columnId} = ?', whereArgs: [id]);
    // Items will be deleted automatically due to CASCADE
  }

  Future<Map<String, dynamic>> getStatistics({int? shopId}) async {
    final db = await databaseHelper.database;

    // Build WHERE clause for shop filtering
    final shopFilter = shopId != null ? 'WHERE ${columnShopId} = $shopId' : '';

    // Total spending
    final totalResult = await db.rawQuery(
      'SELECT SUM(${columnTotalAmount}) as total FROM ${tableReceipts} $shopFilter',
    );
    final totalSpending =
        (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Spending by category
    final categoryQuery = shopId != null
        ? '''
      SELECT ri.${columnCategory}, SUM(ri.${columnAmount}) as total
      FROM ${tableReceiptItems} ri
      JOIN ${tableReceipts} r ON ri.${columnReceiptId} = r.${columnId}
      WHERE r.${columnShopId} = ?
      GROUP BY ri.${columnCategory}
      '''
        : '''
      SELECT ${columnCategory}, SUM(${columnAmount}) as total
      FROM ${tableReceiptItems}
      GROUP BY ${columnCategory}
      ''';
    final categoryArgs = shopId != null ? [shopId] : [];
    final categoryResult = await db.rawQuery(categoryQuery, categoryArgs);
    final Map<String, double> spendingByCategory = {};
    for (var row in categoryResult) {
      spendingByCategory[row[columnCategory] as String] = (row['total'] as num)
          .toDouble();
    }

    // Spending by shop (only if not filtering by shop)
    final Map<String, double> spendingByShop = {};
    if (shopId == null) {
      final shopResult = await db.rawQuery('''
        SELECT ${columnShopName}, SUM(${columnTotalAmount}) as total
        FROM ${tableReceipts}
        GROUP BY ${columnShopName}
        ''');
      for (var row in shopResult) {
        spendingByShop[row[columnShopName] as String] = (row['total'] as num)
            .toDouble();
      }
    }

    // Monthly spending
    final monthlyQuery = shopId != null
        ? '''
      SELECT strftime('%Y-%m', ${columnDate}) as month, SUM(${columnTotalAmount}) as total
      FROM ${tableReceipts}
      WHERE ${columnShopId} = ?
      GROUP BY month
      ORDER BY month DESC
      '''
        : '''
      SELECT strftime('%Y-%m', ${columnDate}) as month, SUM(${columnTotalAmount}) as total
      FROM ${tableReceipts}
      GROUP BY month
      ORDER BY month DESC
      ''';
    final monthlyArgs = shopId != null ? [shopId] : [];
    final monthlyResult = await db.rawQuery(monthlyQuery, monthlyArgs);
    final Map<String, double> monthlySpending = {};
    for (var row in monthlyResult) {
      monthlySpending[row['month'] as String] = (row['total'] as num)
          .toDouble();
    }

    // Spending by item
    final itemQuery = shopId != null
        ? '''
      SELECT 
        ri.${columnDescription} as item_description,
        SUM(ri.${columnAmount}) as total_spent,
        COUNT(*) as purchase_count,
        AVG(ri.${columnUnitPrice}) as avg_price,
        SUM(ri.${columnQuantity}) as total_quantity
      FROM ${tableReceiptItems} ri
      JOIN ${tableReceipts} r ON ri.${columnReceiptId} = r.${columnId}
      WHERE r.${columnShopId} = ?
      GROUP BY ri.${columnDescription}
      ORDER BY total_spent DESC
      '''
        : '''
      SELECT 
        ${columnDescription} as item_description,
        SUM(${columnAmount}) as total_spent,
        COUNT(*) as purchase_count,
        AVG(${columnUnitPrice}) as avg_price,
        SUM(${columnQuantity}) as total_quantity
      FROM ${tableReceiptItems}
      GROUP BY ${columnDescription}
      ORDER BY total_spent DESC
      ''';
    final itemArgs = shopId != null ? [shopId] : [];
    final itemResult = await db.rawQuery(itemQuery, itemArgs);
    final List<Map<String, dynamic>> spendingByItem = [];
    for (var row in itemResult) {
      spendingByItem.add({
        'itemDescription': row['item_description'] as String,
        'totalSpent': (row['total_spent'] as num).toDouble(),
        'purchaseCount': row['purchase_count'] as int,
        'avgPrice': (row['avg_price'] as num).toDouble(),
        'totalQuantity': (row['total_quantity'] as num).toDouble(),
      });
    }

    // Additional insights
    final uniqueItemsCount = spendingByItem.length;
    final avgSpendingPerItem = uniqueItemsCount > 0
        ? totalSpending / uniqueItemsCount
        : 0.0;

    // Shop-specific insights (when filtering by shop)
    int? totalReceipts;
    double? avgReceiptAmount;
    if (shopId != null) {
      final receiptCountResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${tableReceipts} WHERE ${columnShopId} = ?',
        [shopId],
      );
      totalReceipts = receiptCountResult.first['count'] as int;
      avgReceiptAmount = totalReceipts > 0
          ? totalSpending / totalReceipts
          : 0.0;
    }

    // Monthly item spending
    final monthlyItemQuery = shopId != null
        ? '''
      SELECT 
        ri.${columnDescription} as item_description,
        strftime('%Y-%m', r.${columnDate}) as month,
        SUM(ri.${columnAmount}) as total_spent
      FROM ${tableReceiptItems} ri
      JOIN ${tableReceipts} r ON ri.${columnReceiptId} = r.${columnId}
      WHERE r.${columnShopId} = ?
      GROUP BY ri.${columnDescription}, month
      ORDER BY month ASC, total_spent DESC
      '''
        : '''
      SELECT 
        ri.${columnDescription} as item_description,
        strftime('%Y-%m', r.${columnDate}) as month,
        SUM(ri.${columnAmount}) as total_spent
      FROM ${tableReceiptItems} ri
      JOIN ${tableReceipts} r ON ri.${columnReceiptId} = r.${columnId}
      GROUP BY ri.${columnDescription}, month
      ORDER BY month ASC, total_spent DESC
      ''';
    final monthlyItemArgs = shopId != null ? [shopId] : [];
    final monthlyItemResult = await db.rawQuery(
      monthlyItemQuery,
      monthlyItemArgs,
    );

    // Organize monthly item data: Map<String, Map<String, double>>
    // Outer key: item description, Inner key: month, Value: spending amount
    final Map<String, Map<String, double>> monthlyItemSpending = {};
    for (var row in monthlyItemResult) {
      final itemDesc = row['item_description'] as String;
      final month = row['month'] as String;
      final amount = (row['total_spent'] as num).toDouble();

      monthlyItemSpending.putIfAbsent(itemDesc, () => {})[month] = amount;
    }

    return {
      'totalSpending': totalSpending,
      'spendingByCategory': spendingByCategory,
      'spendingByShop': spendingByShop,
      'monthlySpending': monthlySpending,
      'spendingByItem': spendingByItem,
      'monthlyItemSpending': monthlyItemSpending,
      'uniqueItemsCount': uniqueItemsCount,
      'avgSpendingPerItem': avgSpendingPerItem,
      if (shopId != null) 'totalReceipts': totalReceipts,
      if (shopId != null) 'avgReceiptAmount': avgReceiptAmount,
    };
  }

  Future<List<Map<String, dynamic>>> getPriceHistory(
    String itemDescription,
  ) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        r.${columnDate} as date,
        r.${columnShopName} as shop_name,
        ri.${columnUnitPrice} as unit_price,
        ri.${columnQuantity} as quantity
      FROM ${tableReceiptItems} ri
      JOIN ${tableReceipts} r ON ri.${columnReceiptId} = r.${columnId}
      WHERE LOWER(ri.${columnDescription}) LIKE LOWER(?)
      ORDER BY r.${columnDate} ASC
      ''',
      ['%$itemDescription%'],
    );

    return result
        .map(
          (row) => {
            'date': row['date'] as String,
            'shopName': row['shop_name'] as String,
            'unitPrice': (row['unit_price'] as num).toDouble(),
            'quantity': (row['quantity'] as num).toDouble(),
          },
        )
        .toList();
  }

  Future<List<String>> getShopNames() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT $columnShopName FROM $tableReceipts ORDER BY $columnShopName ASC',
    );
    return result.map((row) => row[columnShopName] as String).toList();
  }

  Future<List<String>> getItemNames() async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT $columnDescription FROM $tableReceiptItems ORDER BY $columnDescription ASC',
    );
    return result.map((row) => row[columnDescription] as String).toList();
  }

  Future<double?> getLastItemPrice(String itemName) async {
    final db = await databaseHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT ri.${columnUnitPrice}
      FROM ${tableReceiptItems} ri
      JOIN ${tableReceipts} r ON ri.${columnReceiptId} = r.${columnId}
      WHERE LOWER(ri.${columnDescription}) = LOWER(?)
      ORDER BY r.${columnDate} DESC
      LIMIT 1
      ''',
      [itemName],
    );
    if (result.isEmpty) return null;
    return (result.first[columnUnitPrice] as num?)?.toDouble();
  }

  // Shop methods
  Future<List<ShopModel>> getShops() async {
    final db = await databaseHelper.database;
    final result = await db.query(
      tableShops,
      orderBy: '$columnShopNameCol ASC',
    );
    return result.map((row) => ShopModel.fromDatabaseJson(row)).toList();
  }

  Future<ShopModel?> getShopById(int id) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      tableShops,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return ShopModel.fromDatabaseJson(result.first);
  }

  Future<int> insertShop(ShopModel shop) async {
    final db = await databaseHelper.database;
    return await db.insert(tableShops, shop.toDatabaseJson());
  }

  Future<void> updateShop(ShopModel shop) async {
    if (shop.id == null) throw Exception('Shop ID is required for update');
    final db = await databaseHelper.database;
    await db.update(
      tableShops,
      shop.toDatabaseJson(),
      where: '${columnId} = ?',
      whereArgs: [shop.id],
    );
  }

  Future<void> deleteShop(int id) async {
    final db = await databaseHelper.database;
    await db.delete(tableShops, where: '${columnId} = ?', whereArgs: [id]);
  }

  Future<String> getShopNameById(int shopId) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      tableShops,
      columns: [columnShopNameCol],
      where: '${columnId} = ?',
      whereArgs: [shopId],
    );
    if (result.isEmpty) return '';
    return result.first[columnShopNameCol] as String;
  }

  Future<List<ReceiptModel>> getReceiptsByShopId(int shopId) async {
    final db = await databaseHelper.database;
    final receipts = await db.query(
      tableReceipts,
      where: '$columnShopId = ?',
      whereArgs: [shopId],
      orderBy: '$columnDate DESC',
    );

    final List<ReceiptModel> receiptList = [];
    for (var receiptMap in receipts) {
      final items = await getReceiptItems(receiptMap[columnId] as int);
      receiptList.add(ReceiptModel.fromDatabaseJson(receiptMap, items));
    }
    return receiptList;
  }

  // Category methods
  Future<List<CategoryModel>> getCategories() async {
    final db = await databaseHelper.database;
    final result = await db.query(
      tableCategories,
      orderBy: '$columnCategoryName ASC',
    );
    return result.map((row) => CategoryModel.fromDatabaseJson(row)).toList();
  }

  Future<CategoryModel?> getCategoryById(int id) async {
    final db = await databaseHelper.database;
    final result = await db.query(
      tableCategories,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CategoryModel.fromDatabaseJson(result.first);
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await databaseHelper.database;
    return await db.insert(tableCategories, category.toDatabaseJson());
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (category.id == null)
      throw Exception('Category ID is required for update');
    final db = await databaseHelper.database;
    await db.update(
      tableCategories,
      category.toDatabaseJson(),
      where: '${columnId} = ?',
      whereArgs: [category.id],
    );
  }

  Future<void> deleteCategory(int id) async {
    final db = await databaseHelper.database;
    await db.delete(tableCategories, where: '${columnId} = ?', whereArgs: [id]);
  }

  Future<bool> categoryHasReceiptItems(int categoryId) async {
    final db = await databaseHelper.database;
    final category = await getCategoryById(categoryId);
    if (category == null) return false;

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM $tableReceiptItems
      WHERE $columnCategory = ?
      LIMIT 1
      ''',
      [category.name],
    );
    return (result.first['count'] as int) > 0;
  }
}
