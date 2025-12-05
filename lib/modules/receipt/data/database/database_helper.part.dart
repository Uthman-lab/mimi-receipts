part of 'database_helper.dart';

// Table names
const String tableReceipts = 'receipts';
const String tableReceiptItems = 'receipt_items';
const String tableShops = 'shops';

// Receipts table columns
const String columnId = 'id';
const String columnShopId = 'shop_id';
const String columnShopName = 'shop_name';
const String columnDate = 'date';
const String columnTotalAmount = 'total_amount';

// Shops table columns
const String columnShopNameCol = 'name';
const String columnShopAddress = 'address';
const String columnShopTel = 'tel';

// Receipt items table columns
const String columnReceiptId = 'receipt_id';
const String columnQuantity = 'quantity';
const String columnDescription = 'description';
const String columnUnitPrice = 'unit_price';
const String columnAmount = 'amount';
const String columnCategory = 'category';

// Create shops table SQL
const String createShopsTable = '''
  CREATE TABLE $tableShops (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnShopNameCol TEXT NOT NULL,
    $columnShopAddress TEXT,
    $columnShopTel TEXT
  )
''';

// Create receipts table SQL (updated with shop_id)
const String createReceiptsTable = '''
  CREATE TABLE $tableReceipts (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnShopId INTEGER NOT NULL,
    $columnShopName TEXT NOT NULL,
    $columnDate TEXT NOT NULL,
    $columnTotalAmount REAL NOT NULL,
    FOREIGN KEY ($columnShopId) REFERENCES $tableShops($columnId)
  )
''';

// Create receipt_items table SQL
const String createReceiptItemsTable = '''
  CREATE TABLE $tableReceiptItems (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnReceiptId INTEGER NOT NULL,
    $columnQuantity REAL NOT NULL,
    $columnDescription TEXT NOT NULL,
    $columnUnitPrice REAL NOT NULL,
    $columnAmount REAL NOT NULL,
    $columnCategory TEXT NOT NULL,
    FOREIGN KEY ($columnReceiptId) REFERENCES $tableReceipts($columnId) ON DELETE CASCADE
  )
''';


