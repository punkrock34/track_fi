import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/providers/database/database_service_provider.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../accounts/providers/accounts_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class TransactionsNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  TransactionsNotifier(this._ref) : super(const AsyncValue<List<Transaction>>.loading());

  final Ref _ref;

  ITransactionStorageService get _transactionStorage => _ref.read(transactionStorageProvider);
  IAccountStorageService get _accountStorage => _ref.read(accountStorageProvider);

  Future<void> loadTransactions() async {
    state = const AsyncValue<List<Transaction>>.loading();

    try {
      final List<Account> accounts = await _accountStorage.getAll();
      final List<Transaction> allTransactions = <Transaction>[];

      for (final Account account in accounts) {
        final List<Transaction> accountTransactions =
            await _transactionStorage.getAllByAccount(account.id);
        allTransactions.addAll(accountTransactions);
      }

      allTransactions.sort((Transaction a, Transaction b) =>
          b.transactionDate.compareTo(a.transactionDate));

      state = AsyncValue<List<Transaction>>.data(allTransactions);
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to load transactions',
        error: e,
        stackTrace: stackTrace,
      );
      state = AsyncValue<List<Transaction>>.error(e, stackTrace);
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      final Transaction? transaction = await _transactionStorage.get(transactionId);
      if (transaction == null) {
        return false;
      }

      final Account? account = await _accountStorage.get(transaction.accountId);
      if (account == null) {
        return false;
      }

      double newBalance;
      if (transaction.type == TransactionType.debit) {
        newBalance = account.balance + transaction.amount;
      } else {
        newBalance = account.balance - transaction.amount;
      }

      await _ref.read(databaseServiceProvider).rawQuery('BEGIN TRANSACTION');
      
      try {
        await _transactionStorage.delete(transactionId);
        
        final Account updatedAccount = account.copyWith(
          balance: newBalance,
          updatedAt: DateTime.now(),
        );
        await _accountStorage.update(updatedAccount);
        
        await _ref.read(databaseServiceProvider).rawQuery('COMMIT');
        
        await loadTransactions();
        _ref.read(accountsProvider.notifier).loadAccounts();
        _ref.read(dashboardProvider.notifier).loadDashboardData();
        
        return true;
      } catch (e) {
        await _ref.read(databaseServiceProvider).rawQuery('ROLLBACK');
        rethrow;
      }
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to delete transaction',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> refresh() async {
    await loadTransactions();
  }
}

final StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>> transactionsProvider =
    StateNotifierProvider<TransactionsNotifier, AsyncValue<List<Transaction>>>(
  (StateNotifierProviderRef<TransactionsNotifier, AsyncValue<List<Transaction>>> ref) => TransactionsNotifier(ref),
);

// Individual transaction provider
final FutureProviderFamily<Transaction?, String> transactionProvider =
    FutureProviderFamily<Transaction?, String>((FutureProviderRef<Transaction?> ref, String transactionId) async {
  final ITransactionStorageService storage = ref.read(transactionStorageProvider);
  return storage.get(transactionId);
});
