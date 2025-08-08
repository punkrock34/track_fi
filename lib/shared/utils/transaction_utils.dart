import 'package:flutter/material.dart';

import '../../core/models/database/transaction.dart';
import 'currency_utils.dart';

class TransactionUtils {
  TransactionUtils._();

  /// Get appropriate icon for transaction based on description
  static IconData getTransactionIcon(String description) {
    final String lowerDesc = description.toLowerCase();
    
    if (lowerDesc.contains('grocery') ||
        lowerDesc.contains('supermarket') ||
        lowerDesc.contains('food')) {
      return Icons.shopping_cart_rounded;
    } else if (lowerDesc.contains('gas') ||
               lowerDesc.contains('fuel') ||
               lowerDesc.contains('petrol')) {
      return Icons.local_gas_station_rounded;
    } else if (lowerDesc.contains('restaurant') ||
               lowerDesc.contains('cafe') ||
               lowerDesc.contains('dining')) {
      return Icons.restaurant_rounded;
    } else if (lowerDesc.contains('transfer') ||
               lowerDesc.contains('payment')) {
      return Icons.swap_horiz_rounded;
    } else if (lowerDesc.contains('salary') ||
               lowerDesc.contains('income')) {
      return Icons.work_rounded;
    } else if (lowerDesc.contains('atm') ||
               lowerDesc.contains('cash')) {
      return Icons.local_atm_rounded;
    } else if (lowerDesc.contains('subscription') ||
               lowerDesc.contains('recurring')) {
      return Icons.repeat_rounded;
    } else {
      return Icons.receipt_rounded;
    }
  }

  /// Format transaction type for display
  static String formatTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.debit:
        return 'Expense';
      case TransactionType.credit:
        return 'Income';
    }
  }

  /// Get color for transaction type
  static Color getTransactionColor(TransactionType type, ThemeData theme) {
    switch (type) {
      case TransactionType.debit:
        return theme.colorScheme.error;
      case TransactionType.credit:
        return theme.colorScheme.primary;
    }
  }

  /// Format transaction amount with sign
  static String formatAmountWithSign(Transaction t, {String currency = 'lei'}) {
    final bool isDebit = t.type == TransactionType.debit;
    final String sign = isDebit ? '-' : '+';

    final String formatted = CurrencyUtils.formatAmount(
      t.amount.abs(),
      currency: currency,
    );
    return '$sign$formatted';
  }

  /// Format transaction status for display
  static String formatStatus(String status) {
    return status.split('_').map((String word) =>
        word[0].toUpperCase() + word.substring(1).toLowerCase()).join(' ');
  }

  /// Get color for transaction status
  static Color getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'completed':
        return theme.colorScheme.primary;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurface.withOpacity(0.7);
    }
  }

  /// Group transactions by date
  static Map<String, List<Transaction>> groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = <String, List<Transaction>>{};
    
    for (final Transaction transaction in transactions) {
      final String dateKey = _formatDateKey(transaction.transactionDate);
      grouped.putIfAbsent(dateKey, () => <Transaction>[]);
      grouped[dateKey]!.add(transaction);
    }
    
    return grouped;
  }

  /// Format date for grouping
  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Parse date key back to DateTime
  static DateTime parseDateKey(String dateKey) {
    final List<String> parts = dateKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }

  /// Filter transactions by type
  static List<Transaction> filterByType(List<Transaction> transactions, TransactionType? type) {
    if (type == null) {
      return transactions;
    }
    return transactions.where((Transaction t) => t.type == type).toList();
  }

  /// Filter transactions by account
  static List<Transaction> filterByAccount(List<Transaction> transactions, String? accountId) {
    if (accountId == null) {
      return transactions;
    }
    return transactions.where((Transaction t) => t.accountId == accountId).toList();
  }

  /// Calculate monthly spending from transactions
  static double calculateMonthlySpending(List<Transaction> transactions) {
    final DateTime now = DateTime.now();
    final DateTime monthStart = DateTime(now.year, now.month);

    return transactions
        .where((Transaction t) =>
            t.type == TransactionType.debit &&
            t.transactionDate.isAfter(monthStart))
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());
  }

  /// Calculate weekly spending from transactions
  static double calculateWeeklySpending(List<Transaction> transactions) {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

    return transactions
        .where((Transaction t) =>
            t.type == TransactionType.debit &&
            t.transactionDate.isAfter(weekStart))
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());
  }
}
