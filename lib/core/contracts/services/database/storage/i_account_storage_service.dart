import '../../../../models/database/account.dart';

abstract class IAccountStorageService {
  Future<void> save(Account account);
  Future<void> update(Account account);
  Future<void> delete(String id);
  Future<Account?> get(String id);
  Future<List<Account>> getAll();
  Future<void> clearAll();
}
