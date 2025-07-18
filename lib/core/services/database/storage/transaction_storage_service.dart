import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../models/database/transaction.dart';

class TransactionStorageService implements ITransactionStorageService {
  TransactionStorageService(this._db);

  final IDatabaseService _db;

  static const String _table = 'transactions';

  @override
  Future<void> save(Transaction transaction) =>
      _db.insert(_table, transaction.toMap());

  @override
  Future<void> update(Transaction transaction) =>
      _db.update(
        _table,
        transaction.toMap(),
        where: 'id = ?',
        whereArgs: <Object?>[transaction.id],
      );

  @override
  Future<void> delete(String id) =>
      _db.delete(
        _table,
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );

  @override
  Future<Transaction?> get(String id) async {
    final List<Map<String, dynamic>> result = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
    return result.isEmpty ? null : Transaction.fromMap(result.first);
  }

  @override
  Future<List<Transaction>> getAllByAccount(String accountId) async {
    final List<Map<String, dynamic>> results = await _db.query(
      _table,
      where: 'account_id = ?',
      whereArgs: <Object?>[accountId],
      orderBy: 'transaction_date DESC',
    );

    return results
        .map(Transaction.fromMap)
        .toList();
  }

  @override
  Future<void> clearAll() => _db.delete(_table);
}
