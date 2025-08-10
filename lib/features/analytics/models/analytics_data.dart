import 'package:flutter/material.dart';
import '../../../core/models/database/transaction.dart';

class AnalyticsData {
  const AnalyticsData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netIncome,
    required this.monthlyData,
    required this.categoryBreakdown,
    required this.weeklyTrend,
    required this.topCategories,
    required this.period,
  });

  final double totalIncome;
  final double totalExpenses;
  final double netIncome;
  final List<MonthlyData> monthlyData;
  final List<CategoryData> categoryBreakdown;
  final List<DailyData> weeklyTrend;
  final List<CategoryData> topCategories;
  final AnalyticsPeriod period;
}

class MonthlyData {
  const MonthlyData({
    required this.month,
    required this.income,
    required this.expenses,
    required this.net,
  });

  final String month;
  final double income;
  final double expenses;
  final double net;
}

class CategoryData {
  const CategoryData({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
    required this.color,
    required this.transactionCount,
  });

  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;
  final Color color;
  final int transactionCount;
}

class DailyData {
  const DailyData({
    required this.date,
    required this.amount,
    required this.type,
  });

  final DateTime date;
  final double amount;
  final TransactionType type;
}

enum AnalyticsPeriod {
  week('This Week'),
  month('This Month'),
  quarter('This Quarter'),
  year('This Year'),
  all('All Time');

  const AnalyticsPeriod(this.label);
  final String label;
}
