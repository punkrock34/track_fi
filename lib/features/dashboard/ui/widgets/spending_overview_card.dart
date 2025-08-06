import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../core/models/database/transaction.dart';
import '../../../../core/theme/design_tokens/design_tokens.dart';
import '../../../../shared/providers/ui/balance_visibility_provider.dart';
import 'spending_metric.dart';

class SpendingOverviewCard extends ConsumerWidget {
  const SpendingOverviewCard({
    super.key,
    required this.monthlySpending,
    required this.recentTransactions,
    required this.onToggleVisibility,
  });

  final double monthlySpending;
  final List<Transaction> recentTransactions;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final double weeklySpending = _calculateWeeklySpending();
    final bool showBalance = ref.watch(balanceVisibilityProvider);
    
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
                  child: SpendingMetric(
                    label: 'This Month',
                    amount: monthlySpending,
                    currency: '£',
                    visible: showBalance,
                  ),
                ),
                const Gap(DesignTokens.spacingMd),
                Expanded(
                  child: SpendingMetric(
                    label: 'This Week',
                    amount: weeklySpending,
                    currency: '£',
                    visible: showBalance,
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
