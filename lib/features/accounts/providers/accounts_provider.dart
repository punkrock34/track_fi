import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';

class AccountsNotifier extends StateNotifier<AsyncValue<List<Account>>> {
  AccountsNotifier(this._ref) : super(const AsyncValue<List<Account>>.loading());

  final Ref _ref;

  IAccountStorageService get _storage => _ref.read(accountStorageProvider);

  Future<void> loadAccounts() async {
    state = const AsyncValue<List<Account>>.loading();

    try {
      final List<Account> accounts = await _storage.getAll();
      state = AsyncValue<List<Account>>.data(accounts);
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to load accounts',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue<List<Account>>.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadAccounts();
  }
}

final StateNotifierProvider<AccountsNotifier, AsyncValue<List<Account>>> accountsProvider =
    StateNotifierProvider<AccountsNotifier, AsyncValue<List<Account>>>(
  (StateNotifierProviderRef<AccountsNotifier, AsyncValue<List<Account>>> ref) => AccountsNotifier(ref),
);

// Individual account provider
final FutureProviderFamily<Account?, String> accountProvider =
    FutureProviderFamily<Account?, String>((FutureProviderRef<Account?> ref, String accountId) async {
  final IAccountStorageService storage = ref.read(accountStorageProvider);
  return storage.get(accountId);
});
