import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../core/providers/database/storage/sync_status_storage_service_provider.dart';
import '../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../../core/providers/financial/active_accounts_provider.dart';
import '../../../core/providers/financial/total_balance_provider.dart';
import '../models/dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier(this._ref) : super(const DashboardState());

  final Ref _ref;

  Future<void> loadDashboardData() async {
    if (state.isLoading) {
      return;
    }
    state = state.copyWith(isLoading: true);

    try {
      final List<Account> accounts       = await _ref.read(activeAccountsProvider.future);
      final List<Transaction> recentTx       = await _loadRecentTransactions(accounts);
      final Map<String, dynamic>? syncStatus     = await _ref.read(syncStatusStorageProvider).getLatest();
      final double totalBalance   = await _ref.read(totalBalanceProvider.future);
      final double monthlySpending = await _calculateMonthlySpendingInBaseCurrency(recentTx);

      state = state.copyWith(
        isLoading: false,
        accounts: accounts,
        recentTransactions: recentTx,
        totalBalance: totalBalance,
        monthlySpending: monthlySpending,
        lastSyncStatus: syncStatus,
        lastRefresh: DateTime.now(),
      );
    } catch (e, stackTrace) {
      await log(message: 'Failed to load dashboard data', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load dashboard data. Please try again.',
      );
    }
  }

  Future<List<Transaction>> _loadRecentTransactions(List<Account> accounts) async {
    final ITransactionStorageService txStorage = _ref.read(transactionStorageProvider);
    final List<Transaction> allTransactions = <Transaction>[];

    for (final Account account in accounts) {
      allTransactions.addAll(await txStorage.getAllByAccount(account.id));
    }

    allTransactions.sort((Transaction a, Transaction b) => b.transactionDate.compareTo(a.transactionDate));
    return allTransactions.take(10).toList();
  }

  Future<double> _calculateMonthlySpendingInBaseCurrency(List<Transaction> transactions) async {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);
    final String baseCurrency = await _ref.read(currencyExchangeServiceProvider).getBaseCurrency();

    final List<Transaction> monthlyExpenses = transactions
        .where((Transaction t) => t.type == TransactionType.debit && t.transactionDate.isAfter(monthStart))
        .toList();

    double totalSpending = 0.0;
    for (final Transaction tx in monthlyExpenses) {
      try {
        final Account account = await _ref.read(activeAccountsProvider.future)
                    .then((List<Account> list) => list.firstWhere((Account a) => a.id == tx.accountId, orElse: () => throw Exception('Account not found')));
        final String txCurrency = account.currency;

        if (txCurrency.toUpperCase() == baseCurrency.toUpperCase()) {
          totalSpending += tx.amount.abs();
        } else {
          final double converted = await _ref.read(currencyExchangeServiceProvider)
              .convertAmount(tx.amount.abs(), txCurrency, baseCurrency);
          totalSpending += converted;
        }
      } catch (_) {
        totalSpending += tx.amount.abs();
      }
    }
    return totalSpending;
  }

  Future<void> refresh() => loadDashboardData();
}

final StateNotifierProvider<DashboardNotifier, DashboardState> dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>(
  (StateNotifierProviderRef<DashboardNotifier, DashboardState> ref) => DashboardNotifier(ref),
);
