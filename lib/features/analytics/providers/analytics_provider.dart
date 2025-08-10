import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/contracts/services/database/storage/i_transaction_storage_service.dart';
import '../../../core/models/database/account.dart';
import '../../../core/models/database/transaction.dart';
import '../../../core/providers/currency/currency_exchange_service_provider.dart';
import '../../../core/providers/database/storage/transaction_storage_service_provider.dart';
import '../../../core/providers/financial/active_accounts_provider.dart';
import '../../../shared/utils/category_utils.dart';
import '../models/analytics_data.dart';

class AnalyticsNotifier extends StateNotifier<AsyncValue<AnalyticsData>> {
  AnalyticsNotifier(this._ref) : super(const AsyncValue<AnalyticsData>.loading());

  final Ref _ref;

  Future<void> loadAnalytics(AnalyticsPeriod period) async {
    state = const AsyncValue<AnalyticsData>.loading();

    try {
      final List<Account> accounts = await _ref.read(activeAccountsProvider.future);
      final ITransactionStorageService txStorage = _ref.read(transactionStorageProvider);
      final String baseCurrency = await _ref.read(currencyExchangeServiceProvider).getBaseCurrency();
      
      // Get all transactions for active accounts
      final List<Transaction> allTransactions = <Transaction>[];
      for (final Account account in accounts) {
        final List<Transaction> accountTx = await txStorage.getAllByAccount(account.id);
        allTransactions.addAll(accountTx);
      }

      // Filter by period
      final DateTime now = DateTime.now();
      final DateTime startDate = _getStartDateForPeriod(period, now);
      final List<Transaction> filteredTransactions = allTransactions
          .where((Transaction t) => t.transactionDate.isAfter(startDate))
          .toList();

      // Calculate analytics data
      final AnalyticsData analyticsData = await _calculateAnalyticsData(
        filteredTransactions,
        accounts,
        period,
        baseCurrency,
      );

      state = AsyncValue<AnalyticsData>.data(analyticsData);
    } catch (error, stackTrace) {
      state = AsyncValue<AnalyticsData>.error(error, stackTrace);
    }
  }

  DateTime _getStartDateForPeriod(AnalyticsPeriod period, DateTime now) {
    switch (period) {
      case AnalyticsPeriod.week:
        return now.subtract(const Duration(days: 7));
      case AnalyticsPeriod.month:
        return DateTime(now.year, now.month);
      case AnalyticsPeriod.quarter:
        final int currentQuarter = ((now.month - 1) ~/ 3) + 1;
        final int quarterStartMonth = (currentQuarter - 1) * 3 + 1;
        return DateTime(now.year, quarterStartMonth);
      case AnalyticsPeriod.year:
        return DateTime(now.year);
      case AnalyticsPeriod.all:
        return DateTime(2020); // Far enough back
    }
  }

  Future<AnalyticsData> _calculateAnalyticsData(
    List<Transaction> transactions,
    List<Account> accounts,
    AnalyticsPeriod period,
    String baseCurrency,
  ) async {
    // Convert all amounts to base currency
    final List<Transaction> convertedTx = <Transaction>[];
    for (final Transaction tx in transactions) {
      final Account account = accounts.firstWhere((Account a) => a.id == tx.accountId);
      double convertedAmount = tx.amount;
      
      if (account.currency != baseCurrency) {
        try {
          convertedAmount = await _ref.read(currencyExchangeServiceProvider)
              .convertAmount(tx.amount, account.currency, baseCurrency);
        } catch (_) {
          // Fallback to original amount if conversion fails
        }
      }
      
      convertedTx.add(tx.copyWith(amount: convertedAmount));
    }

    // Calculate totals
    final double totalIncome = convertedTx
        .where((Transaction t) => t.type == TransactionType.credit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount);

    final double totalExpenses = convertedTx
        .where((Transaction t) => t.type == TransactionType.debit)
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());

    final double netIncome = totalIncome - totalExpenses;

    // Calculate monthly data
    final List<MonthlyData> monthlyData = _calculateMonthlyData(convertedTx, period);

    // Calculate category breakdown
    final List<CategoryData> categoryBreakdown = _calculateCategoryBreakdown(
      convertedTx.where((Transaction t) => t.type == TransactionType.debit).toList(),
      totalExpenses,
    );

    // Calculate weekly trend
    final List<DailyData> weeklyTrend = _calculateWeeklyTrend(convertedTx);

    // Top categories (top 5)
    final List<CategoryData> topCategories = categoryBreakdown.take(5).toList();

    return AnalyticsData(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      netIncome: netIncome,
      monthlyData: monthlyData,
      categoryBreakdown: categoryBreakdown,
      weeklyTrend: weeklyTrend,
      topCategories: topCategories,
      period: period,
    );
  }

  List<MonthlyData> _calculateMonthlyData(List<Transaction> transactions, AnalyticsPeriod period) {
    final Map<String, List<Transaction>> monthlyGroups = <String, List<Transaction>>{};
    
    for (final Transaction tx in transactions) {
      final String monthKey = '${tx.transactionDate.year}-${tx.transactionDate.month.toString().padLeft(2, '0')}';
      monthlyGroups.putIfAbsent(monthKey, () => <Transaction>[]);
      monthlyGroups[monthKey]!.add(tx);
    }

    final List<MonthlyData> monthlyData = <MonthlyData>[];
    final List<String> sortedKeys = monthlyGroups.keys.toList()..sort();
    
    for (final String key in sortedKeys.take(12)) { // Last 12 months max
      final List<Transaction> monthTx = monthlyGroups[key]!;
      final double income = monthTx
          .where((Transaction t) => t.type == TransactionType.credit)
          .fold(0.0, (double sum, Transaction t) => sum + t.amount);
      final double expenses = monthTx
          .where((Transaction t) => t.type == TransactionType.debit)
          .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());

      final List<String> parts = key.split('-');
      final DateTime date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      final String monthName = _getMonthName(date.month);

      monthlyData.add(MonthlyData(
        month: monthName,
        income: income,
        expenses: expenses,
        net: income - expenses,
      ));
    }

    return monthlyData;
  }

  List<CategoryData> _calculateCategoryBreakdown(List<Transaction> expenseTransactions, double totalExpenses) {
    final Map<String, List<Transaction>> categoryGroups = <String, List<Transaction>>{};
    
    for (final Transaction tx in expenseTransactions) {
      final String categoryId = tx.categoryId ?? 'uncategorized';
      categoryGroups.putIfAbsent(categoryId, () => <Transaction>[]);
      categoryGroups[categoryId]!.add(tx);
    }

    final List<CategoryData> categoryData = <CategoryData>[];
    
    for (final MapEntry<String, List<Transaction>> entry in categoryGroups.entries) {
      final String categoryId = entry.key;
      final List<Transaction> categoryTx = entry.value;
      final double amount = categoryTx.fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());
      final double percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;

      final ThemeData fakeTheme = ThemeData();
      
      categoryData.add(CategoryData(
        categoryId: categoryId,
        categoryName: CategoryUtils.getCategoryName(categoryId),
        amount: amount,
        percentage: percentage,
        color: CategoryUtils.getCategoryColor(categoryId, fakeTheme),
        transactionCount: categoryTx.length,
      ));
    }

    // Sort by amount descending
    categoryData.sort((CategoryData a, CategoryData b) => b.amount.compareTo(a.amount));
    
    return categoryData;
  }

  List<DailyData> _calculateWeeklyTrend(List<Transaction> transactions) {
    final Map<String, List<Transaction>> dailyGroups = <String, List<Transaction>>{};
    
    for (final Transaction tx in transactions) {
      final String dayKey = '${tx.transactionDate.year}-${tx.transactionDate.month.toString().padLeft(2, '0')}-${tx.transactionDate.day.toString().padLeft(2, '0')}';
      dailyGroups.putIfAbsent(dayKey, () => <Transaction>[]);
      dailyGroups[dayKey]!.add(tx);
    }

    final List<DailyData> dailyData = <DailyData>[];
    final List<String> sortedKeys = dailyGroups.keys.toList()..sort();
    
    for (final String key in sortedKeys.take(30)) { // Last 30 days
      final List<Transaction> dayTx = dailyGroups[key]!;
      final List<String> parts = key.split('-');
      final DateTime date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      
      final double income = dayTx
          .where((Transaction t) => t.type == TransactionType.credit)
          .fold(0.0, (double sum, Transaction t) => sum + t.amount);
      final double expenses = dayTx
          .where((Transaction t) => t.type == TransactionType.debit)
          .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());

      if (income > 0) {
        dailyData.add(DailyData(date: date, amount: income, type: TransactionType.credit));
      }
      if (expenses > 0) {
        dailyData.add(DailyData(date: date, amount: expenses, type: TransactionType.debit));
      }
    }

    return dailyData;
  }

  String _getMonthName(int month) {
    const List<String> months = <String>[
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}

final StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsData>> analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AsyncValue<AnalyticsData>>(
  (StateNotifierProviderRef<AnalyticsNotifier, AsyncValue<AnalyticsData>> ref) => AnalyticsNotifier(ref),
);
