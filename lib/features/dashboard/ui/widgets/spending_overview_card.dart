import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../core/theme/design_tokens/typography.dart';

class SpendingOverviewCard extends StatelessWidget {
  const SpendingOverviewCard({
    super.key,
    required this.monthlySpending,
    required this.recentTransactions,
  });

  final double monthlySpending;
  final List<Transaction> recentTransactions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double weeklySpending = _calculateWeeklySpending();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Spending Overview',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(DesignTokens.spacingSm),
            Row(
              children: <Widget>[
                Expanded(
                  child: _SpendingMetric(
                    label: 'This Month',
                    amount: monthlySpending,
                    currency: '£',
                  ),
                ),
                const Gap(DesignTokens.spacingMd),
                Expanded(
                  child: _SpendingMetric(
                    label: 'This Week',
                    amount: weeklySpending,
                    currency: '£',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _calculateWeeklySpending() {
    final DateTime now = DateTime.now();
    final DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));

    return recentTransactions
        .where((Transaction t) => 
            t.type == TransactionType.debit && 
            t.transactionDate.isAfter(weekStart))
        .fold(0.0, (double sum, Transaction t) => sum + t.amount.abs());
  }
}

class _SpendingMetric extends StatelessWidget {
  const _SpendingMetric({
    required this.label,
    required this.amount,
    required this.currency,
  });

  final String label;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const Gap(DesignTokens.spacing2xs),
        Text(
          '$currency${amount.toStringAsFixed(2)}',
          style: AppTypography.moneyMedium.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
