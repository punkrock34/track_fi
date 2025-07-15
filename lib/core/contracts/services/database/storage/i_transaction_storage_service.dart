import '../../../../models/database/transaction.dart';

abstract class ITransactionStorageService {
  Future<void> save(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(String id);
  Future<Transaction?> get(String id);
  Future<List<Transaction>> getAllByAccount(String accountId);
  Future<void> clearAll();
}
