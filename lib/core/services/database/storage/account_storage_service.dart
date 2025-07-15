import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_account_storage_service.dart';
import '../../../models/database/account.dart';

class AccountStorageService implements IAccountStorageService {

  AccountStorageService(this.db);
  final IDatabaseService db;

  @override
  Future<void> save(Account account) async {
    await db.insert('accounts', account.toMap());
  }

  @override
  Future<void> update(Account account) async {
    await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: <String>[account.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.delete(
      'accounts',
      where: 'id = ?',
      whereArgs: <String>[id],
    );
  }

  @override
  Future<Account?> get(String id) async {
    final List<Map<String, dynamic>> result = await db.query(
      'accounts',
      where: 'id = ?',
      whereArgs: <String>[id],
    );

    return result.isEmpty ? null : Account.fromMap(result.first);
  }

  @override
  Future<List<Account>> getAll() async {
    final List<Map<String, dynamic>> results = await db.query('accounts');
    return results.map((Map<String, dynamic> m) => Account.fromMap(m)).toList();
  }
  
  @override
  Future<void> clearAll() async {
    await db.delete('accounts');
  }
}
