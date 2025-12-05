part of 'database_helper.dart';

// Table names
const String tableReceipts = 'receipts';
const String tableReceiptItems = 'receipt_items';

// Receipts table columns
const String columnId = 'id';
const String columnShopName = 'shop_name';
const String columnDate = 'date';
const String columnTotalAmount = 'total_amount';

// Receipt items table columns
const String columnReceiptId = 'receipt_id';
const String columnQuantity = 'quantity';
const String columnDescription = 'description';
const String columnUnitPrice = 'unit_price';
const String columnAmount = 'amount';
const String columnCategory = 'category';

// Create receipts table SQL
const String createReceiptsTable = '''
  CREATE TABLE $tableReceipts (
    $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
    $columnShopName TEXT NOT NULL,
    $columnDate TEXT NOT NULL,
    $columnTotalAmount REAL NOT NULL
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

