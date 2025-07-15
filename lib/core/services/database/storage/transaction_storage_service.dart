import '../../../contracts/services/database/i_database_service.dart';
import '../../../contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../models/database/transaction.dart';

class TransactionStorageService implements ITransactionStorageService {

  TransactionStorageService(this.db);
  final IDatabaseService db;

  @override
  Future<void> save(Transaction transaction) async {
    await db.insert('transactions', transaction.toMap());
  }

  @override
  Future<void> update(Transaction transaction) async {
    await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: <String>[transaction.id],
    );
  }

  @override
  Future<void> delete(String id) async {
    await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: <String>[id],
    );
  }

  @override
  Future<Transaction?> get(String id) async {
    final List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: <String>[id],
    );

    return result.isEmpty ? null : Transaction.fromMap(result.first);
  }

  @override
  Future<List<Transaction>> getAllByAccount(String accountId) async {
    final List<Map<String, dynamic>> results = await db.query(
      'transactions',
      where: 'account_id = ?',
      whereArgs: <String>[accountId],
      orderBy: 'transaction_date DESC',
    );

    return results.map((Map<String, dynamic> m) => Transaction.fromMap(m)).toList();
  }

  @override
  Future<void> clearAll() async {
    await db.delete('transactions');
  }
}
