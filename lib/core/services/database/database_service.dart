import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../contracts/services/database/i_database_service.dart';
import '../../database/migration_manager.dart';

class DatabaseService implements IDatabaseService {
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
    return _db!.insert(table, data);
  }

  @override
  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
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
