import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/currency/i_currency_exchange_service.dart';
import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/contracts/services/database/storage/i_sync_status_storage_service.dart';
import '../../../core/contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../core/providers/database/storage/account_storage_service_provider.dart';
import '../../../core/providers/database/storage/sync_status_storage_service_provider.dart';
import '../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../models/dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._ref) : super(const DashboardState());

  final Ref _ref;

  IAccountStorageService get _accountStorage => _ref.read(accountStorageProvider);
  ITransactionStorageService get _transactionStorage => _ref.read(transactionStorageProvider);
  ISyncStatusStorageService get _syncStatusStorage => _ref.read(syncStatusStorageProvider);
  ICurrencyExchangeService get _currencyService => _ref.read(currencyExchangeServiceProvider);

  Future<void> loadDashboardData() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final (
        List<Account> accounts,
        List<Transaction> recentTransactions,
        Map<String, dynamic>? syncStatus,
        String baseCurrency,
        Map<String, double> convertedBalances,
      ) = await (
        _loadAccounts(),
        _loadRecentTransactions(),
        _loadSyncStatus(),
        _currencyService.getBaseCurrency(),
        _loadAccountBalancesInBaseCurrency(),
      ).wait;

      final double totalBalance = convertedBalances.values.fold(0.0, (double sum, double balance) => sum + balance);
      final double monthlySpending = await _calculateMonthlySpendingInBaseCurrency(recentTransactions);

      state = state.copyWith(
        isLoading: false,
        accounts: accounts,
        recentTransactions: recentTransactions,
        totalBalance: totalBalance,
        monthlySpending: monthlySpending,
        lastSyncStatus: syncStatus,
        lastRefresh: DateTime.now(),
      );
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to load dashboard data',
        error: e,
        stackTrace: stackTrace,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data. Please try again.',
      );
    }
  }

  Future<List<Account>> _loadAccounts() async {
    final List<Account> accounts = await _accountStorage.getAll();
    return accounts.where((Account account) => account.isActive).toList();
  }

  Future<List<Transaction>> _loadRecentTransactions() async {
    final List<Account> accounts = await _accountStorage.getAll();
    final List<Transaction> allTransactions = <Transaction>[];

    for (final Account account in accounts) {
      final List<Transaction> accountTransactions =
          await _transactionStorage.getAllByAccount(account.id);
      allTransactions.addAll(accountTransactions);
    }

    allTransactions.sort((Transaction a, Transaction b) => b.transactionDate.compareTo(a.transactionDate));
    return allTransactions.take(10).toList();
  }

  Future<Map<String, dynamic>?> _loadSyncStatus() async {
    return _syncStatusStorage.getLatest();
  }

  Future<Map<String, double>> _loadAccountBalancesInBaseCurrency() async {
    try {
      final List<Account> accounts = await _loadAccounts();
      return await _currencyService.convertAccountBalancesToBaseCurrency(accounts);
    } catch (e, stackTrace) {
      await log(
        message: 'Failed to convert account balances to base currency',
        error: e,
        stackTrace: stackTrace,
      );
      
      final List<Account> accounts = await _loadAccounts();
      return Map<String, double>.fromEntries(
        accounts.map((Account account) => MapEntry<String, double>(account.id, account.balance)),
      );
    }
  }

  Future<double> _calculateMonthlySpendingInBaseCurrency(List<Transaction> transactions) async {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);
    final String baseCurrency = await _currencyService.getBaseCurrency();

    final List<Transaction> monthlyExpenses = transactions
        .where((Transaction t) =>
            t.type == TransactionType.debit &&
            t.transactionDate.isAfter(monthStart))
        .toList();

    double totalSpending = 0.0;

    for (final Transaction transaction in monthlyExpenses) {
      try {
        final Account? account = await _accountStorage.get(transaction.accountId);
        final String transactionCurrency = account?.currency ?? 'GBP';
        
        if (transactionCurrency.toUpperCase() == baseCurrency.toUpperCase()) {
          totalSpending += transaction.amount.abs();
        } else {
          final double convertedAmount = await _currencyService.convertAmount(
            transaction.amount.abs(),
            transactionCurrency,
            baseCurrency,
          );
          totalSpending += convertedAmount;
        }
      } catch (e, stackTrace) {
        await log(
          message: 'Failed to convert transaction ${transaction.id} to base currency',
          error: e,
          stackTrace: stackTrace,
        );
        
        totalSpending += transaction.amount.abs();
      }
    }

    return totalSpending;
  }

  Future<void> refresh() async {
    await loadDashboardData();
  }

  void clearError() {
    state = state.copyWith();
  }
}

final StateNotifierProvider<DashboardNotifier, DashboardState> dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (StateNotifierProviderRef<DashboardNotifier, DashboardState> ref) => DashboardNotifier(ref),
);
