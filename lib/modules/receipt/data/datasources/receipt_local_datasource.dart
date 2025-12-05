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
}

