import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/i_database_service.dart';
import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/providers/database/database_service_provider.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../../features/accounts/providers/accounts_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../models/add_transaction_state.dart';
import '../providers/transactions_provider.dart';

class AddTransactionNotifier extends StateNotifier<AddTransactionState> {
  AddTransactionNotifier(this._ref) : super(AddTransactionState(transactionDate: DateTime.now()));

  final Ref _ref;

  ITransactionStorageService get _transactionStorage => _ref.read(transactionStorageProvider);
  IAccountStorageService get _accountStorage => _ref.read(accountStorageProvider);
  IDatabaseService get _database => _ref.read(databaseServiceProvider);

  void updateAccountId(String accountId) {
    state = state.copyWith(accountId: accountId);
  }

  void updateAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateReference(String? reference) {
    state = state.copyWith(reference: reference);
  }

  void updateTransactionDate(DateTime date) {
    state = state.copyWith(transactionDate: date);
  }

  void updateType(TransactionType type) {
    state = state.copyWith(type: type);
  }

  void updateCategoryId(String? categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  Future<bool> createTransaction() async {
    if (!state.isValid) {
      state = state.error(state.validationError!);
      return false;
    }

    if (state.isLoading) {
      return false;
    }

    state = state.loading();

    try {
      final DateTime now = DateTime.now();
      final String transactionId = 'txn_${now.millisecondsSinceEpoch}';

      final Account? currentAccount = await _accountStorage.get(state.accountId!);
      if (currentAccount == null) {
        state = state.error('Selected account no longer exists');
        return false;
      }

      final double newBalance = state.type == TransactionType.credit
          ? currentAccount.balance + state.amount
          : currentAccount.balance - state.amount;

      if (state.type == TransactionType.debit && newBalance < 0) {
        state = state.error('Insufficient funds. This transaction would result in a negative balance.');
        return false;
      }

      final Transaction transaction = Transaction(
        id: transactionId,
        accountId: state.accountId!,
        categoryId: state.categoryId,
        amount: state.amount,
        description: state.description.trim(),
        reference: (state.reference?.trim().isNotEmpty ?? false) ? state.reference!.trim() : null,
        transactionDate: state.transactionDate!,
        balanceAfter: newBalance,
        type: state.type,
        createdAt: now,
        updatedAt: now,
      );

      final Account updatedAccount = currentAccount.copyWith(
        balance: newBalance,
        updatedAt: now,
      );

      await _database.rawQuery('BEGIN TRANSACTION');
      
      try {
        await _transactionStorage.save(transaction);
        await _accountStorage.update(updatedAccount);
        await _database.rawQuery('COMMIT');
      } catch (e) {
        await _database.rawQuery('ROLLBACK');
        rethrow;
      }

      _ref.invalidate(accountProvider(updatedAccount.id));
      _ref.read(transactionsProvider.notifier).loadTransactions();
      _ref.read(accountsProvider.notifier).loadAccounts();
      _ref.read(dashboardProvider.notifier).loadDashboardData();
      
      state = state.success();
      return true;
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to create transaction',
        error: e,
        stackTrace: stackTrace,
      );
      state = state.error('Failed to create transaction. Please try again.');
      return false;
    }
  }

  void reset({String? preselectedAccountId}) {
    state = AddTransactionState(
      transactionDate: DateTime.now(),
      accountId: preselectedAccountId,
    );
  }
}

final StateNotifierProvider<AddTransactionNotifier, AddTransactionState> addTransactionProvider =
    StateNotifierProvider<AddTransactionNotifier, AddTransactionState>(
  (StateNotifierProviderRef<AddTransactionNotifier, AddTransactionState> ref) => AddTransactionNotifier(ref),
);
