import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/database/account.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../../contracts/services/database/storage/i_account_storage_service.dart';

final FutureProvider<List<Account>> activeAccountsProvider = FutureProvider<List<Account>>((FutureProviderRef<List<Account>> ref) async {
  final IAccountStorageService storage = ref.read(accountStorageProvider);
  final List<Account> all = await storage.getAll();
  return all.where((Account a) => a.isActive).toList();
});
