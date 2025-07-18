import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_account_storage_service.dart';
import '../../../core/contracts/services/database/storage/i_sync_status_storage_service.dart';
import '../../../core/contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../core/logging/log.dart';
import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
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

  Future<void> loadDashboardData() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      // Load all data concurrently
      final (
        List<Account> accounts,
        List<Transaction> recentTransactions,
        Map<String, dynamic>? syncStatus
      ) = await (
        _loadAccounts(),
        _loadRecentTransactions(),
        _loadSyncStatus(),
      ).wait;

      // Calculate totals
      final double totalBalance = _calculateTotalBalance(accounts);
      final double monthlySpending = _calculateMonthlySpending(recentTransactions);

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

    // Sort by date and take recent 10
    allTransactions.sort((Transaction a, Transaction b) => 
        b.transactionDate.compareTo(a.transactionDate));
    
    return allTransactions.take(10).toList();
  }

  Future<Map<String, dynamic>?> _loadSyncStatus() async {
    return _syncStatusStorage.getLatest();
  }

  double _calculateTotalBalance(List<Account> accounts) {
    return accounts.fold(0.0, (double sum, Account account) => sum + account.balance);
  }

  double _calculateMonthlySpending(List<Transaction> transactions) {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);

    return transactions
        .where((Transaction t) => 
            t.type == TransactionType.debit && 
            t.transactionDate.isAfter(monthStart))
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());
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
