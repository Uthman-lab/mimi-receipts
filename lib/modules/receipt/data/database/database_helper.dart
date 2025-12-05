import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
part 'database_helper.part.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('receipts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute(createShopsTable);
    await db.execute(createReceiptsTable);
    await db.execute(createReceiptItemsTable);
    await db.execute(createCategoriesTable);

    // Insert default categories
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create shops table
      await db.execute(createShopsTable);

      // Add shop_id column to receipts table
      await db.execute(
        'ALTER TABLE $tableReceipts ADD COLUMN $columnShopId INTEGER',
      );

      // Migrate existing shop names to shops table
      final shopNamesResult = await db.rawQuery(
        'SELECT DISTINCT $columnShopName FROM $tableReceipts WHERE $columnShopName IS NOT NULL',
      );

      final shopNameToId = <String, int>{};

      for (final row in shopNamesResult) {
        final shopName = row[columnShopName] as String;
        if (shopName.isNotEmpty && !shopNameToId.containsKey(shopName)) {
          final shopId = await db.insert(tableShops, {
            columnShopNameCol: shopName,
          });
          shopNameToId[shopName] = shopId;
        }
      }

      // Update receipts with shop_id based on shop_name
      for (final entry in shopNameToId.entries) {
        await db.update(
          tableReceipts,
          {columnShopId: entry.value},
          where: '$columnShopName = ?',
          whereArgs: [entry.key],
        );
      }

      // Make shop_id NOT NULL after migration
      // Note: SQLite doesn't support ALTER COLUMN, so we'll keep it nullable
      // but ensure all existing records have shop_id set
    }

    if (oldVersion < 3) {
      // Create categories table
      await db.execute(createCategoriesTable);

      // Insert default categories
      await _insertDefaultCategories(db);
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    // Check if categories already exist
    final existingCategories = await db.query(tableCategories);
    if (existingCategories.isNotEmpty) return;

    // Default categories with their colors
    final defaultCategories = [
      {'name': 'Food', 'color': '0xFFF59E0B'},
      {'name': 'Electronics', 'color': '0xFF3B82F6'},
      {'name': 'Clothing', 'color': '0xFFEC4899'},
      {'name': 'Household', 'color': '0xFF10B981'},
      {'name': 'Personal Care', 'color': '0xFF8B5CF6'},
      {'name': 'Other', 'color': '0xFF6B7280'},
    ];

    for (final category in defaultCategories) {
      await db.insert(tableCategories, {
        columnCategoryName: category['name'],
        columnCategoryColor: category['color'],
      });
    }
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}
