import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/models.dart';
import '../../domain/entities/entities.dart';

class ReceiptLocalDataSource {
  final DatabaseHelper databaseHelper;

  ReceiptLocalDataSource(this.databaseHelper);

  Future<List<ReceiptModel>> getReceipts() async {
    final db = await databaseHelper.database;
    final receipts = await db.query(
      tableReceipts,
      orderBy: '$columnDate DESC',
    );

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
    final receiptId = await db.insert(
      tableReceipts,
      receipt.toDatabaseJson(),
    );

    // Insert items
    for (var item in receipt.items) {
      await db.insert(
        tableReceiptItems,
        {
          columnReceiptId: receiptId,
          columnQuantity: item.quantity,
          columnDescription: item.description,
          columnUnitPrice: item.unitPrice,
          columnAmount: item.amount,
          columnCategory: item.category,
        },
      );
    }

    return receiptId;
  }

  Future<void> updateReceipt(ReceiptModel receipt) async {
    if (receipt.id == null) throw Exception('Receipt ID is required for update');

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
      await db.insert(
        tableReceiptItems,
        {
          columnReceiptId: receipt.id,
          columnQuantity: item.quantity,
          columnDescription: item.description,
          columnUnitPrice: item.unitPrice,
          columnAmount: item.amount,
          columnCategory: item.category,
        },
      );
    }
  }

  Future<void> deleteReceipt(int id) async {
    final db = await databaseHelper.database;
    await db.delete(
      tableReceipts,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
    // Items will be deleted automatically due to CASCADE
  }

  Future<Map<String, dynamic>> getStatistics() async {
    final db = await databaseHelper.database;

    // Total spending
    final totalResult = await db.rawQuery(
      'SELECT SUM(${columnTotalAmount}) as total FROM ${tableReceipts}',
    );
    final totalSpending = (totalResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Spending by category
    final categoryResult = await db.rawQuery(
      '''
      SELECT ${columnCategory}, SUM(${columnAmount}) as total
      FROM ${tableReceiptItems}
      GROUP BY ${columnCategory}
      ''',
    );
    final Map<String, double> spendingByCategory = {};
    for (var row in categoryResult) {
      spendingByCategory[row[columnCategory] as String] =
          (row['total'] as num).toDouble();
    }

    // Spending by shop
    final shopResult = await db.rawQuery(
      '''
      SELECT ${columnShopName}, SUM(${columnTotalAmount}) as total
      FROM ${tableReceipts}
      GROUP BY ${columnShopName}
      ''',
    );
    final Map<String, double> spendingByShop = {};
    for (var row in shopResult) {
      spendingByShop[row[columnShopName] as String] =
          (row['total'] as num).toDouble();
    }

    // Monthly spending
    final monthlyResult = await db.rawQuery(
      '''
      SELECT strftime('%Y-%m', ${columnDate}) as month, SUM(${columnTotalAmount}) as total
      FROM ${tableReceipts}
      GROUP BY month
      ORDER BY month DESC
      ''',
    );
    final Map<String, double> monthlySpending = {};
    for (var row in monthlyResult) {
      monthlySpending[row['month'] as String] = (row['total'] as num).toDouble();
    }

    return {
      'totalSpending': totalSpending,
      'spendingByCategory': spendingByCategory,
      'spendingByShop': spendingByShop,
      'monthlySpending': monthlySpending,
    };
  }

  Future<List<Map<String, dynamic>>> getPriceHistory(String itemDescription) async {
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

    return result.map((row) => {
          'date': row['date'] as String,
          'shopName': row['shop_name'] as String,
          'unitPrice': (row['unit_price'] as num).toDouble(),
          'quantity': (row['quantity'] as num).toDouble(),
        }).toList();
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
    return await db.insert(
      tableShops,
      shop.toDatabaseJson(),
    );
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
    await db.delete(
      tableShops,
      where: '${columnId} = ?',
      whereArgs: [id],
    );
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
}

