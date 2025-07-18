import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';

class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.accounts = const <Account>[],
    this.recentTransactions = const <Transaction>[],
    this.totalBalance = 0.0,
    this.monthlySpending = 0.0,
    this.lastSyncStatus,
    this.lastRefresh,
    this.error,
  });

  final bool isLoading;
  final List<Account> accounts;
  final List<Transaction> recentTransactions;
  final double totalBalance;
  final double monthlySpending;
  final Map<String, dynamic>? lastSyncStatus;
  final DateTime? lastRefresh;
  final String? error;

  DashboardState copyWith({
    bool? isLoading,
    List<Account>? accounts,
    List<Transaction>? recentTransactions,
    double? totalBalance,
    double? monthlySpending,
    Map<String, dynamic>? lastSyncStatus,
    DateTime? lastRefresh,
    String? error,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      accounts: accounts ?? this.accounts,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      totalBalance: totalBalance ?? this.totalBalance,
      monthlySpending: monthlySpending ?? this.monthlySpending,
      lastSyncStatus: lastSyncStatus ?? this.lastSyncStatus,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      error: error,
    );
  }

  bool get hasData => accounts.isNotEmpty || recentTransactions.isNotEmpty;
  bool get isFirstLoad => !hasData && !isLoading;
}
