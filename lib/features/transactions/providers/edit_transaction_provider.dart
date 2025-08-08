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
import '../../accounts/providers/accounts_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../models/edit_transaction_state.dart';
import 'transactions_provider.dart';

class EditTransactionNotifier extends StateNotifier<EditTransactionState?> {
  EditTransactionNotifier(this._ref) : super(null);

  final Ref _ref;

  ITransactionStorageService get _transactionStorage =>
      _ref.read(transactionStorageProvider);
  IAccountStorageService get _accountStorage =>
      _ref.read(accountStorageProvider);
  IDatabaseService get _database => _ref.read(databaseServiceProvider);

  Future<void> loadTransaction(String transactionId) async {
    try {
      final Transaction? tx = await _transactionStorage.get(transactionId);
      if (tx == null) {
      state = null;
      return;
      }
      state = EditTransactionState.fromTransaction(tx);
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to load transaction for editing',
        error: e,
        stackTrace: stackTrace,
      );
      state = null;
    }
  }

  void updateAccountId(String id) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(accountId: id);
  }

  void updateAmount(double amt) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(amount: amt);
  }

  void updateDescription(String desc) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(description: desc);
  }

  void updateReference(String? ref) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(reference: ref);
  }

  void updateTransactionDate(DateTime date) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(transactionDate: date);
  }

  void updateType(TransactionType type) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(type: type);
  }

  void updateCategoryId(String? categoryId) {
    final EditTransactionState? current = state;
    if (current == null) {
      return;
    }
    state = current.updateField(categoryId: categoryId);
  }

  Future<bool> saveChanges() async {
    final EditTransactionState? s = state;
    if (s == null || !s.isValid || !s.hasChanges) {
      return false;
    }

    state = s.copyWith(isLoading: true);

    try {
      final Transaction? updatedTx = s.toUpdatedTransaction();
      final Transaction? originalTx = s.originalTransaction;
      if (updatedTx == null || originalTx == null) {
        state = s.error('Invalid transaction data');
        return false;
      }

      final Account? currentAccount =
          await _accountStorage.get(updatedTx.accountId);
      if (currentAccount == null) {
        state = s.error('Selected account no longer exists');
        return false;
      }

      if (originalTx.accountId != updatedTx.accountId) {
        final Account? originalAccount =
            await _accountStorage.get(originalTx.accountId);
        if (originalAccount == null) {
          state = s.error('Original account no longer exists');
          return false;
        }

        final double origBalance =
            originalTx.type == TransactionType.debit
                ? originalAccount.balance + originalTx.amount
                : originalAccount.balance - originalTx.amount;

        final double newBalance =
            updatedTx.type == TransactionType.debit
                ? currentAccount.balance - updatedTx.amount
                : currentAccount.balance + updatedTx.amount;

        if (updatedTx.type == TransactionType.debit && newBalance < 0) {
          state = s.error(
              'Insufficient funds. This transaction would result in a negative balance.');
          return false;
        }

        await _database.rawQuery('BEGIN TRANSACTION');
        try {
          await _accountStorage.update(originalAccount.copyWith(
            balance: origBalance,
            updatedAt: DateTime.now(),
          ));
          await _accountStorage.update(currentAccount.copyWith(
            balance: newBalance,
            updatedAt: DateTime.now(),
          ));
          await _transactionStorage.update(
            updatedTx.copyWith(balanceAfter: newBalance),
          );
          await _database.rawQuery('COMMIT');
        } catch (e) {
          await _database.rawQuery('ROLLBACK');
          rethrow;
        }

        _ref.invalidate(accountProvider(originalTx.accountId));
        _ref.invalidate(accountProvider(updatedTx.accountId));
      } else {
        double delta = 0;
        final bool typeChanged = originalTx.type != updatedTx.type;

        if (typeChanged) {
          delta += originalTx.type == TransactionType.debit
              ? originalTx.amount
              : -originalTx.amount;
          delta += updatedTx.type == TransactionType.debit
              ? -updatedTx.amount
              : updatedTx.amount;
        } else {
          final double diff = updatedTx.amount - originalTx.amount;
          delta += updatedTx.type == TransactionType.debit ? -diff : diff;
        }

        final double newBalance = currentAccount.balance + delta;
        if (newBalance < 0) {
          state = s.error(
              'Insufficient funds. This transaction would result in a negative balance.');
          return false;
        }

        await _database.rawQuery('BEGIN TRANSACTION');
        try {
          await _accountStorage.update(currentAccount.copyWith(
            balance: newBalance,
            updatedAt: DateTime.now(),
          ));
          await _transactionStorage.update(
            updatedTx.copyWith(balanceAfter: newBalance),
          );
          await _database.rawQuery('COMMIT');
        } catch (e) {
          await _database.rawQuery('ROLLBACK');
          rethrow;
        }

        _ref.invalidate(accountProvider(updatedTx.accountId));
      }

      _ref.invalidate(transactionProvider(updatedTx.id));
      _ref.read(transactionsProvider.notifier).loadTransactions();
      _ref.read(accountsProvider.notifier).loadAccounts();
      _ref.read(dashboardProvider.notifier).loadDashboardData();

      state = s.success().copyWith(hasChanges: false);
      return true;
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to save transaction changes',
        error: e,
        stackTrace: stackTrace,
      );
      state = s.error('Failed to save changes. Please try again.');
      return false;
    }
  }

  void discardChanges() {
    final EditTransactionState? s = state;
    if (s == null || s.originalTransaction == null) {
      return;
    }
    state = EditTransactionState.fromTransaction(s.originalTransaction!);
  }

  void reset() {
    state = null;
  }
}

final StateNotifierProviderFamily<EditTransactionNotifier, EditTransactionState?, String>
    editTransactionProvider = StateNotifierProvider.family(
  (StateNotifierProviderRef<EditTransactionNotifier, EditTransactionState?> ref, String transactionId) {
    final EditTransactionNotifier notifier = EditTransactionNotifier(ref);
    notifier.loadTransaction(transactionId);
    return notifier;
  },
);
