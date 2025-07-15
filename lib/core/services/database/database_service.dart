import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../contracts/services/database/i_database_service.dart';

class DatabaseService implements IDatabaseService {
  Database? _db;
  static const String _databaseName = 'trackfi.db';
  static const int _databaseVersion = 1;

  @override
  Future<void> init() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);
    _db = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
    await _insertDefaultData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0.0,
        currency TEXT NOT NULL DEFAULT 'GBP',
        bank_name TEXT,
        account_number TEXT,
        sort_code TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        last_synced_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        type TEXT NOT NULL CHECK (type IN ('income', 'expense', 'transfer')),
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        account_id TEXT NOT NULL,
        category_id TEXT,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        reference TEXT,
        transaction_date TEXT NOT NULL,
        balance_after REAL,
        type TEXT NOT NULL CHECK (type IN ('debit', 'credit')),
        status TEXT NOT NULL DEFAULT 'completed',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        synced_at TEXT,
        FOREIGN KEY (account_id) REFERENCES accounts (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        last_sync_attempt TEXT NOT NULL,
        last_successful_sync TEXT,
        sync_status TEXT NOT NULL CHECK (sync_status IN ('success', 'failed', 'in_progress')),
        error_message TEXT,
        records_synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_transactions_account_date ON transactions(account_id, transaction_date)');
    await db.execute(
        'CREATE INDEX idx_transactions_date ON transactions(transaction_date)');
    await db.execute(
        'CREATE INDEX idx_accounts_active ON accounts(is_active)');
  }

  static Future<void> _insertDefaultData(Database db) async {
    final List<Map<String, Object>> defaultCategories = <Map<String, Object>>[
      <String, Object>{
        'id': 'cat_income_salary',
        'name': 'Salary',
        'icon': 'work',
        'color': '#4CAF50',
        'type': 'income',
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      <String, Object>{
        'id': 'cat_expense_groceries',
        'name': 'Groceries',
        'icon': 'shopping_cart',
        'color': '#FF9800',
        'type': 'expense',
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      <String, Object>{
        'id': 'cat_expense_transport',
        'name': 'Transport',
        'icon': 'directions_car',
        'color': '#2196F3',
        'type': 'expense',
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      <String, Object>{
        'id': 'cat_expense_dining',
        'name': 'Dining Out',
        'icon': 'restaurant',
        'color': '#E91E63',
        'type': 'expense',
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
      <String, Object>{
        'id': 'cat_transfer_internal',
        'name': 'Transfer',
        'icon': 'swap_horiz',
        'color': '#9C27B0',
        'type': 'transfer',
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final Map<String, Object> c in defaultCategories) {
      await db.insert('categories', c);
    }
  }

  @override
  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  @override
  Future<void> deleteDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _db = null;
  }

  @override
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]) async {
    return _db!.rawQuery(sql, args);
  }

  @override
  Future<int> insert(String table, Map<String, dynamic> data) async {
    return _db!.insert(table, data);
  }

  @override
  Future<int> update(
      String table, Map<String, dynamic> data,
      {String? where, List<Object?>? whereArgs}) async {
    return _db!.update(table, data, where: where, whereArgs: whereArgs);
  }

  @override
  Future<int> delete(
      String table, {
      String? where,
      List<Object?>? whereArgs,
    }) async {
    return _db!.delete(table, where: where, whereArgs: whereArgs);
  }

  @override
  Future<List<Map<String, dynamic>>> query(
      String table, {
      String? where,
      List<Object?>? whereArgs,
      String? orderBy,
      int? limit,
    }) async {
    return _db!.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }
}
