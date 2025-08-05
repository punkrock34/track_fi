import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../contracts/services/database/i_database_service.dart';
import '../../contracts/services/secure_storage/i_encryption_storage_service.dart';
import '../../database/migration_manager.dart';

class DatabaseService implements IDatabaseService {
  DatabaseService(this._encryptionStorage);

  final IEncryptionStorageService _encryptionStorage;
  Database? _db;
  static const String _databaseName = 'trackfi.db';

  @override
  Future<void> init() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, _databaseName);

    _db = await openDatabase(
      path,
      version: MigrationManager.latestVersion,
      onCreate: MigrationManager.onCreate,
      onUpgrade: MigrationManager.onUpgrade,
      onDowngrade: MigrationManager.onDowngrade,
      onOpen: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
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
    final Map<String, dynamic> encrypted = await _encrypt(table, data);
    return _db!.insert(table, encrypted);
  }

  @override
  Future<int> update(String table, Map<String, dynamic> data, {String? where, List<Object?>? whereArgs}) async {
    final Map<String, dynamic> encrypted = await _encrypt(table, data);
    return _db!.update(table, encrypted, where: where, whereArgs: whereArgs);
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
    final List<Map<String, Object?>> result = await _db!.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );

    return Future.wait(result.map((Map<String, Object?> row) => _decrypt(table, row)));
  }


  Set<String> _sensitiveFieldsForTable(String table) {
    switch (table) {
      case 'accounts':
        return <String>{'account_number', 'sort_code', 'bank_name'};
      case 'transactions':
        return <String>{'reference'};
      default:
        return <String>{};
    }
  }

  Future<Map<String, dynamic>> _encrypt(String table, Map<String, dynamic> data) async {
    final Set<String> fields = _sensitiveFieldsForTable(table);
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (fields.contains(entry.key) && entry.value != null) {
        result[entry.key] = await _encryptionStorage.encrypt(entry.value.toString());
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }

  Future<Map<String, dynamic>> _decrypt(String table, Map<String, dynamic> data) async {
    final Set<String> fields = _sensitiveFieldsForTable(table);
    final Map<String, dynamic> result = <String, dynamic>{};
    for (final MapEntry<String, dynamic> entry in data.entries) {
      if (fields.contains(entry.key) && entry.value != null) {
        result[entry.key] = await _encryptionStorage.decrypt(entry.value.toString());
      } else {
        result[entry.key] = entry.value;
      }
    }
    return result;
  }
}
