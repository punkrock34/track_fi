import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_account_storage_service.dart';
import '../../../models/database/account.dart';

class AccountStorageService implements IAccountStorageService {
  AccountStorageService(this._db);

  final IDatabaseService _db;

  static const String _table = 'accounts';

  @override
  Future<void> save(Account account) =>
      _db.insert(_table, account.toMap());

  @override
  Future<void> update(Account account) =>
      _db.update(
        _table,
        account.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[account.id],
      );

  @override
  Future<void> delete(String id) =>
      _db.delete(
        _table,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );

  @override
  Future<Account?> get(String id) async {
    final List<Map<String, dynamic>> result = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isEmpty ? null : Account.fromMap(result.first);
  }

  @override
  Future<List<Account>> getAll() async {
    final List<Map<String, dynamic>> results = await _db.query(_table);
    return results.map(Account.fromMap).toList();
  }

  @override
  Future<void> clearAll() => _db.delete(_table);
}
